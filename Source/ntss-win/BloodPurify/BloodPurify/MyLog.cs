using System;
using System.IO;
using System.Net;
using System.Reflection;
using System.Windows.Forms;
using NKKLoggingLib;
using TdcVersionInfoLib;

namespace NKK.BloodPurify
{
    static public class MyLog
    {
        static private NKKLogging Nkkl = null;

        /// <summary>
        /// ログファイル識別子
        /// </summary>
        internal const String LOG_FILE_EXT = @"BloodPurify";

        /// <summary>
        /// 本クラスの各種機能を使用する前に呼び出す必要があるメソッド(※コンストラクタ的)
        /// </summary>
        static public void Init()
        {
            if (null == Nkkl)
            {
                Nkkl = NKKLogging.GetInstance();

                Nkkl.LogExt = $"{LOG_FILE_EXT}_{Dns.GetHostName()}";
                Nkkl.FirstWriteEvent = VersionInfos.GetVersionInfo; // exeやdllのファイル情報を出力
                Nkkl.SessionId = $"{DateTime.Now:yyyyMMddHHmmss}_{System.Diagnostics.Process.GetCurrentProcess().Id}";
            }
        }

        /// <summary>
        /// 本クラスを使用終了する際に呼び出す必要があるメソッド(※デストラクタ/ディスポーザ的)
        /// </summary>
        static public void Fini()
        {
            NKKLogging.DeleteInstance();
        }

		static private string ConvertEscapeSequence(string aMsg)
        {
            string ret = aMsg;
            ret = ret.Replace(",", "、");
            ret = ret.Replace("\r\n", "{CRLF}");
            ret = ret.Replace("\r", "{CRLF}"); // CR だけど {CRLF} に
            ret = ret.Replace("\n", "{CRLF}"); // LF だけど {CRLF} に

            return ret;
        }
		
		/// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aGUICode"></param>
        /// <param name="aMessage"></param>
        static public void AddLogInfo(string aGUICode, string aMessage)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aGUICode, NKKLogging.LOGGING_CLASS.INFO, ConvertEscapeSequence(aMessage));
        }
        /// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aObj"></param>
        /// <param name="aMessage"></param>
        static public void AddLogInfo(object aObj, string aMessage)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aObj.GetType().Name, NKKLogging.LOGGING_CLASS.INFO, ConvertEscapeSequence(aMessage));
        }

        /// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aGUICode"></param>
        /// <param name="aAddHeadMsg"></param>
        /// <param name="argEx"></param>
        static public void AddLogInfo(string aGUICode, string aAddHeadMsg, Exception argEx)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            string formattedMsg = ("" == aAddHeadMsg ? "" : aAddHeadMsg + " ")
                + (null != argEx ? "ExMsg[" + argEx.Message + "] StackTrace[" + argEx.StackTrace + "]" : "");
            formattedMsg = ConvertEscapeSequence(formattedMsg);

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aGUICode, NKKLogging.LOGGING_CLASS.ERROR, formattedMsg);
        }
        /// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aObj"></param>
        /// <param name="aAddHeadMsg"></param>
        /// <param name="argEx"></param>
        static public void AddLogInfo(object aObj, string aAddHeadMsg, Exception argEx)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            string formattedMsg = ("" == aAddHeadMsg ? "" : aAddHeadMsg + " ")
                + (null != argEx ? "ExMsg[" + argEx.Message + "] StackTrace[" + argEx.StackTrace + "]" : "");
            formattedMsg = ConvertEscapeSequence(formattedMsg);

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aObj.GetType().Name, NKKLogging.LOGGING_CLASS.ERROR, formattedMsg);
        }

        /// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aObj"></param>
        /// <param name="aLOGGING_CLASS"></param>
        /// <param name="aMessage"></param>
        static public void AddLogInfo(object aObj, NKKLogging.LOGGING_CLASS aLOGGING_CLASS, string aMessage)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aObj.GetType().Name, aLOGGING_CLASS, ConvertEscapeSequence(aMessage));
        }
        /// <summary>
        /// ログ記録(NKKLogging.AddLogInfoのカスタマイズラッパー)
        /// </summary>
        /// <param name="aGUICode"></param>
        /// <param name="aLOGGING_CLASS"></param>
        /// <param name="aMessage"></param>
        static public void AddLogInfo(string aGUICode, NKKLogging.LOGGING_CLASS aLOGGING_CLASS, string aMessage)
        {
            if ("" == Nkkl.LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            Nkkl.AddLogInfo(DateTime.Now, Application.ProductName, aGUICode, aLOGGING_CLASS, ConvertEscapeSequence(aMessage));
        }
    }
}
