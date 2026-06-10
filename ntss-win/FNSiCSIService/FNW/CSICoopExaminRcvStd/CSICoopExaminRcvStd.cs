///////////////////////////////////////////////////////////////////////////////
// 
// システム名 ： FutureNet Ⅲ
// 
// 機  能  名 ： 検査結果情報の受信機能
// 
// ファイル名 ： CSICoopExaminRcvStd.cs
// 
// 説      明 ： 日に一度、設定時刻にMIRAIsデータベースから検査結果を取得し、
//               FutureNetデータベースへ受信内容を更新します。
// 
// Copyright(C) 2008 NIKKISO CO., LTD. All Right Reserved
// 
// ＜更新履歴＞
// 
//   日付        担当        内容
//   ----------  ----------  ------------------------------------------------
//   2009/12/07  森山俊介    新規作成
//   2010/03/10  飛田隆太    大幅改修、取り込み仕様を大きく変更
// 
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Data;
using System.Text;
using System.Reflection;
using System.Timers;
using System.Data.OracleClient;
using System.Collections;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;

namespace jp.co.nikkiso.fn3.Cooperation.CSICoop
{
    /// <summary>
    /// 検体検査結果情報の受信連携を行います。
    /// </summary>
    public partial class CSICoopExaminRcvStd : Fn3ComPlugIn
    {

        #region プライベート変数定義

        /// <summary>
        /// 連携実行タイマー
        /// </summary>
        private Timer timerExaminRcvExecute;

        // 2013/08/22 中村 １日複数回取込対応 Chg Start
        ///// <summary>
        ///// 定期取込実施時刻
        ///// </summary>
        //private DateTime dtExecuteTime;
        private List<DateTime> listExecuteTime;
        // 2013/08/22 中村 １日複数回取込対応 Chg End

        /// <summary>
        /// MIRAISデータベース接続用データソース
        /// </summary>
        private string miraisDataSource;

        /// <summary>
        /// MIRAISデータベース接続用ユーザー名
        /// </summary>
        private string miraisUserName;

        /// <summary>
        /// MIRAISデータベース接続用パスワード
        /// </summary>
        private string miraisPassword;

        /// <summary>
        /// コメント区切り文字
        /// </summary>
        private string strCommentSeparate;

        /// <summary>
        /// タイマーイベント処理中フラグ
        /// </summary>
        private static bool bTimerIsAlive;

        #endregion


        #region コンストラクタ

        /// <summary>
        /// <see cref="CSICoopExaminRcvStd"/>クラスの新しいインスタンスを初期化します。
        /// </summary>
        public CSICoopExaminRcvStd()
            : base()
        {
            // 初期化
            this.timerExaminRcvExecute = null;
            // 2013/08/22 中村 １日複数回取込対応 Chg Start
            // this.dtExecuteTime = DateTime.Today;
            this.listExecuteTime = null;
            // 2013/08/22 中村 １日複数回取込対応 Chg End
            this.miraisDataSource = string.Empty;
            this.miraisUserName = string.Empty;
            this.miraisPassword = string.Empty;
            this.strCommentSeparate = string.Empty;
            bTimerIsAlive = false;
        }

        #endregion


        #region オーバーライドメソッド

        /// <summary>
        /// 初期化処理を実行します。
        /// </summary>
        /// <returns><see cref="Fn3ReturnCode"/> 値の 1 つ。</returns>
        /// <remarks>
        /// サービス起動時に呼び出されます。
        /// </remarks>
        protected override Fn3ReturnCode Initialize()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // ..

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());

            return Fn3ReturnCode.Success;
        }

        /// <summary>
        /// 連携処理を開始します。
        /// </summary>
        /// <returns><see cref="Fn3ReturnCode"/> 値の 1 つ。</returns>
        /// <remarks>
        /// サービス起動時、サービス一時停止再開時、個別停止再開時に呼び出されます。
        /// </remarks>
        protected override Fn3ReturnCode Start()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            Fn3ReturnCode retCode;

            try
            {
                // -------------------------------------
                // 連携設定情報の取得
                // -------------------------------------

                // 定期取込実施時刻の取得
                string strTmpValue = string.Empty;
                retCode = this.GetInitialValue(
                    CSICommonConst.SYS_DIV_UNIQUE, 
                    CSICommonConst.SYS_SECT_EXAMINRCV, 
                    CSICommonConst.SYS_KEY_EXECUTE_TIME, 
                    ref strTmpValue);
                if (retCode.IsError || retCode.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_EXAMINRCV,
                        CSICommonConst.SYS_KEY_EXECUTE_TIME,
                        strTmpValue));
                    return retCode;
                }
                else if (strTmpValue.Trim().Equals(""))
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, 
                        string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_EXAMINRCV,
                        CSICommonConst.SYS_KEY_EXECUTE_TIME,
                        strTmpValue));
                    return retCode;
                }

                // 2013/08/22 中村 １日複数回取込対応 Chg Start
                //if (!DateTime.TryParse(
                //    string.Format("{0} {1}", DateTime.Now.ToString("yyyy/MM/dd"), strTmpValue),
                //    out this.dtExecuteTime))
                //{
                //    // 時刻として認識できない
                //    retCode = CSIReturnCode.ERR_EXAMIN_RCV_BADEXECUTETIME;
                //    this.TraceOut(retCode, string.Format(
                //        CSICommonConst.SYS_LOG_FORMAT,
                //        CSICommonConst.SYS_SECT_EXAMINRCV,
                //        CSICommonConst.SYS_KEY_EXECUTE_TIME,
                //        strTmpValue));
                //    return retCode;
                //}
                this.listExecuteTime = new List<DateTime>();
                string[] strArrayData = strTmpValue.Split(',');
                foreach (string strData in strArrayData)
                {
                    if (strData.Equals("")) continue;

                    DateTime dtTmpValue;
                    if (!DateTime.TryParse(
                        string.Format("{0} {1}", DateTime.Now.ToString("yyyy/MM/dd"), strData),
                        out dtTmpValue))
                    {
                        // 時刻として認識できない
                        retCode = CSIReturnCode.ERR_EXAMIN_RCV_BADEXECUTETIME;
                        this.TraceOut(retCode, string.Format(
                            CSICommonConst.SYS_LOG_FORMAT,
                            CSICommonConst.SYS_SECT_EXAMINRCV,
                            CSICommonConst.SYS_KEY_EXECUTE_TIME,
                            strTmpValue));
                        return retCode;
                    }
                    this.listExecuteTime.Add(dtTmpValue);
                }
                // 2013/08/22 中村 １日複数回取込対応 Chg End

                // MIRAISデータベース接続ネットサービス名の取得
                retCode = this.GetInitialValue(
                    CSICommonConst.SYS_DIV_UNIQUE, 
                    CSICommonConst.SYS_SECT_COMMON, 
                    CSICommonConst.SYS_KEY_DB_NETSERVICE, 
                    ref this.miraisDataSource);
                if (retCode.IsError || retCode.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_NETSERVICE,
                        this.miraisDataSource));
                    return retCode;
                }
                else if (this.miraisDataSource.Trim().Equals(""))
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode,
                        string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_NETSERVICE,
                        this.miraisDataSource));
                    return retCode;
                }

                // MIRAISデータベース接続ユーザー名の取得
                retCode = this.GetInitialValue(
                    CSICommonConst.SYS_DIV_UNIQUE, 
                    CSICommonConst.SYS_SECT_COMMON, 
                    CSICommonConst.SYS_KEY_DB_USER, 
                    ref this.miraisUserName);
                if (retCode.IsError || retCode.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_USER,
                        this.miraisUserName));
                    return retCode;
                }
                else if (this.miraisUserName.Trim().Equals(""))
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode,
                        string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_USER,
                        this.miraisUserName));
                    return retCode;
                }

                // MIRAISデータベース接続パスワードの取得
                retCode = this.GetInitialValue(
                    CSICommonConst.SYS_DIV_UNIQUE, 
                    CSICommonConst.SYS_SECT_COMMON, 
                    CSICommonConst.SYS_KEY_DB_PASSWORD, 
                    ref this.miraisPassword);
                if (retCode.IsError || retCode.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_PASSWORD,
                        this.miraisPassword));
                    return retCode;
                }
                else if (this.miraisPassword.Trim().Equals(""))
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode,
                        string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_COMMON,
                        CSICommonConst.SYS_KEY_DB_PASSWORD,
                        this.miraisPassword));
                    return retCode;
                }

                // コメント区切り文字の取得
                retCode = this.GetInitialValue(
                    CSICommonConst.SYS_DIV_UNIQUE, 
                    CSICommonConst.SYS_SECT_EXAMINRCV,
                    CSICommonConst.SYS_KEY_COMMENT_SEPARATE,
                    ref this.strCommentSeparate);
                if (retCode.IsError || retCode.IsException)
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode, string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_EXAMINRCV,
                        CSICommonConst.SYS_KEY_COMMENT_SEPARATE,
                        this.strCommentSeparate));
                    return retCode;
                }
                else if (this.strCommentSeparate.Trim().Equals(""))
                {
                    retCode = CSIReturnCode.ERR_EXAMIN_RCV_GETINITIALVALUE;
                    this.TraceOut(retCode,
                        string.Format(
                        CSICommonConst.SYS_LOG_FORMAT,
                        CSICommonConst.SYS_SECT_EXAMINRCV,
                        CSICommonConst.SYS_KEY_COMMENT_SEPARATE,
                        this.strCommentSeparate));
                    return retCode;
                }

                //// -------------------------------------
                //// タイマーの設定
                //// -------------------------------------

                //// 定期取込実施時刻までの時間(ミリ秒)を計算
                //// 2013/08/22 中村 １日複数回取込対応 Chg Start
                //// double dblDueTime = this.GetMSecOfUntilSpecifiedTime(this.dtExecuteTime);
                //double dblDueTime = this.GetMSecOfUntilSpecifiedTime(this.listExecuteTime);
                //// 2013/08/22 中村 １日複数回取込対応 Chg End

                //// タイマーセット
                //this.timerExaminRcvExecute = new Timer();
                //this.timerExaminRcvExecute.Elapsed += new ElapsedEventHandler(ExaminRcvExecute);
                //this.timerExaminRcvExecute.Interval = dblDueTime;
                //this.timerExaminRcvExecute.AutoReset = false;
                //this.timerExaminRcvExecute.Start();
                
                retCode = Fn3ReturnCode.Success;
            }
            catch (Exception ex)
            {
                retCode = CSIReturnCode.FTL_EXAMIN_RCV_INITIALIZE;
                this.ErrorTraceOut(retCode, ex);
            }
            finally
            {
                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return retCode;
        }


        /// <summary>
        /// 連携終了処理を実行します。
        /// </summary>
        /// <remarks>
        /// サービス一時停止時、個別停止時、サービス停止時に呼び出されます。
        /// </remarks>
        protected override void Stop()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // イベント実行中の場合は処理完了を待つ
            while (true)
            {
                System.Threading.Thread.Sleep(100);
                if (!bTimerIsAlive)
                {
                    break;
                }
            }

            // タイマー停止
            if (this.timerExaminRcvExecute != null)
            {
                this.timerExaminRcvExecute.Enabled = false;
                this.timerExaminRcvExecute.Close();
                this.timerExaminRcvExecute.Dispose();
                this.timerExaminRcvExecute = null;
            }

            this.listExecuteTime = null;

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        /// <summary>
        /// 各種開放処理を実行します。
        /// </summary>
        /// <remarks>
        /// 個別停止時、サービス停止時(Stop()メソッドの後)に呼び出されます。
        /// </remarks>
        protected override void Release()
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            // 初期化
            // 2013/08/22 中村 １日複数回取込対応 Chg Start
            // this.dtExecuteTime = DateTime.Today;
            // 2013/08/22 中村 １日複数回取込対応 Chg End
            this.miraisDataSource = string.Empty;
            this.miraisUserName = string.Empty;
            this.miraisPassword = string.Empty;
            this.strCommentSeparate = string.Empty;

            // メソッド終了ログ
            this.MethodEndLogOut(MethodBase.GetCurrentMethod());
        }

        #endregion


        #region タイマーイベントハンドラ

        /// <summary>
        /// 検査結果情報の受信処理を実行します。
        /// </summary>
        /// <param name="sender">イベントのソース。</param>
        /// <param name="e">イベント データを格納している <see cref="ElapsedEventArgs"/> オブジェクト。</param>
        private void ExaminRcvExecute(object sender, ElapsedEventArgs e)
        {
            bTimerIsAlive = true;

            OracleConnection oraConnection = null;
            Fn3ReturnCode resCode;

            try
            {
                // メソッド開始ログ
                this.MethodStartLogOut(MethodBase.GetCurrentMethod());

                // タイマー一時停止
                this.timerExaminRcvExecute.Stop();

                // DB接続文字列の構築
                OracleConnectionStringBuilder oraConnectionStringBuilder = new OracleConnectionStringBuilder();
                oraConnectionStringBuilder.DataSource = this.miraisDataSource;
                oraConnectionStringBuilder.UserID = this.miraisUserName;
                oraConnectionStringBuilder.Password = this.miraisPassword;

                // -------------------------------------
                // MIRAISデータベースへの接続
                // -------------------------------------
                try
                {
                    oraConnection = new OracleConnection(oraConnectionStringBuilder.ConnectionString);
                    oraConnection.Open();
                }
                catch (Exception ex1)
                {
                    resCode = CSIReturnCode.FTL_EXAMIN_RCV_DBOPEN;
                    this.ErrorTraceOut(resCode, ex1);
                    return;
                }

                // -------------------------------------
                // MIRAISデータベースから検査結果を取得
                // -------------------------------------
                DataSet dsExaminData = null;

                // 取得メソッド呼び出し
                resCode = this.GetExaminationData(oraConnection, out dsExaminData);
                if (resCode.IsError || resCode.IsException)
                {
                    // アラーム出力
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, "", "", resCode);
                    return;
                }

                // -------------------------------------
                // 取り込むべき検査結果情報のリストを生成
                // ※FNWに取り込む際の検査結果と、MIRAIs側検査結果の比率は1:Nとなる(Nはシーケンス番号の数)
                // ※FNWに存在しない患者は処理対象から外す
                // -------------------------------------
                List<ExamInfo> lstExamInfos = new List<ExamInfo>();
                resCode = this.CreateExamInfoList(dsExaminData, ref lstExamInfos);
                if (resCode.IsError || resCode.IsException)
                {
                    return;
                }

                // 検査結果情報の件数分処理
                foreach (ExamInfo eiExamInfo in lstExamInfos)
                {
                    // -------------------------------------
                    // FNデータベースへの検査結果の更新
                    // -------------------------------------
                    resCode = this.UpdateExaminationData(dsExaminData, eiExamInfo);
                    if (resCode.IsError || resCode.IsException)
                    {
                        // アラーム出力
                        string strMessage = string.Format("検査結果の取込みに失敗しました。 （検査日時：{0} 検査区分：{1}）",
                                                          eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"),
                                                          eiExamInfo.OrderClass);
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, "", CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + strMessage);
                        continue;
                    }

                    // -------------------------------------
                    // MIRAISデータベースの検査結果情報を削除
                    // -------------------------------------
                    resCode = this.DeleteExaminationData(oraConnection, eiExamInfo);
                    if (resCode.IsError || resCode.IsException)
                    {
                        // アラーム出力
                        string strMessage = string.Format("検査結果データの削除に失敗しました。（検査日時：{0} 検査区分：{1}）",
                                                          eiExamInfo.ExamDate,
                                                          eiExamInfo.OrderClass);
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, "", CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + strMessage);
                        continue;
                    }

                    // 検査結果取込成功
                    this.DebugTraceOut(CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_DBG + CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG +
                                       string.Format("検査結果の取込みに成功しました。 患者ID：{0} 表示用患者ID：{1} 検査日時：{2} 検査区分：{3}",
                                       eiExamInfo.PatID, eiExamInfo.DispPatID, eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"), eiExamInfo.OrderClass));
                }

                // 検査結果情報受信正常終了
                this.DebugTraceOut(CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_DBG + string.Format("MIRAIs-DBからの検査結果情報受信処理が終了しました。Count : {0}", lstExamInfos.Count.ToString()));
            }
            catch (Exception ex)
            {
                resCode = CSIReturnCode.FTL_EXAMIN_RCV_ELAPSED;
                this.ErrorTraceOut(resCode, ex);
            }
            finally
            {
                if (oraConnection != null && oraConnection.State != ConnectionState.Closed)
                {
                    oraConnection.Close();
                    oraConnection.Dispose();
                    oraConnection = null;
                }

                // 翌日の定期取込実施時刻までの時間(ミリ秒)を計算
                // 2013/08/22 中村 １日複数回取込対応 Chg Start
                // double dblDueTime = this.GetMSecOfUntilSpecifiedTime(this.dtExecuteTime);
                double dblDueTime = this.GetMSecOfUntilSpecifiedTime(this.listExecuteTime);
                // 2013/08/22 中村 １日複数回取込対応 Chg End

                // タイマー再開
                this.timerExaminRcvExecute.Interval = dblDueTime;
                this.timerExaminRcvExecute.Start();

                // メソッド開始ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());

                bTimerIsAlive = false;
            }

            return;
        }

        #endregion

        /// <summary>
        /// プラグイン送信実行処理
        /// </summary>
        /// <param name="exeInfo">連携情報</param>
        /// <returns>リターンコード</returns>
        protected override Fn3ReturnCode Execute(Fn3ExecuteInfo exeInfo)
        {
            // メソッド開始ログ
            this.MethodStartLogOut(MethodBase.GetCurrentMethod());

            OracleConnection oraConnection = null;
            Fn3ReturnCode resCode = Fn3ReturnCode.Success; ;

            try
            {
                // DB接続文字列の構築
                OracleConnectionStringBuilder oraConnectionStringBuilder = new OracleConnectionStringBuilder();
                oraConnectionStringBuilder.DataSource = this.miraisDataSource;
                oraConnectionStringBuilder.UserID = this.miraisUserName;
                oraConnectionStringBuilder.Password = this.miraisPassword;

                // -------------------------------------
                // MIRAISデータベースへの接続
                // -------------------------------------
                try
                {
                    oraConnection = new OracleConnection(oraConnectionStringBuilder.ConnectionString);
                    oraConnection.Open();
                }
                catch (Exception ex1)
                {
                    resCode = CSIReturnCode.FTL_EXAMIN_RCV_DBOPEN;
                    this.ErrorTraceOut(resCode, ex1);
                    return resCode;
                }

                // -------------------------------------
                // MIRAISデータベースから検査結果を取得
                // -------------------------------------
                DataSet dsExaminData = null;

                // 取得メソッド呼び出し
                resCode = this.GetExaminationData(oraConnection, out dsExaminData);
                if (resCode.IsError || resCode.IsException)
                {
                    // アラーム出力
                    this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, "", "", resCode);
                    return resCode;
                }

                // -------------------------------------
                // 取り込むべき検査結果情報のリストを生成
                // ※FNWに取り込む際の検査結果と、MIRAIs側検査結果の比率は1:Nとなる(Nはシーケンス番号の数)
                // ※FNWに存在しない患者は処理対象から外す
                // -------------------------------------
                List<ExamInfo> lstExamInfos = new List<ExamInfo>();
                resCode = this.CreateExamInfoList(dsExaminData, ref lstExamInfos);
                if (resCode.IsError || resCode.IsException)
                {
                    return resCode;
                }

                // 検査結果情報の件数分処理
                foreach (ExamInfo eiExamInfo in lstExamInfos)
                {
                    // -------------------------------------
                    // FNデータベースへの検査結果の更新
                    // -------------------------------------
                    resCode = this.UpdateExaminationData(dsExaminData, eiExamInfo);
                    if (resCode.IsError || resCode.IsException)
                    {
                        // アラーム出力
                        string strMessage = string.Format("検査結果の取込みに失敗しました。 （検査日時：{0} 検査区分：{1}）",
                                                          eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"),
                                                          eiExamInfo.OrderClass);
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, "", CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + strMessage);
                        continue;
                    }

                    // -------------------------------------
                    // MIRAISデータベースの検査結果情報を削除
                    // -------------------------------------
                    resCode = this.DeleteExaminationData(oraConnection, eiExamInfo);
                    if (resCode.IsError || resCode.IsException)
                    {
                        // アラーム出力
                        string strMessage = string.Format("検査結果データの削除に失敗しました。（検査日時：{0} 検査区分：{1}）",
                                                          eiExamInfo.ExamDate,
                                                          eiExamInfo.OrderClass);
                        this.SendAlarm(AlarmKind.DEVICE_ALARM_ALL, eiExamInfo.DispPatID, eiExamInfo.PatName, "", CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_ERR + strMessage);
                        continue;
                    }

                    // 検査結果取込成功
                    this.DebugTraceOut(CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_DBG + CSICommonConst.DEBUGTRACE_PRE_SUCCESS_MSG +
                                       string.Format("検査結果の取込みに成功しました。 患者ID：{0} 表示用患者ID：{1} 検査日時：{2} 検査区分：{3}",
                                       eiExamInfo.PatID, eiExamInfo.DispPatID, eiExamInfo.ExamDate.ToString("yyyy/MM/dd HH:mm:ss"), eiExamInfo.OrderClass));
                }

                // 検査結果情報受信正常終了
                this.DebugTraceOut(CSICommonConst.MODULE_MNAME_ER + CSICommonConst.LOGTYPE_DBG + string.Format("MIRAIs-DBからの検査結果情報受信処理が終了しました。Count : {0}", lstExamInfos.Count.ToString()));
            }
            catch (Exception ex)
            {
                resCode = CSIReturnCode.FTL_EXAMIN_RCV_ELAPSED;
                this.ErrorTraceOut(resCode, ex);
            }
            finally
            {
                if (oraConnection != null && oraConnection.State != ConnectionState.Closed)
                {
                    oraConnection.Close();
                    oraConnection.Dispose();
                    oraConnection = null;
                }
                // メソッド終了ログ
                this.MethodEndLogOut(MethodBase.GetCurrentMethod());
            }

            return resCode;
        }

    }
}
