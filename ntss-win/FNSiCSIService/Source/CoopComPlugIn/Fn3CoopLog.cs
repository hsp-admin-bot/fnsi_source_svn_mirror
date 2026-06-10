///////////////////////////////////////////////////////////////////////////////
//
// システム名：FutureNetⅢ
// 機能名    ：連携本体ログ出力
// ファイル名：Fn3CoopLog.cs
// 説明      ：連携本体のログ出力を行う
//
//	Copyright(C) 2009 NIKKISO CO., LTD. All Rights Reserved 
//
// 更新履歴
//	日付		担当				理由
//	2009/10/16	青木　雅文			新規作成
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Text;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonInterface;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;
using jp.co.nikkiso.fn3.Cooperation;
using System.Reflection;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using System.IO;

namespace jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn
{
    /// <summary>
    /// メソッドログフラグ
    /// </summary>
    public enum MethodFlag
    {
		/// <summary>
		/// 開始ログ
		/// </summary>
        Start = 0,

		/// <summary>
		///	終了ログ
		/// </summary>
        End = 1
    }

	/// <summary>
	/// 変更内容区分1
	/// </summary>
	public enum ChangeLogType1
	{
		/// <summary>
		/// その他
		/// </summary>
		Etc,

		/// <summary>
		/// 患者情報
		/// </summary>
		PatInfo,

		/// <summary>
		/// 実績
		/// </summary>
		Result,

		/// <summary>
		/// 指示
		/// </summary>
		Indication,

		/// <summary>
		/// 予定管理
		/// </summary>
		Schedule,

		/// <summary>
		/// 治療状況
		/// </summary>
		Treat,

		/// <summary>
		/// 帳票
		/// </summary>
		Report,

		/// <summary>
		/// 器材保守
		/// </summary>
		DevMente,

		/// <summary>
		/// システム
		/// </summary>
		System
	}

	/// <summary>
	/// 変更内容区分2
	/// </summary>
	public enum ChangeLogType2
	{
		/// <summary>
		/// なし
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndication、Result以外の場合はNoneを選択します。
		/// </remarks>
		None,

		/// <summary>
		/// 透析予約
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		DialSche,

		/// <summary>
		/// 透析条件
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		DialCondition,

		/// <summary>
		/// 投薬
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		Medicine,

		/// <summary>
		/// 医療材料
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		Material,

		/// <summary>
		/// 補足
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		Supplement,

		/// <summary>
		/// 条件付
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がIndicationの場合のみ選択可。
		/// </remarks>
		Condition,

		/// <summary>
		/// 透析条件
		/// </summary>
		/// <remarks>
		/// ChangeLogType1がResultの場合のみ選択可。
		/// </remarks>
		Result
	}

	/// <summary>
	/// ログ出力クラス
	/// </summary>
    public class Fn3CoopLog
    {

        #region "プロパティ変数"
        private OutLogDelegate m_dgtOutLog = null;
        #endregion

        #region "プロパティ宣言"
		/// <summary>
		/// ログ出力デリゲートを取得または設定します。
		/// </summary>
        public OutLogDelegate OutLogDelegate
        {
            set { m_dgtOutLog = value; }
			get { return m_dgtOutLog; }
        }
        #endregion

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// スタートログを出力します
        ///// </summary>
        //public void StartLog(object obj)
        //{
        //    LogParameter log = new LogParameter();

        //    log.Initialize();
        //    log.TraceFlg = true;
        //    log.TraceMsg = string.Format("[{0}] : START.",GetFileName(obj.GetType()));
        //    m_dgtOutLog(CoopLogLevel.NONE, "", log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// スタートログを出力します
        /// </summary>
        public void StartLog(object obj)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            StartLog(logParameter, obj);
        }

        /// <summary>
        /// スタートログを出力します
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="obj"></param>
        public void StartLog(LogParameter logParameter, object obj)
        {
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            logParameter.TraceMsg = string.Format("[{0}] : START.", GetFileName(obj.GetType()));
            m_dgtOutLog(CoopLogLevel.NONE, "", logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// エンドログを出力します
        ///// </summary>
        //public void EndLog(object obj)
        //{
        //    LogParameter log = new LogParameter();

        //    log.Initialize();
        //    log.TraceFlg = true;
        //    log.TraceMsg = string.Format("[{0}] : END.", GetFileName(obj.GetType()));
        //    m_dgtOutLog(CoopLogLevel.NONE, "", log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// エンドログを出力します
        /// </summary>
        public void EndLog(object obj)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            EndLog(logParameter, obj);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エンドログを出力します
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="obj"></param>
        public void EndLog(LogParameter logParameter, object obj)
        {
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            logParameter.TraceMsg = string.Format("[{0}] : END.", GetFileName(obj.GetType()));
            m_dgtOutLog(CoopLogLevel.NONE, "", logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// トレースログ
        ///// </summary>
        ///// <param name="strMessage">出力メッセージ</param>
        //public void TraceLog(string strMessage)
        //{
        //    this.TraceLog("", strMessage);
        //}

        ///// <summary>
        ///// トレースログ
        ///// </summary>
        ///// <param name="strErrCode">エラーコード</param>
        ///// <param name="strMessage">出力メッセージ</param>
        //public void TraceLog(string strErrCode, string strMessage)
        //{
        //    LogParameter log = new LogParameter();
        //    log.Initialize();
        //    log.TraceFlg = true;
        //    log.TraceMsg = strMessage;
        //    m_dgtOutLog(CoopLogLevel.ERROR, strErrCode, log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="strMessage">出力メッセージ</param>
        public void TraceLog(string strMessage)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            this.TraceLog(logParameter, "", strMessage);
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strMessage"></param>
        public void TraceLog(LogParameter logParameter, string strMessage)
        {
            this.TraceLog(logParameter, "", strMessage);
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="strErrCode">エラーコード</param>
        /// <param name="strMessage">出力メッセージ</param>
        public void TraceLog(string strErrCode, string strMessage)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            TraceLog(logParameter, strErrCode, strMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strErrCode"></param>
        /// <param name="strMessage"></param>
        public void TraceLog(LogParameter logParameter, string strErrCode, string strMessage)
        {
            if (string.IsNullOrEmpty(logParameter.SeriesCode))
            {
                logParameter.SetProcessID("000", "00000", "0");
            }
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            logParameter.TraceMsg = strMessage;
            m_dgtOutLog(CoopLogLevel.ERROR, strErrCode, logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// トレースログ
        ///// </summary>
        ///// <param name="code">リターンコード</param>
        //public void TraceLog(Fn3ReturnCode code)
        //{
        //    this.TraceLog(code, "");
        //}

        ///// <summary>
        ///// トレースログ
        ///// </summary>
        ///// <param name="code">リターンコード</param>
        ///// <param name="strExtensionMessage">拡張メッセージ</param>
        //public void TraceLog(Fn3ReturnCode code, string strExtensionMessage)
        //{
        //    LogParameter log = new LogParameter();
        //    log.Initialize();
        //    log.TraceFlg = true;
        //    if(strExtensionMessage != null && strExtensionMessage.Length > 0)
        //    {
        //        log.TraceMsg = string.Format("{0}（{1}）", code.Message, strExtensionMessage);
        //    }
        //    else
        //    {
        //        log.TraceMsg = code.Message;
        //    }
        //    m_dgtOutLog(CoopLogLevel.ERROR, code.ErrorCode, log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="code">リターンコード</param>
        public void TraceLog(Fn3ReturnCode code)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            this.TraceLog(logParameter, code, "");
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="code"></param>
        public void TraceLog(LogParameter logParameter, Fn3ReturnCode code)
        {
            this.TraceLog(logParameter, code, "");
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="code">リターンコード</param>
        /// <param name="strExtensionMessage">拡張メッセージ</param>
        public void TraceLog(Fn3ReturnCode code, string strExtensionMessage)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            TraceLog(logParameter, code, strExtensionMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// トレースログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="code"></param>
        /// <param name="strExtensionMessage"></param>
        public void TraceLog(LogParameter logParameter, Fn3ReturnCode code, string strExtensionMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            if (string.IsNullOrEmpty(logParameter.SeriesCode))
            {
                logParameter.SetProcessID("000", "00000", "0");
            }
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            if (strExtensionMessage != null && strExtensionMessage.Length > 0)
            {
                logParameter.TraceMsg = string.Format("{0}（{1}）", code.Message, strExtensionMessage);
            }
            else
            {
                logParameter.TraceMsg = code.Message;
            }
            m_dgtOutLog(CoopLogLevel.ERROR, code.ErrorCode, logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// エラーログ
        ///// </summary>
        ///// <param name="code">リターンコード</param>
        ///// <param name="ex">例外クラス</param>
        //public void ErrorLog(Fn3ReturnCode code, Exception ex)
        //{
        //    this.ErrorLog(code, ex, "");
        //}

        ///// <summary>
        ///// エラーログ
        ///// </summary>
        ///// <param name="code">リターンコード</param>
        ///// <param name="ex">例外クラス</param>
        ///// <param name="strExtensionMessage">追加情報</param>
        //public void ErrorLog(Fn3ReturnCode code, Exception ex, string strExtensionMessage)
        //{
        //    LogParameter log = new LogParameter();
        //    log.Initialize();
        //    log.ErrorFlg = true;
        //    if(strExtensionMessage != null && strExtensionMessage.Length > 0)
        //    {
        //        log.ErrorMsg = string.Format("{0}[{1}][{2}]({3})", code.Message, ex.Message, ex.StackTrace, strExtensionMessage);
        //    }
        //    else
        //    {
        //        log.ErrorMsg = string.Format("{0}[{1}][{2}]", code.Message, ex.Message, ex.StackTrace);
        //    }

        //    m_dgtOutLog(CoopLogLevel.ERROR, code.ErrorCode, log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// エラーログ
        /// </summary>
        /// <param name="code">リターンコード</param>
        /// <param name="ex">例外クラス</param>
        public void ErrorLog(Fn3ReturnCode code, Exception ex)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            this.ErrorLog(logParameter, code, ex, "");
        }

        /// <summary>
        /// エラーログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="code"></param>
        /// <param name="ex"></param>
        public void ErrorLog(LogParameter logParameter, Fn3ReturnCode code, Exception ex)
        {
            this.ErrorLog(logParameter, code, ex, "");
        }

        /// <summary>
        /// エラーログ
        /// </summary>
        /// <param name="code">リターンコード</param>
        /// <param name="ex">例外クラス</param>
        /// <param name="strExtensionMessage">追加情報</param>
        public void ErrorLog(Fn3ReturnCode code, Exception ex, string strExtensionMessage)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            ErrorLog(logParameter, code, ex, strExtensionMessage);
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        }

        /// <summary>
        /// エラーログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="code"></param>
        /// <param name="ex"></param>
        /// <param name="strExtensionMessage"></param>
        public void ErrorLog(LogParameter logParameter, Fn3ReturnCode code, Exception ex, string strExtensionMessage)
        {
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            if (string.IsNullOrEmpty(logParameter.SeriesCode))
            {
                logParameter.SetProcessID("000", "00000", "0");
            }
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            logParameter.Initialize();
            logParameter.ErrorFlg = true;
            if (strExtensionMessage != null && strExtensionMessage.Length > 0)
            {
                logParameter.ErrorMsg = string.Format("{0}[{1}][{2}]({3})", code.Message, ex.Message, ex.StackTrace, strExtensionMessage);
            }
            else
            {
                logParameter.ErrorMsg = string.Format("{0}[{1}][{2}]", code.Message, ex.Message, ex.StackTrace);
            }

            m_dgtOutLog(CoopLogLevel.ERROR, code.ErrorCode, logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// エラーログを出力する
        ///// </summary>
        ///// <param name="strErrorCode">エラーコード</param>
        ///// <param name="strErrorMesage">エラーメッセージ</param>
        ///// <param name="ex">例外クラス</param>
        //public void ErrorLog(string strErrorCode, string strErrorMesage, Exception ex)
        //{
        //    this.ErrorLog(strErrorCode, strErrorMesage, ex, "");
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// エラーログを出力する
        /// </summary>
        /// <param name="strErrorCode">エラーコード</param>
        /// <param name="strErrorMessage">エラーメッセージ</param>
        /// <param name="ex">例外クラス</param>
        public void ErrorLog(string strErrorCode, string strErrorMessage, Exception ex)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            ErrorLog(logParameter, strErrorCode, strErrorMessage, ex, "");
        }

        /// <summary>
        /// エラーログを出力する
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strErrorCode"></param>
        /// <param name="strErrorMessage"></param>
        /// <param name="ex"></param>
        public void ErrorLog(LogParameter logParameter, string strErrorCode, string strErrorMessage, Exception ex)
        {
            ErrorLog(logParameter, strErrorCode, strErrorMessage, ex, "");
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// エラーログを出力する。
        ///// </summary>
        ///// <param name="strErrorCode">エラーコード</param>
        ///// <param name="strErrorMessage">エラーメッセージ</param>
        ///// <param name="ex">例外クラス</param>
        ///// <param name="strExtensionMessage">追加情報</param>
        //public void ErrorLog(string strErrorCode, string strErrorMessage, Exception ex, string strExtensionMessage)
        //{
        //    LogParameter log = new LogParameter();
        //    log.Initialize();
        //    log.ErrorFlg = true;
        //    if(strExtensionMessage != null && strExtensionMessage.Length > 0)
        //    {
        //        log.ErrorMsg = string.Format("{0}[{1}][{2}]", strErrorMessage, ex.Message, ex.StackTrace);
        //    }
        //    else
        //    {
        //        log.ErrorMsg = string.Format("{0}[{1}][{2}]({3})", strErrorMessage, ex.Message, ex.StackTrace, strExtensionMessage);
        //    }

        //    m_dgtOutLog(CoopLogLevel.ERROR, strErrorCode, log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// エラーログを出力する。
        /// </summary>
        /// <param name="strErrorCode">エラーコード</param>
        /// <param name="strErrorMessage">エラーメッセージ</param>
        /// <param name="ex">例外クラス</param>
        /// <param name="strExtensionMessage">追加情報</param>
        public void ErrorLog(string strErrorCode, string strErrorMessage, Exception ex, string strExtensionMessage)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            ErrorLog(logParameter, strErrorCode, strErrorMessage, ex, strExtensionMessage);
        }

        /// <summary>
        /// エラーログを出力する。
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strErrorCode"></param>
        /// <param name="strErrorMessage"></param>
        /// <param name="ex"></param>
        /// <param name="strExtensionMessage"></param>
        public void ErrorLog(LogParameter logParameter, string strErrorCode, string strErrorMessage, Exception ex, string strExtensionMessage)
        {
            logParameter.Initialize();
            logParameter.ErrorFlg = true;
            if (strExtensionMessage != null && strExtensionMessage.Length > 0)
            {
                logParameter.ErrorMsg = string.Format("{0}[{1}][{2}]", strErrorMessage, ex.Message, ex.StackTrace);
            }
            else
            {
                logParameter.ErrorMsg = string.Format("{0}[{1}][{2}]({3})", strErrorMessage, ex.Message, ex.StackTrace, strExtensionMessage);
            }

            m_dgtOutLog(CoopLogLevel.ERROR, strErrorCode, logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// デバッグログを出力する。
        ///// </summary>
        ///// <param name="strMessage">出力メッセージ</param>
        //public void DebugLog(string strMessage)
        //{
        //    LogParameter log = new LogParameter();
        //    log.TraceFlg = true;
        //    log.TraceMsg = strMessage;

        //    m_dgtOutLog(CoopLogLevel.DEBUG, "", log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// デバッグログを出力する。
        /// </summary>
        /// <param name="strMessage">出力メッセージ</param>
        public void DebugLog(string strMessage)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            DebugLog(logParameter, strMessage);
        }

        /// <summary>
        /// デバッグログを出力する。
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strMessage"></param>
        public void DebugLog(LogParameter logParameter, string strMessage)
        {
            logParameter.TraceFlg = true;
            logParameter.TraceMsg = strMessage;

            m_dgtOutLog(CoopLogLevel.DEBUG, "", logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        /// <summary>
        /// 自分自身のファイル名を取得
        /// </summary>
        /// <returns>ファイル名</returns>
        public string GetFileName(Type type)
        {
			return Assembly.GetAssembly(type).GetName().Name;
        }

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        #region 系列施設複数連携対応
        ///// <summary>
        ///// メソッドログ
        ///// </summary>
        ///// <param name="flag">0：開始　1：終了</param>
        ///// <param name="mb">メソッドベース</param>
        //public void MethodLog(MethodFlag flag, MethodBase mb)
        //{
			
        //    LogParameter log = new LogParameter();
        //    log.Initialize();
        //    log.TraceFlg = true;
        //    if(flag == MethodFlag.Start)
        //    {
        //        log.TraceMsg = string.Format("[{0}]{1} : Method Start.", GetFileName(mb.DeclaringType), Fn3ComTool.GetMethodName(mb));
        //    }
        //    else
        //    {
        //        log.TraceMsg = string.Format("[{0}]{1} : Method End.", GetFileName(mb.DeclaringType), Fn3ComTool.GetMethodName(mb));
        //    }
        //    m_dgtOutLog(CoopLogLevel.METHOD, "", log);
        //}
        #endregion //系列施設複数連携対応

        /// <summary>
        /// メソッドログ
        /// </summary>
        /// <param name="flag">0：開始　1：終了</param>
        /// <param name="mb">メソッドベース</param>
        public void MethodLog(MethodFlag flag, MethodBase mb)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            MethodLog(logParameter, flag, mb);
        }

        /// <summary>
        /// メソッドログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="flag"></param>
        /// <param name="mb"></param>
        public void MethodLog(LogParameter logParameter, MethodFlag flag, MethodBase mb)
        {
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            if (flag == MethodFlag.Start)
            {
                logParameter.TraceMsg = string.Format("[{0}]{1} : Method Start.", GetFileName(mb.DeclaringType), Fn3ComTool.GetMethodName(mb));
            }
            else
            {
                logParameter.TraceMsg = string.Format("[{0}]{1} : Method End.", GetFileName(mb.DeclaringType), Fn3ComTool.GetMethodName(mb));
            }
            m_dgtOutLog(CoopLogLevel.METHOD, "", logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        /// <summary>
        /// 詳細ログ
        /// </summary>
        /// <param name="mb">メソッドベース</param>
        /// <param name="message">デバッグの内容を設定</param>
        public void MethodDetailLog(MethodBase mb, string message)
        {
            LogParameter logParameter = new LogParameter();
            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            logParameter.SetProcessID("000", "00000", "0");
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
            MethodDetailLog(logParameter, mb, message);
        }

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>
        /// 詳細ログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="mb"></param>
        /// <param name="message"></param>
        public void MethodDetailLog(LogParameter logParameter, MethodBase mb, string message)
        {
            logParameter.Initialize();
            logParameter.TraceFlg = true;
            logParameter.TraceMsg = string.Format("[{0}]{1} : ", GetFileName(mb.DeclaringType), Fn3ComTool.GetMethodName(mb), message);
            m_dgtOutLog(CoopLogLevel.DETAIL, "", logParameter);
        }
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>
        /// ダンプ出力
        /// </summary>
        /// <param name="strCooperationID">連携ID</param>
        /// <param name="strSpecificKey">特定キー</param>
        /// <param name="bytes">出力データ</param>
        public void DumpOut(string strCooperationID, string strSpecificKey, byte[] bytes)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            DumpOut(logParameter, strCooperationID, strSpecificKey, bytes);
        }
        
        /// <summary>
        /// ダンプ出力
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="strCooperationID"></param>
        /// <param name="strSpecificKey"></param>
        /// <param name="bytes"></param>
		public void DumpOut(LogParameter logParameter, string strCooperationID, string strSpecificKey, byte[] bytes)
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        {
			DateTime dt = DateTime.Now;

            // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
            #region 系列施設複数連携対応
            //LogParameter param = new LogParameter();
            #endregion //系列施設複数連携対応
            // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07

			logParameter.DmpFlg = true;
			logParameter.DmpSpecificKey = strSpecificKey;
			logParameter.DmpCoopId = strCooperationID;
			logParameter.DmpMsgBuf = bytes;
			logParameter.DmpProcDate = dt.ToString("yyyyMMddHHmmssffff");

			this.m_dgtOutLog(CoopLogLevel.NONE, "", logParameter);
		}

        // 系列施設複数連携対応 ここから 大星憲士 2013/05/07
        /// <summary>
        /// 変更ログ
        /// </summary>
        /// <param name="type1">種別１</param>
        /// <param name="type2">種別２</param>
        /// <param name="strPatID">患者ID</param>
        /// <param name="strDialysisNo">透析番号</param>
        /// <param name="strChangeLog">変更ログ</param>
        public void ChangeLogOut(ChangeLogType1 type1, ChangeLogType2 type2, string strPatID, string strDialysisNo, string strChangeLog)
        {
            LogParameter logParameter = new LogParameter();
            logParameter.SetProcessID("000", "00000", "0");
            ChangeLogOut(logParameter,
                                    type1,
                                    type2,
                                    strPatID,
                                    strDialysisNo,
                                    strChangeLog);
        }

        /// <summary>
        /// 変更ログ
        /// </summary>
        /// <param name="logParameter"></param>
        /// <param name="type1"></param>
        /// <param name="type2"></param>
        /// <param name="strPatID"></param>
        /// <param name="strDialysisNo"></param>
        /// <param name="strChangeLog"></param>
		public void ChangeLogOut(LogParameter logParameter, 
                                    ChangeLogType1 type1, 
                                    ChangeLogType2 type2, 
                                    string strPatID, 
                                    string strDialysisNo, 
                                    string strChangeLog)
        // 系列施設複数連携対応 ここまで 大星憲士 2013/05/07
        {
			string strType1 = "";
			string strType2 = "";

			switch(type1)
			{
			case ChangeLogType1.Etc: strType1 = "00"; break;
			case ChangeLogType1.PatInfo: strType1 = "01"; break;
			case ChangeLogType1.Result: strType1 = "02"; break;
			case ChangeLogType1.Indication: strType1 = "03"; break;
			case ChangeLogType1.Schedule: strType1 = "04"; break;
			case ChangeLogType1.Treat: strType1 = "05"; break;
			case ChangeLogType1.Report: strType1 = "06"; break;
			case ChangeLogType1.DevMente: strType1 = "07"; break;
			case ChangeLogType1.System: strType1 = "08"; break;
			}

			switch(type2)
			{
			case ChangeLogType2.None: strType2 = ""; break;
			case ChangeLogType2.DialSche: strType2 = "01"; break;
			case ChangeLogType2.DialCondition: strType2 = "02"; break;
			case ChangeLogType2.Medicine: strType2 = "03"; break;
			case ChangeLogType2.Material: strType2 = "04"; break;
			case ChangeLogType2.Supplement: strType2 = "05"; break;
			case ChangeLogType2.Condition: strType2 = "06"; break;
			case ChangeLogType2.Result: strType2 = "01"; break;
			}

            logParameter.ChgFlg = true;
            logParameter.ChgPatId = strPatID;
            logParameter.ChgDialysisNo = strDialysisNo;
            logParameter.ChgLogType1 = strType1;
            logParameter.ChgLogType2 = strType2;
            logParameter.ChgLogChange = strChangeLog;

            this.m_dgtOutLog(CoopLogLevel.NONE, "", logParameter);

		}
    }
}
