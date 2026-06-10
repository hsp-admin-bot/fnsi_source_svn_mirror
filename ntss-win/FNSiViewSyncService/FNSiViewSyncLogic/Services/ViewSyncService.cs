using System;
using System.Collections.Generic;
using System.Linq;
using System.Text.RegularExpressions;
using System.Threading;
using FNSiViewSyncLogicLib.Common.Utilities;
using FNSiViewSyncLogicLib.Services;
using NKKLoggingLib;

namespace FNSiViewSyncLogicLib.Service
{
    public class ViewSyncService
    {
        //private readonly String CONFIG_INITALUPDATEDDATE_SECTION = "Settings\\Common\\InitialUpdatedDate";
        private readonly String CONFIG_FILE_NAME = "FNSiViewSync.config";
        private readonly String XMLG_FILE_NAME = "FNSiViewSync.xml";


        public void InitialViewSync()
        {
            try
            {
                ViewTableInfo[] cumulativeModeArray = FNSiViewSyncSetting.m_viewTableInfoListAll
                    .Where(v => v.Mode == Mode.ACCUMULATION.ToString())
                    .ToArray();
                ViewTableInfo[] fullItemModeArray = FNSiViewSyncSetting.m_viewTableInfoListAll
                    .Where(v => v.Mode == Mode.FULL_ITEM.ToString())
                    .ToArray();

                foreach (ViewTableInfo viewTableInfo in cumulativeModeArray)
                {
                    string jobKeyName = $"init_{viewTableInfo.KeyName}";
                    if (IsExecutable(viewTableInfo, SyncMode.START, jobKeyName))
                    {
                        viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                        XmlService.UpdateViewXmlTableLastStartDateByName(viewTableInfo.KeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"サービス起動時データ更新キュー登録処理:{viewTableInfo.KeyName}：蓄積型");
                        QueueProcessor.Enqueue(() => ProcessAcumulativeMode(viewTableInfo, SyncMode.START, $"サービス起動時データ更新キュー登録処理:{viewTableInfo.KeyName}：蓄積型", jobKeyName));
                    }
                }
                foreach (ViewTableInfo viewTableInfo in fullItemModeArray)
                {
                    string jobKeyName = $"init_{viewTableInfo.KeyName}";
                    if (IsExecutable(viewTableInfo, SyncMode.START, jobKeyName))
                    {
                        viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                        XmlService.UpdateViewXmlTableLastStartDateByName(viewTableInfo.KeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"サービス起動時データ更新キュー登録処理:{viewTableInfo.KeyName}：全更新型");
                        QueueProcessor.Enqueue(() => ProcessFullItemMode(viewTableInfo, SyncMode.START, $"サービス起動時データ更新キュー登録処理:{viewTableInfo.KeyName}：全更新型", jobKeyName));
                    }
                }
                //ModifyFNSiViewSyncConfig("Common", CONFIG_INITALUPDATEDDATE_SECTION, DateTime.Now.ToString("yyyyMMddHHmmss"));
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        public void StartIntervalUpdateServices()
        {
            try
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "###間隔処理開始###");
                var filteredAndSorted = FNSiViewSyncSetting.m_intervalViewTableInfoList
                    .FindAll(s => s.IsEffect)
                    .OrderBy(s => s.No);

                foreach (ViewTableInfo viewTableInfo in filteredAndSorted)
                {
                    string keyName = viewTableInfo.KeyName;
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"間隔同期:{keyName}スレッド開始");
                    if (!FNSiViewSyncSetting.JobStatusList.ContainsKey(keyName))
                    {
                        FNSiViewSyncSetting.JobStatusList.Add(keyName, new JobStatus());
                        FNSiViewSyncSetting.JobStatusList[keyName].StartDate = DateTime.Now;
                        FNSiViewSyncSetting.JobStatusList[keyName].ViewTableInfo = viewTableInfo;
                    }
                    viewTableInfo.JobKeyName = keyName;
                    Timer timer = new Timer(UpdateCallback, viewTableInfo, TimeSpan.FromMinutes(int.Parse(viewTableInfo.UpdateInterval)), Timeout.InfiniteTimeSpan);
                    FNSiViewSyncSetting.Timers.Add(keyName, timer);
                }

                void UpdateCallback(object state)
                {
                    ViewTableInfo viewTableInfo = (ViewTableInfo)state;
                    try
                    {
                        string keyName = viewTableInfo.KeyName;
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG,
                            string.Format("間隔同期コールバック開始:{0}, {1}", viewTableInfo.KeyName, DateTime.Now.ToString("yyyy/MM/dd HH:mm")));

                        DateTime startDate = FNSiViewSyncSetting.JobStatusList[keyName].StartDate;
                        DateTime endDate = DateTime.Now;

                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"間隔同期:{keyName} 日付[{startDate:yyyy/MM/dd HH:mm:ss}～{endDate:yyyy/MM/dd HH:mm:ss}]");

                        if (viewTableInfo.Mode == Mode.ACCUMULATION.ToString())
                        {
                            if (IsExecutable(viewTableInfo, SyncMode.TIME_SPAN, keyName))
                            {
                                viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                                XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"間隔時間同期のデータ更新キュー登録:{keyName}：蓄積型");
                                QueueProcessor.Enqueue(() => ProcessAcumulativeMode(viewTableInfo, SyncMode.TIME_SPAN, $"間隔時間同期のデータ更新キュー登録:{keyName}：蓄積型", keyName));
                            }
                        }
                        if (viewTableInfo.Mode == Mode.FULL_ITEM.ToString())
                        {
                            if (IsExecutable(viewTableInfo, SyncMode.TIME_SPAN, keyName))
                            {
                                viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                                XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"間隔時間同期のデータ更新キュー登録:{keyName}：全更新型");
                                QueueProcessor.Enqueue(() => ProcessFullItemMode(viewTableInfo, SyncMode.TIME_SPAN, $"間隔時間同期のデータ更新キュー登録:{keyName}：全更新型", keyName));
                            }
                        }

                        FNSiViewSyncSetting.JobStatusList[keyName].StartDate = endDate;
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, string.Format("間隔同期コールバック完了:{0}, {1}", viewTableInfo.KeyName, DateTime.Now.ToString("yyyy/MM/dd HH:mm")));
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            CommonUtil.EndProcessing(viewTableInfo.KeyName, viewTableInfo.JobKeyName);
                            if (!String.IsNullOrEmpty(viewTableInfo.UpdateInterval) && SyncMode.TIME_SPAN.Equals(SyncMode.TIME_SPAN))
                            {
                                FNSiViewSyncSetting.Timers[viewTableInfo.JobKeyName].Change(TimeSpan.FromMinutes(int.Parse(viewTableInfo.UpdateInterval)), Timeout.InfiniteTimeSpan);
                            }
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"{ex.Message}:{ex.StackTrace}");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"コールバック処理中にエラーが発生しました、処理をスキップしました:{viewTableInfo.KeyName}");
                        }
                        catch (Exception ex2)
                        {
                            throw ex2;
                        }
                    }

                }
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        public void StartUpdateFixService()
        {
            try
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "###固定同期処理開始###");
                var filteredAndSorted = FNSiViewSyncSetting.m_fixViewTableInfoList
                    .FindAll(s => s.IsEffect)
                    .OrderBy(s => s.No);

                foreach (ViewTableInfo viewTableInfo in filteredAndSorted)
                {
                    string keyName = viewTableInfo.KeyName;
                    string[] weekList = viewTableInfo.Week.Split(',');
                    string[] timeList = viewTableInfo.Time.Split(',');


                    foreach (string week in weekList)
                    {
                        foreach (string time in timeList)
                        {
                            viewTableInfo.JobKeyName = $"{keyName}_{week}_{time}";
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期:{viewTableInfo.JobKeyName}スレッド開始");
                            if (!FNSiViewSyncSetting.JobStatusList.ContainsKey($"{viewTableInfo.JobKeyName}"))
                            {
                                FNSiViewSyncSetting.JobStatusList.Add($"{viewTableInfo.JobKeyName}", new JobStatus());
                                FNSiViewSyncSetting.JobStatusList[$"{viewTableInfo.JobKeyName}"].StartDate = DateTime.Now;
                                FNSiViewSyncSetting.JobStatusList[$"{viewTableInfo.JobKeyName}"].ViewTableInfo = viewTableInfo;
                            }
                            DateTime now = DateTime.Now;
                            DateTime nextTargetDateTime = CommonUtil.GetNextTargetDateTime(now, (DayOfWeek)int.Parse(week), time.ToString());
                            TimeSpan timeUntilTarget = nextTargetDateTime - now;
                            Timer timer = new Timer(UpdateCallback, (viewTableInfo, week, time), TimeSpan.FromSeconds(timeUntilTarget.TotalSeconds), Timeout.InfiniteTimeSpan);
                            FNSiViewSyncSetting.Timers.Add($"{viewTableInfo.JobKeyName}", timer);
                        }
                    }
                }

                void UpdateCallback(object state)
                {
                    var (viewTableInfo, day, time) = ((ViewTableInfo viewTableInfo, string Day, string Time))state;
                    try
                    {
                        string keyName = viewTableInfo.KeyName;
                        string jobKeyName = viewTableInfo.JobKeyName;
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期コールバック開始:{jobKeyName}, {DateTime.Now.ToString("yyyy/MM/dd HH:mm")}");

                        DateTime startDate = FNSiViewSyncSetting.JobStatusList[jobKeyName].StartDate;
                        DateTime endDate = DateTime.Now;

                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期:{keyName} 日付[{startDate:yyyy/MM/dd HH:mm:ss}～{endDate:yyyy/MM/dd HH:mm:ss}]");
                        if (viewTableInfo.Mode == Mode.ACCUMULATION.ToString())
                        {
                            if (IsExecutable(viewTableInfo, SyncMode.MODE1, jobKeyName))
                            {
                                viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                                XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期のデータ更新キュー登録:{jobKeyName}：蓄積型");
                                QueueProcessor.Enqueue(() => ProcessAcumulativeMode(viewTableInfo, SyncMode.MODE1, $"固定同期のデータ更新キュー登録:{jobKeyName}：蓄積型", jobKeyName));
                            }
                        }
                        if (viewTableInfo.Mode == Mode.FULL_ITEM.ToString())
                        {
                            if (IsExecutable(viewTableInfo, SyncMode.MODE1, jobKeyName))
                            {
                                viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                                XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期のデータ更新キュー登録:{jobKeyName}：全更新型");
                                QueueProcessor.Enqueue(() => ProcessFullItemMode(viewTableInfo, SyncMode.MODE1, $"固定同期のデータ更新キュー登録:{jobKeyName}：全更新型", jobKeyName));
                            }
                        }

                        FNSiViewSyncSetting.JobStatusList[jobKeyName].StartDate = endDate;

                        // ModifyFNSiViewSyncConfig("Common", CONFIG_INITALUPDATEDDATE_SECTION, DateTime.Now.ToString("yyyyMMddHHmmss"));
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"固定同期コールバック完了:{jobKeyName}, {DateTime.Now.ToString("yyyy/MM/dd HH:mm")}");
                    }
                    catch (Exception ex)
                    {
                        try
                        {
                            // 0～6
                            string patternDay = @"^[0-6]$";
                            // 00:00～23:59
                            string patternTime = @"^(?:[01]\d|2[0-3]):[0-5]\d$";
                            CommonUtil.EndProcessing(viewTableInfo.KeyName, viewTableInfo.JobKeyName);
                            if (!String.IsNullOrEmpty(viewTableInfo.Week) && !String.IsNullOrEmpty(viewTableInfo.Time)
                                && Regex.IsMatch(day, patternDay) && Regex.IsMatch(time, patternTime))
                            {

                                DateTime now = DateTime.Now;
                                DateTime nextTargetDateTime = CommonUtil.GetNextTargetDateTime(now, (DayOfWeek)int.Parse(day), time.ToString());
                                TimeSpan timeUntilTarget = nextTargetDateTime - now;
                                FNSiViewSyncSetting.Timers[viewTableInfo.JobKeyName].Change(TimeSpan.FromSeconds(timeUntilTarget.TotalSeconds), Timeout.InfiniteTimeSpan);
                            }
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, $"{ex.Message}:{ex.StackTrace}");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"コールバック処理中にエラーが発生しました、処理をスキップしました:{viewTableInfo.JobKeyName}");
                        }
                        catch (Exception ex2)
                        {
                            throw ex2;
                        }
                    }
                }
            }
            catch (Exception e)
            {
                throw e;
            }
        }

        public void ManualSync(string keyName)
        {
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "###手動同期処理開始###");
            ViewTableInfo viewTableInfo = null;
            foreach (ViewTableInfo table in FNSiViewSyncSetting.m_viewTableInfoListAll)
            {
                if (table.KeyName == keyName)
                {
                    viewTableInfo = table;
                    break;
                }
            }
            if (viewTableInfo == null)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"有効なテーブルリストの中に指定されたkey_nameが存在しませんでした。キー名：{keyName}");
                return;
            }
            string jobKeyName = $"Manual_{keyName}";
            if (viewTableInfo.Mode == Mode.ACCUMULATION.ToString())
            {
                if (IsExecutable(viewTableInfo, SyncMode.Manual, jobKeyName))
                {
                    viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                    XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"手動実行:{jobKeyName}:蓄積型:キュー登録");
                    QueueProcessor.Enqueue(() => ProcessAcumulativeMode(viewTableInfo, SyncMode.Manual, $"手動実行:{jobKeyName}:蓄積型", jobKeyName));
                }
            }
            else if (viewTableInfo.Mode == Mode.FULL_ITEM.ToString())
            {
                if (IsExecutable(viewTableInfo, SyncMode.Manual, jobKeyName))
                {
                    viewTableInfo.RegDate = DateTime.Now.ToString("yyyyMMdd");
                    XmlService.UpdateViewXmlTableLastStartDateByName(keyName);
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"手動実行:{jobKeyName}:全更新型:キュー登録");
                    QueueProcessor.Enqueue(() => ProcessFullItemMode(viewTableInfo, SyncMode.Manual, $"手動実行:{jobKeyName}:全更新型", jobKeyName));
                }
            }
            else
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"手動実行:未定義のモード:{keyName}");
                return;
            }
        }
        private bool IsExecutable(ViewTableInfo viewTableInfo, int syncMode, string jobKeyName)
        {
            lock (FNSiViewSyncSetting.lockFile)
            {
                if (!FNSiViewSyncSetting.JobStatusList.ContainsKey(jobKeyName))
                {
                    FNSiViewSyncSetting.JobStatusList.Add(jobKeyName, new JobStatus());
                }
                int viewSyncCntStatus = FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus;
                if (!(SyncCntStatus.INIT == viewSyncCntStatus) &&
                     !(SyncCntStatus.LAST_END == viewSyncCntStatus))
                    return false;
                if (SyncMode.START == syncMode && !viewTableInfo.OnceFlg)
                    return false;
                if (!viewTableInfo.IsEffect && SyncMode.Manual != syncMode)
                    return false;

                // 蓄積型または全更新型かつsqlfileが設定されてる場合uprangeが1以上の数値かチェック
                if (viewTableInfo.Mode == Mode.ACCUMULATION.ToString() || (viewTableInfo.Mode == Mode.FULL_ITEM.ToString() && !String.IsNullOrEmpty(viewTableInfo.Sqlfile)))
                {
                    if (!int.TryParse(viewTableInfo.UpRange, out int upRange))
                        return false;

                    if (upRange <= 0)
                        return false;
                }
                FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.BEGIN;
            }
            return true;
        }

        private void ProcessAcumulativeMode(ViewTableInfo viewTableInfo, int syncMode, String threadName, string jobKeyName)
        {
            List<List<ViewTableInfo>> sendDataList = new List<List<ViewTableInfo>>();
            List<ViewTableInfo> tblList = new List<ViewTableInfo>();
            DateTime fromDate = DateTime.Now.Date;
            DateTime toDate = DateTime.Now.Date;
            try
            {
                int upRange;
                lock (FNSiViewSyncSetting.lockFile)
                {
                    if (!FNSiViewSyncSetting.JobStatusList.ContainsKey(jobKeyName))
                    {
                        FNSiViewSyncSetting.JobStatusList.Add(jobKeyName, new JobStatus());
                    }
                    int viewSyncCntStatus = FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus;
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ErrorFlag = false;
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewTableInfo = viewTableInfo;
                    if (!int.TryParse(viewTableInfo.UpRange, out upRange))
                        return;

                    if (upRange <= 0)
                        return;
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.BEGIN;
                }
                Dictionary<string, string> viewSyncAttributes = CommonUtil.GetViewSyncAttributes(XMLG_FILE_NAME, viewTableInfo.KeyName, new string[] { "is_init" });
                FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewTableInfo.IsInit = viewSyncAttributes["is_init"] == "1";
                DateTime currentDate = DateTime.Now.Date;
                if (viewTableInfo.IsInit)
                {
                    fromDate = currentDate.AddDays(-viewTableInfo.PastRangeTotal);
                    toDate = currentDate.AddDays(viewTableInfo.FutureRangeTotal + 1);
                }
                else
                {
                    fromDate = currentDate.AddDays(-viewTableInfo.KeepOldLimit);
                    toDate = currentDate.AddDays(viewTableInfo.KeepNewLimit + 1);
                }

                int totalDays = (toDate - fromDate).Days;
                int interval = (totalDays + upRange - 1) / upRange;

                DateTime currentFromDate = fromDate;
                DateTime currentToDate;

                for (int i = 0; i < interval; i++)
                {
                    currentToDate = currentFromDate.AddDays(upRange);
                    if (currentToDate > toDate)
                    {
                        currentToDate = toDate;
                    }

                    ViewTableInfo tbl = ConvertTableData(viewTableInfo, viewTableInfo.RegDate, syncMode, interval, upRange, currentFromDate, currentToDate, i);
                    currentFromDate = currentToDate;

                    tblList.Add(tbl);

                    int ViewSyncCnt = 1;
                    if (tblList.Count == ViewSyncCnt)
                    {
                        sendDataList.Add(new List<ViewTableInfo>(tblList));
                        tblList.Clear();
                    }
                }

                if (tblList.Count > 0)
                {
                    sendDataList.Add(new List<ViewTableInfo>(tblList));
                }
                FNSiViewSyncSetting.JobStatusList[jobKeyName].SendDataList = new List<List<ViewTableInfo>>(sendDataList);
                CommonUtil.Sync(syncMode, threadName, jobKeyName);

                tblList.Clear();
                sendDataList.Clear();
            }
            catch (Exception e)
            {
                try
                {
                    CommonUtil.EndProcessing(viewTableInfo.KeyName, jobKeyName);
                }
                catch (Exception e2)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "ProcessCumulativeMode(),エラー後処理に失敗しました: " + e2.Message + " : " + e2.StackTrace);
                }
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, e.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=500, message=\"VIEWアプリ要求部エラー\", result={viewTableInfo.KeyName}:{fromDate:yyyyMMdd}~{toDate:yyyyMMdd}");
            }
        }

        private void ProcessFullItemMode(ViewTableInfo viewTableInfo, int syncMode, String threadName, string jobKeyName)
        {
            List<List<ViewTableInfo>> sendDataList = new List<List<ViewTableInfo>>();
            List<ViewTableInfo> tblList = new List<ViewTableInfo>();
            try
            {
                lock (FNSiViewSyncSetting.lockFile)
                {
                    if (!FNSiViewSyncSetting.JobStatusList.ContainsKey(jobKeyName))
                    {
                        FNSiViewSyncSetting.JobStatusList.Add(jobKeyName, new JobStatus());
                    }
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ErrorFlag = false;
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewTableInfo = viewTableInfo;
                    FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.BEGIN;
                }
                if (!String.IsNullOrEmpty(viewTableInfo.Sqlfile))
                {
                    if (!int.TryParse(viewTableInfo.UpRange, out int upRange))
                    {
                        CommonUtil.EndProcessing(viewTableInfo.KeyName, jobKeyName);
                        return;
                    }
                    if (upRange <= 0)
                    {
                        CommonUtil.EndProcessing(viewTableInfo.KeyName, jobKeyName);
                        return;
                    }
                    List<string> splitAllItemModeData = CommonUtil.GetSplitAllItemModeData(viewTableInfo);
                    if (splitAllItemModeData == null || splitAllItemModeData.Count == 0)
                    {
                        CommonUtil.EndProcessing(viewTableInfo.KeyName, jobKeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"事前SQLの結果が0件のため処理終了しました result={viewTableInfo.KeyName}");
                        return;
                    }
                    int interval = (splitAllItemModeData.Count + upRange - 1) / upRange;
                    for (int i = 0; i < interval; i++)
                    {
                        int start = i * upRange;
                        int count = upRange;
                        if (start + count > splitAllItemModeData.Count)
                        {
                            count = splitAllItemModeData.Count - start;
                        }
                        List<string> subList = splitAllItemModeData.GetRange(start, count);
                        AddFixTableToList(viewTableInfo, subList);
                    }
                }
                else
                {
                    AddFixTableToList(viewTableInfo);
                }
                FNSiViewSyncSetting.JobStatusList[jobKeyName].SendDataList = new List<List<ViewTableInfo>>(sendDataList);
                CommonUtil.Sync(syncMode, threadName, jobKeyName);

                tblList.Clear();
                sendDataList.Clear();

                void AddFixTableToList(ViewTableInfo viewInfo, List<string> subList = null)
                {
                    ViewTableInfo tbl = ConvertTableData(viewInfo, viewInfo.RegDate, viewInfo.SyncMode, splitAllItemModeData: subList);
                    tblList.Add(tbl);
                    int ViewSyncCnt = 1;
                    if (tblList.Count == ViewSyncCnt)
                    {
                        sendDataList.Add(new List<ViewTableInfo>(tblList));
                        tblList.Clear();
                    }
                }
            }
            catch (Exception ex)
            {
                try
                {
                    CommonUtil.EndProcessing(viewTableInfo.KeyName, jobKeyName);
                }
                catch (Exception e2)
                {
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "ProcessFullItemMode(),エラー後処理に失敗しました: " + e2.Message + " : " + e2.StackTrace);
                }
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, ex.StackTrace);
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=500, message=\"VIEWアプリ要求部エラー\", result={viewTableInfo.KeyName}");
            }
        }

        private ViewTableInfo ConvertTableData(ViewTableInfo viewTableInfo, string regDate, int syncMode, int? interval = null, int? upRange = null, DateTime? fromDate = null, DateTime? toDate = null, int? sequence = null, List<string> splitAllItemModeData = null)
        {
            ViewTableInfo tbl = new ViewTableInfo(viewTableInfo);

            if (fromDate.HasValue && toDate.HasValue && interval.HasValue && upRange.HasValue && sequence.HasValue)
            {
                DateTime nonNullableFromDate = fromDate.Value;
                DateTime nonNullableToDate = toDate.Value;
                tbl.FromDate = nonNullableFromDate.ToString("yyyyMMdd");
                tbl.ToDate = nonNullableToDate.ToString("yyyyMMdd");
            }

            if (splitAllItemModeData != null)
            {
                tbl.SplitAllItemModeData = splitAllItemModeData;
            }

            // 実行結果項目を追加する
            tbl.RegDate = regDate;
            tbl.SyncMode = syncMode;

            return tbl;
        }
    }
}
