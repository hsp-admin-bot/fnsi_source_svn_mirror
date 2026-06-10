using FNSiViewSyncLogicLib.Services;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.Data;
using System.Globalization;
using System.IO;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Xml;
using System.Security.Cryptography;

namespace FNSiViewSyncLogicLib.Common.Utilities
{
    // TODO: UpdateDataUtilを作成し処理を分割する
    public class CommonUtil
    {
        /// <summary>
        /// SQL文を取得する
        /// </summary>
        /// <param name="tableName">テーブル名</param>
        /// <param name="types">種類</param>
        public static string GetSql(String tableName, String type)
        {
            String sqlFileName = String.Format("{0}\\sql\\{1}_{2}.sql", AppDomain.CurrentDomain.BaseDirectory, tableName, type);

            string tmpSql = File.ReadAllText(sqlFileName);
            string sql = tmpSql.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
            return sql;
        }

        public static string GetSqlByName(String name)
        {
            String sqlFileName = String.Format("{0}\\sql\\{1}", AppDomain.CurrentDomain.BaseDirectory, name);

            string tmpSql = File.ReadAllText(sqlFileName);
            string sql = tmpSql.Replace("\r\n", " ").Replace("\r", " ").Replace("\n", " ");
            return sql;
        }

        public static void Sync(int syncMode, string threadName, string jobKeyName)
        {
            FNSiViewSyncSetting.JobStatusList[jobKeyName].RequestTimeStart = DateTime.Now;
            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"{threadName}:{jobKeyName}:開始");
            ViewTableInfo viewTableInfo = FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewTableInfo;
            List<List<ViewTableInfo>> sendDataList = FNSiViewSyncSetting.JobStatusList[jobKeyName].SendDataList;

            try
            {
                FNSiViewSyncSetting.JobStatusList[jobKeyName].ErrorFlag = false;
                FNSiViewSyncSetting.JobStatusList[jobKeyName].StartDate = DateTime.Now;
                DateTime dtRequestStart = DateTime.Now;

                for (int syncCnt = 0; syncCnt < sendDataList.Count; syncCnt++)
                {
                    // 一回同期ビューを取得する
                    List<ViewTableInfo> syncViews = sendDataList[syncCnt];
                    syncViews[0].JobKeyName = jobKeyName;

                    // IFEdgeから、データの取得処理
                    FNSiSocketClient socketClient = new FNSiSocketClient(syncViews);
                    socketClient.IFEdgeIPAddress = FNSiViewSyncSetting.IFEdgeIPAddress;
                    socketClient.IFEdgePortNo = FNSiViewSyncSetting.IFEdgePortNo;
                    socketClient.LocalIPAddress = FNSiViewSyncSetting.LocalIPAddress;
                    socketClient.LocalPortNo = FNSiViewSyncSetting.LocalPortNo;
                    socketClient.SyncMode = syncMode;
                    socketClient.JobKeyName = jobKeyName;

                    if (syncCnt == (sendDataList.Count - 1))
                    {
                        // 一回同期状態(LAST_BEGIN)を設定する
                        FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_BEGIN;
                    }
                    else
                    {
                        // 一回同期状態(BEGIN)を設定する
                        FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.BEGIN;
                    }

                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, string.Format("----------------キー名[{2}]：同期回数[{0:D2}] {1}----------------", (syncCnt + 1), DateTime.Now.ToString("yyyy/MM/dd HH:mm:ss"), sendDataList[0][0].KeyName));

                    // データを取得する
                    // スレッドにてログ削除を行う
                    Thread trdAll = new Thread(socketClient.DoWork)
                    {
                        Name = threadName
                    };
                    trdAll.Start();

                    // FNSiSocketServiceより、同期終了か？
                    int timeoutSeconds = FNSiViewSyncSetting.TimeoutSeconds;
                    int elapsedTime = 0;
                    while (true)
                    {
                        Thread.Sleep(100);
                        elapsedTime += 1;

                        if (SyncCntStatus.END == FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus || SyncCntStatus.LAST_END == FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus)
                        {
                            break;
                        }

                        if (FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus != SyncCntStatus.LAST_BEGIN && elapsedTime >= (timeoutSeconds * 10))
                        {
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, string.Format("タイムアウト発生:キー名[{1}]：同期回数[{0:D2}] でタイムアウトしました。", syncCnt + 1, sendDataList[0][0].KeyName));
                            FNSiViewSyncSetting.JobStatusList[jobKeyName].ErrorFlag = true;  // 中断フラグを設定
                            FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                            trdAll.Abort();  // スレッドを中断する
                            break;
                        }
                    }

                    // エラーになった時
                    if (FNSiViewSyncSetting.JobStatusList[jobKeyName].ErrorFlag)
                    {
                        XmlService.UpdateViewXmlTableLastEndDateByName(viewTableInfo.KeyName);
                        LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"{threadName}:{viewTableInfo.KeyName}を中断しました。");
                        break;  // 中断フラグが立っていれば全体の同期プロセスを中止
                    }

                    // 正常終了した時
                    if (SyncCntStatus.LAST_END == FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus)
                    {
                        XmlService.UpdateViewXmlFile(viewTableInfo);
                        XmlService.UpdateViewXmlTableLastEndDateByName(viewTableInfo.KeyName);
                    }
                }

                string[] jobKeyNameSplit = jobKeyName.Split('_');

                int length = jobKeyNameSplit.Length;

                string day = jobKeyNameSplit[length -2];
                string time = jobKeyNameSplit[length -1];

                // 0～6
                string patternDay = @"^[0-6]$";
                // 00:00～23:59
                string patternTime = @"^(?:[01]\d|2[0-3]):[0-5]\d$";

                if (!String.IsNullOrEmpty(viewTableInfo.UpdateInterval) && SyncMode.TIME_SPAN.Equals(syncMode))
                {
                    FNSiViewSyncSetting.Timers[jobKeyName].Change(TimeSpan.FromMinutes(int.Parse(viewTableInfo.UpdateInterval)), Timeout.InfiniteTimeSpan);
                }
                else if(!String.IsNullOrEmpty(viewTableInfo.Week) && !String.IsNullOrEmpty(viewTableInfo.Time)
                    && Regex.IsMatch(day, patternDay) && Regex.IsMatch(time, patternTime) && SyncMode.MODE1.Equals(syncMode))
                {

                    DateTime now = DateTime.Now;
                    DateTime nextTargetDateTime = GetNextTargetDateTime(now, (DayOfWeek)int.Parse(day), time.ToString());
                    TimeSpan timeUntilTarget = nextTargetDateTime - now;
                    FNSiViewSyncSetting.Timers[jobKeyName].Change(TimeSpan.FromSeconds(timeUntilTarget.TotalSeconds), Timeout.InfiniteTimeSpan);
                }
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"{threadName}:{jobKeyName}:終了");
            }
            catch (Exception e)
            {
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"{threadName}:{jobKeyName}で例外が発生しました: {e.Message}");
                FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
                throw e;
            }

        }

        public static DateTime GetNextTargetDateTime(DateTime now, DayOfWeek targetDay, string time)
        {
            var timeParts = time.Split(':');
            int targetHour = int.Parse(timeParts[0]);
            int targetMinute = int.Parse(timeParts[1]);

            int currentDayOfWeek = (int)now.DayOfWeek;
            int targetDayOfWeek = (int)targetDay;

            int daysUntilTarget = (targetDayOfWeek - currentDayOfWeek + 7) % 7;
            if (daysUntilTarget == 0 && (now.Hour > targetHour || (now.Hour == targetHour && now.Minute >= targetMinute)))
            {
                daysUntilTarget = 7;
            }

            DateTime nextTargetDate = now.Date.AddDays(daysUntilTarget).AddHours(targetHour).AddMinutes(targetMinute);
            return nextTargetDate;
        }

        public static void ReadViewSyncXml(string XMLG_FILE_NAME)
        {
            int retryCount = FNSiViewSyncSetting.XMLRetryCount;
            int retryInterval = FNSiViewSyncSetting.XMLRetryInterval;
            for (int attempt = 0; attempt < retryCount; attempt++)
            {
                try
                {
                    FNSiViewSyncSetting.m_viewTableInfoListAll.Clear();
                    FNSiViewSyncSetting.m_intervalViewTableInfoList.Clear();
                    FNSiViewSyncSetting.m_fixViewTableInfoList.Clear();

                    // SQL設定ファイルフォルダ
                    string strFolder = AppDomain.CurrentDomain.BaseDirectory;
                    String sqlFolder = strFolder + (strFolder.EndsWith("\\") ? "" : "\\") + "sql\\";

                    // XMLファイル名作成
                    String xmlfile = strFolder + (strFolder.EndsWith("\\") ? "" : "\\") + XMLG_FILE_NAME;

                    // テーブル情報取得(XMLより)
                    // 出力先テーブル情報配列

                    XmlDocument xdoc = LoadDecryptedXml(xmlfile);
                    XmlNodeList xnlView = xdoc.SelectNodes("//viewList/view");
                    int line = 0;
                    foreach (XmlNode xn in xnlView)
                    {
                        ViewTableInfo vti = new ViewTableInfo();
                        vti.No = line;
                        vti.KeyName = xn.Attributes["key_name"].Value.Trim();
                        vti.SqlCd = xn.Attributes["sqlcd"].Value.Trim();
                        vti.TableName = xn.Attributes["name"].Value.Trim();
                        vti.DispName = xn.Attributes["disp_name"].Value.Trim();
                        vti.Desc = xn.Attributes["desc"].Value.Trim();
                        vti.Mode = xn.Attributes["Mode"].Value.Trim();
                        vti.IsInit = xn.Attributes["is_init"].Value.Trim() == "1";
                        vti.OnceFlg = xn.Attributes["once_flg"].Value.Trim() == "1";
                        vti.IsEffect = xn.Attributes["is_effect"].Value.Trim() == "1";
                        vti.UpRange = xn.Attributes["up_range"].Value.Trim();
                        vti.UpdateInterval = xn.Attributes["updateInterval"].Value.Trim();
                        vti.Time = xn.Attributes["time"].Value.Trim();
                        vti.Week = xn.Attributes["week"].Value.Trim();
                        vti.LastStartDate = DateTime.TryParseExact(xn.Attributes["last_start_date"].Value.Trim(), "yyyyMMddHHmmss", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedStartDate) ? parsedStartDate : DateTime.MinValue;
                        vti.LastEndDate = DateTime.TryParseExact(xn.Attributes["last_end_date"].Value.Trim(), "yyyyMMddHHmmss", CultureInfo.InvariantCulture, DateTimeStyles.None, out DateTime parsedEndDate) ? parsedEndDate : DateTime.MinValue;
                        vti.Sqlfile = xn.Attributes["sqlfile"].Value.Trim();

                        line++;

                        //同期モードを判定
                        string SyncMode = DetermineProcessingType(vti, line, XMLG_FILE_NAME);
                        if ("ERROR".Equals(SyncMode))
                        {
                            continue;
                        }

                        // テーブル名は設定するか
                        if (String.IsNullOrEmpty(vti.TableName))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " nameが設定されていません。キー名：" + vti.KeyName + " [" + "name:" + vti.TableName + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        // キー名重複判定
                        foreach (ViewTableInfo viewTableInfo in FNSiViewSyncSetting.m_viewTableInfoListAll)
                        {
                            if (viewTableInfo.KeyName == vti.KeyName)
                            {
                                // ログ記録：設定無効
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " key_nameが重複しています。キー名：" + vti.KeyName + " [" + "name:" + vti.KeyName + "]");
                                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                                continue;
                            }
                        }

                        // SqlCdは設定するか
                        if (String.IsNullOrEmpty(vti.SqlCd))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " SqlCdが設定されていません。キー名：" + vti.KeyName + "  [" + "SqlCd:" + vti.SqlCd + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        // モードが正しく設定されているかどうかを確認
                        if (!int.TryParse(vti.Mode, out int modeValue) || (modeValue != Mode.FULL_ITEM && modeValue != Mode.ACCUMULATION))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " モードは1か0を設定してください。キー名：" + vti.KeyName + " [" + GetEntityToString(vti) + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        //is_init
                        if (!(xn.Attributes["is_init"].Value.Trim() == "1" || xn.Attributes["is_init"].Value.Trim() == "0"))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " is_initは1か0を設定してください。キー名：" + vti.KeyName + "  [" + "is_init:" + xn.Attributes["is_init"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        int resultTryParse;
                        // past_range_totalの必須
                        if (!int.TryParse(xn.Attributes["past_range_total"].Value.Trim(), out resultTryParse) && modeValue == Mode.ACCUMULATION)
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " past_range_totalは数値を設定してください。キー名：" + vti.KeyName + "  [" + "past_range_total:" + xn.Attributes["past_range_total"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        vti.PastRangeTotal = resultTryParse;

                        //future_range_total
                        if (!int.TryParse(xn.Attributes["future_range_total"].Value.Trim(), out resultTryParse) && modeValue == Mode.ACCUMULATION)
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " future_range_totalは数値を設定してください。キー名：" + vti.KeyName + "  [" + "future_range_total:" + xn.Attributes["future_range_total"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        vti.FutureRangeTotal = resultTryParse;

                        //keep_old_limit
                        if (!int.TryParse(xn.Attributes["keep_old_limit"].Value.Trim(), out resultTryParse) && modeValue == Mode.ACCUMULATION)
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " keep_old_limitは数値を設定してください。キー名：" + vti.KeyName + "  [" + "keep_old_limit:" + xn.Attributes["keep_old_limit"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        vti.KeepOldLimit = resultTryParse;

                        //keep_new_limit
                        if (!int.TryParse(xn.Attributes["keep_new_limit"].Value.Trim(), out resultTryParse) && modeValue == Mode.ACCUMULATION)
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " keep_new_limitは数値を設定してください。キー名：" + vti.KeyName + "  [" + "keep_new_limit:" + xn.Attributes["keep_new_limit"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        vti.KeepNewLimit = resultTryParse;

                        //exec_interval
                        if (!IsPositiveInteger(xn.Attributes["exec_interval"].Value.Trim()))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " exec_intervalは正の数値を設定してください。キー名：" + vti.KeyName + "  [" + "exec_interval:" + xn.Attributes["exec_interval"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        vti.ExecInterval = int.Parse(xn.Attributes["exec_interval"].Value.Trim());

                        // up_rangeの必須
                        if (!IsPositiveInteger(xn.Attributes["up_range"].Value.Trim()) && ((modeValue == Mode.ACCUMULATION) || (modeValue == Mode.FULL_ITEM && !String.IsNullOrEmpty(xn.Attributes["sqlfile"].Value.Trim()))))
                        {
                            // ログ記録：設定無効0
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " up_rangeは正の数値を設定してください。キー名：" + vti.KeyName + "  [" + "up_range:" + xn.Attributes["up_range"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        //once_flg
                        if (!(xn.Attributes["once_flg"].Value.Trim() == "1" || xn.Attributes["once_flg"].Value.Trim() == "0"))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " once_flgは1か0を設定してください。キー名：" + vti.KeyName + "  [" + "once_flg:" + xn.Attributes["once_flg"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        //is_effect
                        if (!(xn.Attributes["is_effect"].Value.Trim() == "1" || xn.Attributes["is_effect"].Value.Trim() == "0"))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " is_effectは1か0を設定してください。キー名：" + vti.KeyName + "  [" + "is_effect:" + xn.Attributes["is_effect"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        //updateInterval
                        if (!String.IsNullOrEmpty(xn.Attributes["updateInterval"].Value.Trim()) && !IsPositiveInteger(xn.Attributes["updateInterval"].Value.Trim()))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " updateIntervalは正の数値を設定してください。キー名：" + vti.KeyName + "  [" + "updateInterval:" + xn.Attributes["updateInterval"].Value.Trim() + "]");
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }
                        //time
                        if (String.IsNullOrEmpty(xn.Attributes["time"].Value.Trim()) && String.IsNullOrEmpty(xn.Attributes["updateInterval"].Value.Trim()))
                        {
                            String[] TimeArray = Regex.Split(vti.Time, ",");
                            for (int j = 0; j < TimeArray.Length; j++)
                            {
                                if (!Regex.IsMatch(TimeArray[j], @"\d\d:\d\d"))
                                {
                                    // ログ記録：設定無効
                                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " timeは時刻を設定してください。キー名：" + vti.KeyName + "  [" + "time:" + xn.Attributes["time"].Value.Trim() + "]");
                                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                                    continue;
                                }

                            }
                        }
                        //week
                        if (String.IsNullOrEmpty(xn.Attributes["week"].Value.Trim()) && String.IsNullOrEmpty(xn.Attributes["updateInterval"].Value.Trim()))
                        {
                            String[] WeekArray = Regex.Split(vti.Week, ",");
                            for (int i = 0; i < WeekArray.Length; i++)
                            {
                                if (!int.TryParse(WeekArray[i], out resultTryParse))
                                {
                                    // ログ記録：設定無効
                                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " weekは数値を設定してください。キー名：" + vti.KeyName + "  [" + "week:" + WeekArray[i] + "]");
                                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                                    continue;
                                }

                            }
                        }

                        // TODO: SQL名check方法を確認
                        // XMLの設定が有効なデータの場合、関連SQLが有りか
                        String insSqlFile = sqlFolder + vti.KeyName + "_insert.sql";
                        if (!File.Exists(insSqlFile))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " 関連Insert SQLファイル[" + vti.KeyName + "_insert.sql" + "]が無し。キー名：" + vti.KeyName);
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        //String selSqlFile = sqlFolder + vti.KeyName + "_select.sql";
                        //if (!File.Exists(selSqlFile))
                        //{
                        // ログ記録：設定無効
                        //    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " 関連Select SQLファイル[" + vti.TableName + "_select.sql" + "]が無し。キー名：" + vti.KeyName);
                        //    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                        //    continue;
                        //}

                        // String updSqlFile = sqlFolder + vti.KeyName + "_update.sql";
                        // if (!File.Exists(updSqlFile))
                        // {
                        // ログ記録：設定無効
                        //    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " 関連Update SQLファイル[" + vti.TableName + "_update.sql" + "]が無し。キー名：" + vti.KeyName);
                        //    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                        //    continue;
                        // }

                        String delSqlFile = sqlFolder + vti.KeyName + "_delete.sql";
                        if (!File.Exists(delSqlFile))
                        {
                            // ログ記録：設定無効
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " 関連Delete SQLファイル[" + vti.KeyName + "_delete.sql" + "]が無し。キー名：" + vti.KeyName);
                            LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：設定エラー, result={vti.KeyName}");
                            continue;
                        }

                        FNSiViewSyncSetting.m_viewTableInfoListAll.Add(vti);

                        // xml読み込みます
                        if ("Interval".Equals(SyncMode))
                        {
                            FNSiViewSyncSetting.m_intervalViewTableInfoList.Add(vti);
                        }
                        else if ("TimeAndWeek".Equals(SyncMode))
                        {
                            FNSiViewSyncSetting.m_fixViewTableInfoList.Add(vti);
                        }
                    }
                    break; // 成功した場合はループを抜ける
                }
                catch (Exception ex)
                {
                    if (attempt == retryCount - 1)
                    {
                        throw ex;
                    }
                    else
                    {
                        Thread.Sleep(retryInterval);
                    }
                }
            }
        }

        public static Dictionary<string, string> GetViewSyncAttributes(string XMLG_FILE_NAME, string keyName, string[] AttributeNames)
        {
            int retryCount = FNSiViewSyncSetting.XMLRetryCount;
            int retryInterval = FNSiViewSyncSetting.XMLRetryInterval;
            Dictionary<string, string> attributeValues = new Dictionary<string, string>();

            for (int attempt = 0; attempt < retryCount; attempt++)
            {
                try
                {
                    // SQL設定ファイルフォルダ
                    string strFolder = AppDomain.CurrentDomain.BaseDirectory;
                    string xmlfile = strFolder + (strFolder.EndsWith("\\") ? "" : "\\") + XMLG_FILE_NAME;

                    // テーブル情報取得(XMLより)
                    XmlDocument xdoc = LoadDecryptedXml(xmlfile);
                    XmlNodeList xnlView = xdoc.SelectNodes("//viewList/view");
                    int line = 0;

                    foreach (XmlNode xn in xnlView)
                    {
                        if (xn.Attributes["key_name"].Value.Trim() == keyName)
                        {
                            foreach (string attributeName in AttributeNames)
                            {
                                if (attributeName == "no")
                                {
                                    attributeValues["no"] = line.ToString();
                                }
                                else if (xn.Attributes[attributeName] != null)
                                {
                                    attributeValues[attributeName] = xn.Attributes[attributeName].Value.Trim();
                                }
                            }
                            return attributeValues; // 一致するキーが見つかったら返却
                        }
                        line++;
                    }
                    break; // 成功した場合はループを抜ける
                }
                catch (Exception ex)
                {
                    if (attempt == retryCount - 1)
                    {
                        throw ex;
                    }
                    else
                    {
                        Thread.Sleep(retryInterval);
                    }
                }
            }
            return attributeValues; // 一致するキーが見つからなかった場合は空の辞書を返却
        }

        private static string DetermineProcessingType(ViewTableInfo vti, int line, string XMLG_FILE_NAME)
        {
            // updateIntervalが設定されているかチェック
            bool isUpdateIntervalSet = !string.IsNullOrWhiteSpace(vti.UpdateInterval);

            // timeとweekが設定されているかチェック
            bool isTimeAndWeekSet = !string.IsNullOrWhiteSpace(vti.Time) && !string.IsNullOrWhiteSpace(vti.Week);

            if (isUpdateIntervalSet && isTimeAndWeekSet)
            {
                // updateIntervalとtime, weekが共に設定されている場合はログ記録：設定無効
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " updateIntervalとtime, weekは同時に設定できません。テーブル名：" + vti.TableName + " [" + GetEntityToString(vti) + "]");
            }
            else if (isUpdateIntervalSet)
            {
                return "Interval";
            }
            else if (isTimeAndWeekSet)
            {
                return "TimeAndWeek";
            }
            else
            {
                // どちらも設定されていない場合はログ記録：設定無効
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "[" + XMLG_FILE_NAME + "] Line:" + String.Format("{0:D2}", line) + " 周期設定、定時設定どちらも設定されていません。テーブル名：" + vti.TableName + " [" + GetEntityToString(vti) + "]");
            }
            return "ERROR";
        }

        /// <summary>
        /// 反射によりクラスを文字列に変換します
        /// </summary>
        /// <param name="t">クラス</param>
        /// <returns>文字列</returns>
        public static string GetEntityToString(ViewTableInfo t)
        {
            System.Text.StringBuilder sb = new StringBuilder();
            Type type = t.GetType();
            System.Reflection.PropertyInfo[] propertyInfos = type.GetProperties();
            for (int i = 0; i < propertyInfos.Length; i++)
            {
                sb.Append(propertyInfos[i].Name + ":" + propertyInfos[i].GetValue(t, null) + ",");
            }
            return sb.ToString().TrimEnd(new char[] { ',' });
        }

        /// <summary>
        /// 文字列が0以上の数値か判定
        /// </summary>
        private static bool IsPositiveInteger(string value)
        {
            if (int.TryParse(value, out int result))
            {
                return result >= 0;
            }
            return false;
        }

        public static List<string> GetSplitAllItemModeData(ViewTableInfo viewTableInfo)
        {
            // コネクション
            ODBCHelper connection = new ODBCHelper(FNSiViewSyncSetting.ConnectionString);
            try
            {
                string sql = CommonUtil.GetSqlByName(viewTableInfo.Sqlfile);
                DataTable dataTable = connection.Select(sql);
                return (List<string>)DataTableUtils.GetSelectedColumnsPerRow(dataTable, new int[] { 0 });
            }
            catch (Exception ex)
            {
                // ログ記録
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=500, message=VIEW要求部エラー:{ex.Message}, result={viewTableInfo.TableName}");
                return null;
            }
        }

        public static void EndProcessing(String keyName, String jobKeyName)
        {
            FNSiViewSyncSetting.JobStatusList[jobKeyName].ViewSyncCntStatus = SyncCntStatus.LAST_END;
            XmlService.UpdateViewXmlTableLastEndDateByName(keyName);
        }


        private static readonly byte[] AesKey = Convert.FromBase64String("l/OJBBphFnzi7RXvAQZnhG4sD8YDLXVP3xPHP0ow5D4=");
        /// <summary>
        /// XML複合
        /// </summary>
        public static XmlDocument LoadDecryptedXml(string xmlPath)
        {
            string text = File.ReadAllText(xmlPath, Encoding.UTF8);
            if (text.Length > 0 && text[0] == '<')
            {
                XmlDocument xmlDocument = new XmlDocument();
                xmlDocument.LoadXml(text);
                return xmlDocument;
            }
            byte[] array = Convert.FromBase64String(text);
            byte[] array2;
            using (AesManaged aesManaged = new AesManaged())
            {
                aesManaged.Key = CommonUtil.AesKey;
                aesManaged.IV = new byte[16];
                aesManaged.Mode = CipherMode.CBC;
                aesManaged.Padding = PaddingMode.PKCS7;
                using (MemoryStream memoryStream = new MemoryStream())
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, aesManaged.CreateDecryptor(), CryptoStreamMode.Write))
                    {
                        cryptoStream.Write(array, 0, array.Length);
                        cryptoStream.FlushFinalBlock();
                        array2 = memoryStream.ToArray();
                    }
                }
            }
            XmlDocument xmlDocument2 = new XmlDocument();
            xmlDocument2.LoadXml(Encoding.UTF8.GetString(array2));
            return xmlDocument2;
        }

        /// <summary>
        /// XML暗号
        /// </summary>
        public static bool SaveEncrypted(XmlDocument xdoc, string xmlfile)
        {
            string outerXml = xdoc.OuterXml;
            byte[] bytes = Encoding.UTF8.GetBytes(outerXml);
            byte[] array;
            using (AesManaged aesManaged = new AesManaged())
            {
                aesManaged.Key = CommonUtil.AesKey;
                aesManaged.IV = new byte[16];
                aesManaged.Mode = CipherMode.CBC;
                aesManaged.Padding = PaddingMode.PKCS7;
                using (MemoryStream memoryStream = new MemoryStream())
                {
                    using (CryptoStream cryptoStream = new CryptoStream(memoryStream, aesManaged.CreateEncryptor(), CryptoStreamMode.Write))
                    {
                        cryptoStream.Write(bytes, 0, bytes.Length);
                        cryptoStream.FlushFinalBlock();
                        array = memoryStream.ToArray();
                    }
                }
            }
            string text = xmlfile + ".tmp";
            string text2 = Convert.ToBase64String(array);
            File.WriteAllText(text, text2, new UTF8Encoding(false));
            File.Replace(text, xmlfile, null);
            return true;
        }

    }
}
