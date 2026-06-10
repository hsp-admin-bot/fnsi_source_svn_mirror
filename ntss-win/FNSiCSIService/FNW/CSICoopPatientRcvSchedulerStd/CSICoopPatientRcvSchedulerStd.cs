///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：患者情報連携定期イベント発行
// ファイル名：CSICoopPatientRcvSchedulerStd.cs
// 説明      ：1日1度、指定時刻に患者情報連携用プラグイン(別モジュール)へ
//             患者取込依頼イベントを発行する。
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/11/18	飛田隆太			新規作成
//  2015/04/09  中村圭之介          Redmine#4251対応
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Xml;
using System.Text;
using System.Threading;
using System.Reflection;
using System.Collections;
using System.Collections.Generic;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using jp.co.nikkiso.fn3.Cooperation.CSICoop;


namespace CSICoopPatientRcvSchedulerStd
{
    // 2015/04/03 中村 Redmine#4251対応 Start
    public class PatInfo
    {
        private string m_strDispPatid;
        /// <summary>
        /// 表示用患者ID
        /// </summary>
        public string DispPatid
        {
            get { return m_strDispPatid; }
            set { m_strDispPatid = value; }
        }

        private string m_strPatid;
        /// <summary>
        /// 患者ID
        /// </summary>
        public string Patid
        {
            get { return m_strPatid; }
            set { m_strPatid = value; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public PatInfo()
        {
            m_strDispPatid = string.Empty;
            m_strPatid = string.Empty;
        }
    }
    // 2015/04/03 中村 Redmine#4251対応 End

    public class CSICoopPatientRcvSchedulerStd : Fn3ComPlugIn
    {
        #region メンバ定義
        /// <summary>
        /// 定期更新タイマ
        /// </summary>
        private System.Timers.Timer tmrUpdateTimer;

        /// <summary>
        /// 定期更新時刻
        /// </summary>
        private String UpdateTime;

        /// <summary>
        /// イベント通知先DLL名
        /// </summary>
        private String SendToDLLName;

        /// <summary>
        /// 定期更新中フラグ
        /// </summary>
        private bool isUpdating;

        /// <summary>
        /// 停止要求フラグ
        /// </summary>
        private bool isStopRequest;

        /// <summary>
        /// 個別クエリID定義
        /// 表示用患者IDリスト取得クエリ
        /// </summary>
        private const String ORG_QUERY_ID_GET_PATIENT_LIST = "00001";

        // 2015/04/06 中村 Redmine#4251対応 Start
        /// <summary>
        /// 個別クエリID定義
        /// 系列施設モード取得クエリ
        /// </summary>
        private const String ORG_QUERY_ID_GET_SERIES_MODE = "00002";

        /// <summary>
        /// 個別クエリID定義
        /// 主所属の系列施設コード取得クエリ
        /// </summary>
        private const String ORG_QUERY_ID_GET_SERIES_CD = "00003";

        /// <summary>
        /// 個別クエリID定義
        /// 系列施設対応ＤＢかどうかのチェッククエリ
        /// </summary>
        private const String ORG_QUERY_ID_SERIES_FACILITY = "00004";
        // 2015/04/06 中村 Redmine#4251対応 End

        /// <summary>
        /// 個別クエリ条件定義
        /// 表示用患者IDリスト取得クエリのWHERE句値
        /// </summary>
        private const String ORG_QUERY_COND_GET_PATIENT_LIST = "<rootNode><VALUE1>0</VALUE1></rootNode>";

        /// <summary>
        /// イベント区分定義
        /// その他
        /// </summary>
        private const String EVENT_CLASS_REQUEST = "4";

        /// <summary>
        /// 系列施設モード
        /// true:系列施設モード、false:それ以外
        /// </summary>
        private bool IsSeriesMode;

        #endregion

        #region メソッド
        /// <summary>
        /// 初期化処理
        /// 定期更新タイマ生成、設定値取得を行う
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 定期更新タイマ生成
            this.tmrUpdateTimer = new System.Timers.Timer();
            this.tmrUpdateTimer.AutoReset = false;
            this.tmrUpdateTimer.Elapsed += new System.Timers.ElapsedEventHandler(this.OnUpdating);

            // 設定値取得(定期更新時刻)
            Fn3ReturnCode retCode = this.GetIniSetting();
            if (retCode.IsError)
            {
                // [トレースログ]設定値取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_INITIALIZE);

                // [エラー]初期化失敗
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_INITIALIZE;
            }

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());

            // 初期化成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 開始処理
        /// 定期更新タイマ設定を行う
        /// </summary>
        /// <returns>成功/失敗</returns>
        protected override Fn3ReturnCode Start()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 停止要求フラグOFF
            this.isStopRequest = false;

            // 2015/04/06 中村 Redmine#4251対応 Start
            IsSeriesMode = false;
            string strOutXml = string.Empty;
            // 系列施設対応済みかどうかのチェック
            Fn3ReturnCode retCode = base.DBExecQuery(ORG_QUERY_ID_SERIES_FACILITY, "<rootNode />", ref strOutXml);
            if (retCode.IsSuccess)
            {
                XmlDocument xmlDoc = new XmlDocument();
                xmlDoc.LoadXml(strOutXml);

                string strCount = Fn3ComTool.GetXmlValue(xmlDoc.LastChild, "//rootNode/Table/TBLCOUNT");
                if (strCount.Equals("1"))
                {
                    // 系列施設モード設定(システム設定：ID=450)の取得
                    retCode = base.DBExecQuery(ORG_QUERY_ID_GET_SERIES_MODE, "<rootNode />", ref strOutXml);
                    if (retCode.IsSuccess)
                    {
                        xmlDoc = new XmlDocument();
                        xmlDoc.LoadXml(strOutXml);

                        string strSerieseMode = Fn3ComTool.GetXmlValue(xmlDoc.LastChild, "//rootNode/SYS_SYSTEM_DEFINE/VALUE");
                        if (strSerieseMode.Equals("1"))
                        {
                            // 系列施設モードの場合、trueを設定
                            IsSeriesMode = true;
                        }
                    }
                }
            }            
            // 2015/04/06 中村 Redmine#4251対応 End

            // 定期更新処理開始
            this.StartUpdateProcess();

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());

            // 開始処理成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 停止処理
        /// 定期更新タイマ停止処理を行い、定期更新処理中の場合は処理を途中で完了させる
        /// </summary>
        protected override void Stop()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 停止要求フラグON
            this.isStopRequest = true;

            // 定期更新処理・タイマ停止処理実施
            this.StopUpdateProcess();

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 解放処理
        /// 定期更新タイマを破棄する
        /// </summary>
        protected override void Release()
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 定期更新タイマ破棄
            this.tmrUpdateTimer.Dispose();

            // メソッド終了ログ
            base.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 定期更新処理開始
        /// 処理中フラグOFF、タイマ時刻設定、開始
        /// </summary>
        private void StartUpdateProcess()
        {
            // 定期更新中フラグOFF
            this.isUpdating = false;

            // 定期更新タイマ設定
            this.SetNextUpdateTime(this.UpdateTime);

            // 定期更新タイマ開始
            this.tmrUpdateTimer.Start();
        }

        /// <summary>
        /// 定期更新イベント発行処理停止
        /// タイマ停止、および処理中の場合は停止するまで待機
        /// </summary>
        private void StopUpdateProcess()
        {
            // 定期更新タイマ停止
            this.tmrUpdateTimer.Stop();

            // 定期更新中フラグにて判定
            while (this.isUpdating)
            {
                // 500msecスリープして定期更新処理停止を待つ
                Thread.Sleep(500);

                // [トレースログ]停止待ち
                base.DebugTraceOut(this.CreateTraceMessage("定期更新イベント発行処理を停止中です。"));
            }

            // [トレースログ]定期更新イベント発行停止完了
            base.DebugTraceOut(this.CreateTraceMessage("定期更新イベント発行処理を停止しました。"));
        }

        /// <summary>
        /// 定期更新イベント発行処理
        /// FNWに登録されている全患者の情報をMIRAIsより取得し、更新イベントを発行する
        /// </summary>
        /// <param name="sender">定期更新タイマ</param>
        /// <param name="e">イベント引数</param>
        private void OnUpdating(object sender, System.Timers.ElapsedEventArgs e)
        {
            // メソッド開始ログ
            base.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 定期更新中フラグON
            this.isUpdating = true;

            // 2015/04/06 中村 Redmine#4251対応
            // List<String> lstPatientList = new List<String>();
            List<PatInfo> lstPatientList = new List<PatInfo>();
            try
            {
                // FNW登録患者リスト取得
                Fn3ReturnCode retCodeGetList = this.GetUpdatePatientList(ref lstPatientList);
                if (retCodeGetList.IsError)
                {
                    // [トレースログ]患者リスト取得失敗
                    base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_REGIST_EVENT);
                    return;
                }

                // 全患者分のイベント発行
                // foreach (String strDispPatID in lstPatientList)
                foreach (PatInfo patInfo in lstPatientList)
                {
                    // 本体から停止要求が来ている場合
                    if (this.isStopRequest)
                    {
                        // 処理終了
                        break;
                    }

                    // 2015/04/06 中村 Redmine#4251対応 Start
                    //// キー情報生成
                    //Hashtable htbKeyInfo = new Hashtable();
                    //htbKeyInfo.Add("DISP_PATID", strDispPatID);

                    //// 患者情報取込イベント発行(対象DLL：設定値、イベント区分：依頼要求、キー情報：DISP_PATID、特定キー：DISP_PATID、メモ無し、非同期)
                    //Fn3ReturnCode retCodeRegistEvent = base.RegistEvent(this.SendToDLLName, EVENT_CLASS_REQUEST, htbKeyInfo, strDispPatID, "", false);
                    //if (retCodeRegistEvent.IsError || retCodeRegistEvent.IsException)
                    //{
                    //    // [トレースログ]イベント登録失敗(処理は継続)
                    //    base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_REGIST_EVENT, retCodeRegistEvent.Message);

                    //    // 失敗をアラーム通知
                    //    base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, null, null, "", 
                    //                   String.Format("{0}（患者ID：{1}）", CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_UPDATE.Message, strDispPatID));
                    //}
                    string strSeriesCd = string.Empty;
                    // 系列施設モードチェック
                    if (IsSeriesMode)
                    {
                        // 主所属の系列施設コードを取得
                        strSeriesCd = this.GetSerieseCd(patInfo.Patid);
                    }
                    if (string.IsNullOrEmpty(strSeriesCd))
                    {
                        // イベント登録（系列施設コードの指定なし）
                        // ※通信先系列施設コードでイベントが登録される
                        this.RegistEventManage(patInfo.DispPatid);
                    }
                    else
                    {
                        // イベント登録（系列施設コードの指定あり）
                        this.RegistEventManage(patInfo.DispPatid, strSeriesCd);
                    }
                    // 2015/04/06 中村 Redmine#4251対応 End
                }
            }
            finally
            {
                // 次回定期更新時刻設定
                this.SetNextUpdateTime(this.UpdateTime);

                // 定期更新中フラグOFF
                this.isUpdating = false;

                // メソッド終了ログ
                base.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }
        }

        /// <summary>
        /// 設定値取得＆チェック
        /// 定期更新時刻、イベント通知先DLL名を取得
        /// さらに取得値の形式チェックを実施
        /// </summary>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode GetIniSetting()
        {
            bool isNotExists = false;

            // 初期設定から定期更新時刻を取得
            Hashtable htbSettings = new Hashtable();
            Fn3ReturnCode retCode = base.GetInitialValue(CSICommonConst.SYS_DIV_UNIQUE,
                                                         CSICommonConst.SYS_SECT_PATIENTRCV,
                                                         ref htbSettings);

            // 取得に失敗した場合
            if (retCode.IsError || retCode.IsException)
            {
                // [トレースログ]初期設定取得失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS, retCode.Message);

                // [エラー]初期設定取得失敗
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS;
            }

            // 定期更新時刻存在チェック
            if (!htbSettings.Contains(CSICommonConst.SYS_KEY_UPDATE_TIME))
            { 
                // [トレースログ]定期更新時刻無し
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS, "定期更新時刻が存在しません。");

                isNotExists = true;
            }
            // イベント通知先DLL名存在チェック
            if (!htbSettings.Contains(CSICommonConst.SYS_KEY_SEND_TO_DLL_NAME))
            { 
                // [トレースログ]イベント通知先DLL名無し
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS, "イベント通知先DLL名称が存在しません。");

                isNotExists = true;
            }

            // 設定値が無い場合
            if (isNotExists)
            { 
                // [エラー]設定値無し
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS;
            }

            // 形式チェック
            String strUpdateTime = htbSettings[CSICommonConst.SYS_KEY_UPDATE_TIME].ToString();
            DateTime dtmScheTime;
            if (!DateTime.TryParse(strUpdateTime, out dtmScheTime))
            {
                // [トレースログ]時刻フォーマット不正
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS, 
                              String.Format("定期更新時刻のフォーマット[hh:mm形式]が不正です。 ({0})", strUpdateTime));

                // [エラー]時刻フォーマット不正
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_GET_SETTINGS;
            }

            // 取得値を保持
            this.UpdateTime = strUpdateTime;
            this.SendToDLLName = htbSettings[CSICommonConst.SYS_KEY_SEND_TO_DLL_NAME].ToString();

            // 設定値取得成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// 定期更新時刻設定
        /// タイマに次の定期更新時刻までのインターバルを設定
        /// 当日の時刻が過ぎている場合、翌日までのインターバルを設定する
        /// </summary>
        /// <param name="strScheduleTime">予定時刻(hh:mm形式)</param>
        private void SetNextUpdateTime(String strScheduleTime)
        {
            // 今日の更新時刻を算出
            DateTime dtmScheTime = DateTime.Parse(strScheduleTime);

            // 現在時刻と更新時刻の差を算出
            TimeSpan tsToday = dtmScheTime - DateTime.Now;

            // 更新時刻に達していない場合
            DateTime dtmUpdateDate;
            if (tsToday.TotalMilliseconds > 0)
            {
                // 更新時刻までの総ミリ秒を設定
                this.tmrUpdateTimer.Interval = tsToday.TotalMilliseconds;
                dtmUpdateDate = DateTime.Now + tsToday;
            }
            // 更新時刻を過ぎている場合
            else
            {
                // 明日の更新時刻までの総ミリ秒を設定
                TimeSpan tsTomorrow = dtmScheTime.AddDays(1) - DateTime.Now;
                this.tmrUpdateTimer.Interval = tsTomorrow.TotalMilliseconds;
                dtmUpdateDate = DateTime.Now + tsTomorrow;
            }

            // [トレースログ]定期更新時刻設定
            base.DebugTraceOut(this.CreateTraceMessage("患者情報定期更新時刻を設定しました。", dtmUpdateDate.ToString("予定時刻 yyyy/MM/dd HH:mm:ss")));
        }

        // 2015/04/06 中村 Redmine#4251対応
        ///// <summary>
        ///// 更新対象患者IDリスト取得
        ///// </summary>
        ///// <param name="htbPatIDList">患者IDリスト(表示用患者ID)</param>
        ///// <returns>成功/失敗</returns>
        //private Fn3ReturnCode GetUpdatePatientList(ref List<String> lstPatientList)
        /// <summary>
        /// 更新対象患者情報リスト取得
        /// </summary>
        /// <param name="lstPatientList">患者情報リスト</param>
        /// <returns>成功/失敗</returns>
        private Fn3ReturnCode GetUpdatePatientList(ref List<PatInfo> lstPatientList)
        {
            // 表示用患者ID取得用個別クエリ実施
            String strQueryResultXml = "";
            // 2012/07/30 中村 本日透析を予定している患者を取得 Chg Start
            // Fn3ReturnCode retCode = base.DBExecQuery(ORG_QUERY_ID_GET_PATIENT_LIST, ORG_QUERY_COND_GET_PATIENT_LIST, ref strQueryResultXml);
            Fn3ReturnCode retCode = base.DBExecQuery(ORG_QUERY_ID_GET_PATIENT_LIST, "<rootNode />", ref strQueryResultXml);
            // 2012/07/30 中村 本日透析を予定している患者を取得 Chg End
            if (retCode.IsError || retCode.IsException)
            {
                // [トレースログ]個別クエリ失敗
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_LIST, "更新対象患者取得用個別クエリが失敗しました。");

                // [エラー]個別クエリ失敗
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_LIST;
            }

            // 取得IDをリスト化
            XmlDocument xmlDocPatientList = new XmlDocument();
            try
            {
                xmlDocPatientList.LoadXml(strQueryResultXml);
                
                // 2015/04/06 中村 Redmine#4251対応 Start
                //// 2012/07/30 中村 本日透析を予定している患者を取得 Chg Start
                //// foreach (XmlNode nodeDispPatID in xmlDocPatientList.SelectNodes("//rootNode/Table/DISP_PATID"))
                //foreach (XmlNode nodeDispPatID in xmlDocPatientList.SelectNodes("//rootNode/PAT_BASIC_INFO/DISP_PATID"))
                //// 2012/07/30 中村 本日透析を予定している患者を取得 Chg End
                //{
                //    // リストに表示用患者ID追加
                //    lstPatientList.Add(nodeDispPatID.InnerText);
                //}
                foreach (XmlNode xmlPatBasicInfo in xmlDocPatientList.SelectNodes("//rootNode/PAT_BASIC_INFO"))
                {
                    // 表示用患者IDの取得
                    string strDispPatID = Fn3ComTool.GetXmlValue(xmlPatBasicInfo, "DISP_PATID");
                    // 患者IDの取得
                    string strPatID = Fn3ComTool.GetXmlValue(xmlPatBasicInfo, "PATID");
                    if (string.IsNullOrEmpty(strDispPatID) || string.IsNullOrEmpty(strPatID))
                    {
                        continue;
                    }
                    PatInfo patInfo = new PatInfo();
                    patInfo.DispPatid = strDispPatID;
                    patInfo.Patid = strPatID;
                    // 患者リストに追加
                    lstPatientList.Add(patInfo);
                }
                // 2015/04/06 中村 Redmine#4251対応 End
            }
            catch (Exception ex)
            { 
                // [トレースログ]患者ID取り出し失敗
                base.ErrorTraceOut(CSIReturnCode.FTL_PATIENT_RCV_SCHEDULER_PATIENT_LIST, ex);

                // [エラー]患者ID取り出し失敗
                return CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_LIST;
            }

            // 患者IDリスト取得成功
            return CSIReturnCode.Success;
        }

        /// <summary>
        /// トレースメッセージ生成
        /// [～プラグイン]：メインメッセージ (補足情報)の形式でメッセージ生成
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <returns>トレースメッセージ</returns>
        private String CreateTraceMessage(String strMainMessage)
        {
            return CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_DBG + strMainMessage;
        }

        /// <summary>
        /// トレースメッセージ生成
        /// [～プラグイン]：メインメッセージ (補足情報)の形式でメッセージ生成
        /// </summary>
        /// <param name="strMainMessage">～しました。などの主文</param>
        /// <param name="strSubInfo">主文に対する補足情報(不正な設定値、値など)</param>
        /// <returns>トレースメッセージ</returns>
        private String CreateTraceMessage(String strMainMessage, String strSubInfo)
        {
            return CSICommonConst.MODULE_MNAME_PRS + CSICommonConst.LOGTYPE_DBG + strMainMessage + "(" + strSubInfo + ")";
        }

        // 2015/04/06 中村 Redmine#4251対応 Start
        /// <summary>
        /// 主所属の系列施設コード取得
        /// </summary>
        /// <param name="strPatId">患者ID</param>
        /// <returns>系列施設コード</returns>
        private string GetSerieseCd(string strPatId)
        {
            string strInXml = string.Format("<rootNode><PATID>{0}</PATID></rootNode>", strPatId);
            string strOutXml = string.Empty;
            Fn3ReturnCode retCode = base.DBExecQuery(ORG_QUERY_ID_GET_SERIES_CD, strInXml, ref strOutXml);
            if (retCode.IsError || retCode.IsException)
            {
                return string.Empty;
            }

            XmlDocument xmlDoc = new XmlDocument();
            xmlDoc.LoadXml(strOutXml);
            return Fn3ComTool.GetXmlValue(xmlDoc.LastChild, "//rootNode/SYS_PAT_SERIES_FACILITY/SERIES_CD");
        }

        /// <summary>
        /// イベント管理テーブルへのイベント登録
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID</param>
        private void RegistEventManage(string strDispPatID)
        {
            // キー情報生成
            Hashtable htbKeyInfo = new Hashtable();
            htbKeyInfo.Add("DISP_PATID", strDispPatID);

            // 患者情報取込イベント発行(対象DLL：設定値、イベント区分：依頼要求、キー情報：DISP_PATID、特定キー：DISP_PATID、メモ無し、非同期)
            Fn3ReturnCode retCodeRegistEvent = base.RegistEvent(this.SendToDLLName, EVENT_CLASS_REQUEST, htbKeyInfo, strDispPatID, "", false);
            if (retCodeRegistEvent.IsError || retCodeRegistEvent.IsException)
            {
                // [トレースログ]イベント登録失敗(処理は継続)
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_REGIST_EVENT, retCodeRegistEvent.Message);

                // 失敗をアラーム通知
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, null, null, "",
                               String.Format("{0}（患者ID：{1}）", CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_UPDATE.Message, strDispPatID));
            }
        }

        /// <summary>
        /// イベント管理テーブルへのイベント登録（系列施設コード指定有り）
        /// </summary>
        /// <param name="strDispPatID">表示用患者ID</param>
        /// <param name="strSeriesCd">系列施設コード</param>
        private void RegistEventManage(string strDispPatID, string strSeriesCd)
        {
            // キー情報生成
            Hashtable htbKeyInfo = new Hashtable();
            htbKeyInfo.Add("DISP_PATID", strDispPatID);

            // 患者情報取込イベント発行(対象DLL：設定値、イベント区分：依頼要求、キー情報：DISP_PATID、特定キー：DISP_PATID、メモ無し、非同期)
            Fn3ReturnCode retCodeRegistEvent = base.RegistEvent(this.SendToDLLName, EVENT_CLASS_REQUEST, htbKeyInfo, strDispPatID, "", false, strSeriesCd);
            if (retCodeRegistEvent.IsError || retCodeRegistEvent.IsException)
            {
                // [トレースログ]イベント登録失敗(処理は継続)
                base.TraceOut(CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_REGIST_EVENT, retCodeRegistEvent.Message);

                // 失敗をアラーム通知
                base.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, null, null, "",
                               String.Format("{0}（患者ID：{1}）", CSIReturnCode.ERR_PATIENT_RCV_SCHEDULER_PATIENT_UPDATE.Message, strDispPatID));
            }
        }
        // 2015/04/06 中村 Redmine#4251対応 End

        #endregion
    }
}
