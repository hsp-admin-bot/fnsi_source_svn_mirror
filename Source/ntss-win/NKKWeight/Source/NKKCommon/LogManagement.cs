//----------------------------------------------------------------------------------------------------
//Mongoログ処理
//----------------------------------------------------------------------------------------------------

using NKKLoggingLib;
using NKKWebAccessLib;
using System;
using System.Net;
using System.Net.Sockets;
using System.Text;

namespace NKKCommon
{
    public static class LogManagement
    {

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアントIP
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_clientIp = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クライアントIP参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String ClientIp
        {
            get { return GetLocalIP(); }
            set { m_clientIp = value; }
        }

        /// <summary>
        /// 本機本体のipを取る
        /// </summary>
        /// <returns></returns>
        public static string GetLocalIP()
        {
            try
            {
                //ホスト名を取得する
                string HostName = Dns.GetHostName(); 
                IPHostEntry IpEntry = Dns.GetHostEntry(HostName);
                for (int i = 0; i < IpEntry.AddressList.Length; i++)
                {
                    //IPアドレスリストからIPv 4タイプのIPアドレスを絞り出す
                    if (IpEntry.AddressList[i].AddressFamily == AddressFamily.InterNetwork)
                    {
                        string ip = "";
                        ip = IpEntry.AddressList[i].ToString();
                        return IpEntry.AddressList[i].ToString();
                    }
                }
                return "";
            }
            catch (Exception ex)
            {
                return ex.Message;
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// セッションID
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_sessionId = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// セッションID参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String SessionId
        {
            get { return (m_sessionId); }
            set { m_sessionId = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバイスエッジNo
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_deviceEdgeNo = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバイスエッジNo参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String DeviceEdgeNo
        {
            get { return (m_deviceEdgeNo); }
            set { m_deviceEdgeNo = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バイスエッジ製造番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_deviceEdgeSerialNo = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// バイスエッジ製造番号参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String DeviceEdgeSerialNo
        {
            get { return (m_deviceEdgeSerialNo); }
            set { m_deviceEdgeSerialNo = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 型式
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_machineType = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 型式参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String MachineType
        {
            get { return (m_machineType); }
            set { m_machineType = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 型式コード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_machineTypeCd = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 型式コード参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String MachineTypeCd
        {
            get { return (m_machineTypeCd); }
            set { m_machineTypeCd = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// EC2識別
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_ec2Identification = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// EC2識別参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String Ec2Identification
        {
            get { return (m_ec2Identification); }
            set { m_ec2Identification = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_serviceName = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String ServiceName
        {
            get { return (m_serviceName); }
            set { m_serviceName = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 機能コード
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_functionCd = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 機能コード参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String FunctionCd
        {
            get { return (m_functionCd); }
            set { m_functionCd = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 内部患者ID
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_patId = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 内部患者ID参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String PatId
        {
            get { return (m_patId); }
            set { m_patId = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SQL名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_sqlIdentification = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// SQL名参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String SqlIdentification
        {
            get { return (m_sqlIdentification); }
            set { m_sqlIdentification = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ内容
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_logMessage = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ内容参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String LogMessage
        {
            get { return (m_logMessage); }
            set { m_logMessage = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 対応内容
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_supportMessage = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 対応内容参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String SupportMessage 
        {
            get { return (m_supportMessage); }
            set { m_supportMessage = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// invokeクラス
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String m_invokeClass = String.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// invokeクラス参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static String InvokeClass
        {
            get { return (m_invokeClass); }
            set { m_invokeClass = value; }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private static String SERVICE_NAME = "LogManagement";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private static void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }

        /// <summary>
        /// アプリケーションURI
        /// </summary>
        private static string WEB_APP_URI { get; set; } = "/ntss-admin-web/api/logging";
        /// <summary>
        /// ログ転送URI /mongo/{logLevel}
        /// </summary>
        public static string MONGODB_URI { get; set; } = "/mongo/info";

        public static void SetLogingProperties()
        {
            // add 3819:サインイン画面でアプリを閉じる際に異常に時間がかかるの対応 夏 start
            if (NKKWebAccess.Login == true) {
            // add 3819:サインイン画面でアプリを閉じる際に異常に時間がかかるの対応 夏 end
                // Uri作成                         
                string strUri = $"{NKKWebAccess.BaseUri}{WEB_APP_URI}{MONGODB_URI}?_={DateTime.Now.Ticks}";
           
                try
                {
                    // ログイン処理
                    var mongoDBcontent = new StringBuilder();
                    mongoDBcontent.Append("{")
                                .AppendFormat("\"facilityCd\": \"{0}\",", NKKWebAccess.FacilityCd)
                                .AppendFormat("\"userId\": \"{0}\",", NKKWebAccess.UserId)
                                .AppendFormat("\"clientIp\": \"{0}\",", ClientIp)
                                .AppendFormat("\"sessionId\": \"{0}\",", SessionId)
                                .AppendFormat("\"deviceEdgeNo\": \"{0}\",", DeviceEdgeNo)
                                .AppendFormat("\"deviceEdgeSerialNo\": \"{0}\",", DeviceEdgeSerialNo)
                                .AppendFormat("\"machineType\": \"{0}\",", MachineType)
                                .AppendFormat("\"machineTypeCd\": \"{0}\",", MachineTypeCd)
                                .AppendFormat("\"ec2Identification\": \"{0}\",", Ec2Identification)
                                .AppendFormat("\"serviceName\": \"{0}\",", ServiceName)
                                .AppendFormat("\"functionCd\": \"{0}\",", FunctionCd)
                                .AppendFormat("\"patId\": \"{0}\",", PatId)
                                .AppendFormat("\"sqlIdentification\": \"{0}\",", SqlIdentification)
                                .AppendFormat("\"logMessage\": \"{0}\",", LogManagement.LogMessage)
                                .AppendFormat("\"supportMessage\": \"{0}\",", SupportMessage)
                                .AppendFormat("\"invokeClass\": \"{0}\"", InvokeClass)
                                .Append("}");

                    NKKWebAccessResponse res = NKKWebAccess.Put("ログ転送", strUri, mongoDBcontent.ToString()).Result;
                }
                catch (Exception ex)
                {
                    // エラー(サーバー未到達含む)
                    AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("ログ転送に失敗しました,{0},{1}", strUri, ex.ToString().Replace("\r\n", "{CRLF}")));

                }
            // add 3819:サインイン画面でアプリを閉じる際に異常に時間がかかるの対応 夏 start
            }
            // add 3819:サインイン画面でアプリを閉じる際に異常に時間がかかるの対応 夏 end
        }

    }
}
