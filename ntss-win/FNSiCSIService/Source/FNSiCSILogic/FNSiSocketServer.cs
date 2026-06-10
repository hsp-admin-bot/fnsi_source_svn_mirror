using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NKKLoggingLib;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.Odbc;
using System.IO;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Threading;
using System.Threading.Tasks;
using TdcLib;
using TdcSocketLib;
using System.Xml;
using jp.co.nikkiso.fn3.Cooperation.CoopComPlugIn;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopLog;                 //ログ
using System.Configuration;
using jp.co.nikkiso.fn3.Cooperation;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonDefine;
using jp.co.nikkiso.fn3.Cooperation.StdLinkage.CoopCommonInterface;

namespace FNSiCSILogicLib
{
    /// <summary>
    /// FNSiSocketServiceクラス
    /// </summary>
    class FNSiSocketService
    {
        #region プライベート定義

        // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
        /// <summary>
        /// エラー分類:DDL
        /// </summary>
        public static String ERR_FN3 = "FN3";

        /// <summary>
        /// エラー分類:CSI
        /// </summary>
        public static String ERR_CSI = "CSI";
        // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end

        /// <summary>
        /// サービス名称
        /// </summary>
        private readonly String SERVICE_NAME = String.Format("{0,-20}", System.Reflection.Assembly.GetExecutingAssembly().GetName().Name);

        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        private Exception m_Exception = null;

        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        private readonly Thread m_Thread = null;

        /// <summary>
        /// SocketサービスのポートNo
        /// </summary>
        private int m_nPortNo = 0;

        /// <summary>
        /// CSIDll情報配列
        /// </summary>
        private ArrayList m_CSIDllInfoList = new ArrayList();

        /// <summary>
        /// TdcBaseSocketServerオブジェクト
        /// </summary>
        private readonly TdcBaseSocketServer m_socketService = new TdcBaseSocketServer();

        /// <summary>
        /// 設定ファイル内[共通設定]セッション識別子
        /// </summary>
        public static String CONFIG_COMMON_SECTION = "Settings\\Common";

        private String path = AppDomain.CurrentDomain.BaseDirectory;

        private Fn3ComPlugIn m_iPlugin = null;

        /// <summary>ログクラス定義 (シングルトン)</summary>
        private CoopLogManager m_LogManager = null;

        /// <summary>初期設定定義</summary>
        private InitialDataManager m_IniDATA = null;

        /// <summary>アラームクラス定義</summary>
        private AlarmManager m_dgtAlarm = null;

        private String m_functionDllName = "";

        private String csiDllName = "";

        private String m_keyInfo = "";

        private Boolean isExecuteFlg = false;

        private Byte[] m_clientReceivedBuff = new Byte[0];

        private Boolean isConnectFlg = false;

        private String LocalFolder = "Data\\";

        private String sendCsiFileName = "";

        private Object m_lockObject = new Object();
        #endregion

        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FNSiSocketService()
        {
            // 構築処理

            // クライアント接続時
            this.m_socketService.ServiceName = this.SERVICE_NAME;
            this.m_socketService.ClientConnectedHandler = this.ClientConnected;
            this.m_socketService.ClientReceivedHandler = this.ClientReceived;

            // Socket Server用スレッド構築
            this.m_Thread = new Thread(this.DoWork)
            {
                Name = "FNSiSocketService処理スレッド",
                IsBackground = false
            };
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiSocketService()
        {
            // 処理終了
            //this.Stop();
        }

        /// <summary>
        /// 処理開始
        /// </summary>
        /// <returns></returns>
        public Boolean Start()
        {
            Boolean bret = true;

            DateTime dtnow = DateTime.Now;

            try
            {
                // 処理開始成功時
                if (bret == true && this.m_Thread != null)
                {
                    // Socket Server用スレッド開始
                    this.m_Thread.Start();
                }

                // ログ記録
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理開始");
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }

            return (bret);
        }

        /// <summary>
        /// 処理終了
        /// </summary>
        public void Stop()
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // Socketサーバー処理停止
                if (this.m_socketService.IsListen)
                {
                    this.m_socketService.StopListner();

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理終了");
                }

                // Socket Server用スレッド停止
                if (this.m_Thread != null)
                {
                    // カウンタ値初期化
                    uint dwtickcount = (uint)System.Environment.TickCount;

                    // スレッドが終了するか10秒間待つ
                    while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                    {
                        // スレッドが終了した場合
                        if (this.m_Thread.IsAlive == false)
                        {
                            // 処理を抜ける
                            break;
                        }
                    };
                }

                // ログ記録
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理終了");
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }

        /// <summary>
        /// SocketサービスのポートNo 参照/設定用プロパティ
        /// </summary>
        public int PortNo
        {
            get { return this.m_nPortNo; }
            set { this.m_nPortNo = value; }
        }

        /// <summary>
        /// 出力先テーブル情報配列 参照/設定用プロパティ
        /// </summary>
        public ArrayList CSIDllInfoList
        {
            get { return this.m_CSIDllInfoList; }
            set { this.m_CSIDllInfoList = new ArrayList(value); }
        }

        #endregion

        #region プライベートメソッド

        /// <summary>
        /// Socket Server用スレッド実行処理
        /// </summary>
        private void DoWork()
        {
            try
            {
                // socketサービスを作成する
                m_socketService.ServiceName = this.SERVICE_NAME;
                if (m_socketService.StartListener(null, m_nPortNo, 2))
                {
                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理開始");
                }
                else
                {
                    throw (new Exception(this.m_socketService.ServiceName + "待ち受け失敗"));
                }
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }

        /// <summary>
        /// クライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        private void ClientConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            if (Status == TdcBaseSocket.ConnectionStatus.CONNECT)
            {
                // 接続完了時

                if (Sender is TdcBaseSocketServerClient cl)
                {
                    isConnectFlg = true;

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "Client Socket Connected.[" + cl.GetConnectionString() + "]");
                }
            }
        }

        /// <summary>
        /// クライアントソケット受信時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cData">受信バッファ</param>
        /// <param name="nRecieveSize">受信byte数</param>
        private void ClientReceived(Object Sender, Byte[] cData, int nRecieveSize)
        {
            Dictionary<String, String> tbl = new Dictionary<string, string>();
            String initializeCoopPath = "";
            String initializeCoopFileName = "";
            String sendResult = "000008NG";
            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
            // 応答フォーマット:データ長(6)+エラーコード(2)+エラーメッセージ(N)
            String reusltFormat = "{0:D6}{1}{2}";
            String errMsgFormat = "{0}:{1}:{2}";
            String errMsg = "";
            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
            XmlDocument xmlDoc = new XmlDocument();

            int count = 0;

            m_clientReceivedBuff = m_clientReceivedBuff.Concat(cData).ToArray();

            // 受信データ
            string strdata = Encoding.Default.GetString(m_clientReceivedBuff, 0, m_clientReceivedBuff.Length);

            try
            {
                count = int.Parse(strdata.Substring(0, 6));
            }
            catch (Exception ex)
            {
                m_clientReceivedBuff = new Byte[0];

                if (isConnectFlg)
                {
                    isConnectFlg = false;

                    // ログ記録
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:受信に失敗しました.[" + strdata + "]");

                    // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                    errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "受信電文の共通部のサイズが規定より短い、または、電文長に数値以外の文字が設定されている。");
                    sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                    // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                    this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                }

                return;
            }

            isConnectFlg = false;

            if (count > m_clientReceivedBuff.Length)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:受信に失敗しました.[" + strdata + "]");
                // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "電文長に設定している値と実際に受信した電文サイズが異なる。");
                sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                return;
            }

            m_clientReceivedBuff = new Byte[0];

            if (strdata.Length >= 8)
            {
                strdata = strdata.Substring(8);
            }

            // 受信データがJSONか
            if (TdcLib.JSONLib.IsJSONData(strdata))
            {
                // JSON分解
                tbl = TdcLib.JSONLib.JSONtoData(strdata);

                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:データ生成に成功しました.");

                // モードフラグ取得
                if (tbl.ContainsKey("Protocol") == true)
                {
                    if ("filesocket".Equals(tbl["Protocol"]))
                    {
                        // Coopファイルパス取得
                        if (tbl.ContainsKey("CoopXmlDataPath") == true)
                        {
                            initializeCoopPath = tbl["CoopXmlDataPath"];
                        }

                        // Coopファイル名取得
                        if (tbl.ContainsKey("CoopXmlDataFileName") == true)
                        {
                            initializeCoopFileName = tbl["CoopXmlDataFileName"];
                        }

                        if (String.IsNullOrEmpty(initializeCoopPath) || String.IsNullOrEmpty(initializeCoopFileName))
                        {
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:Coopのファイルパス／ファイル名に取得に失敗しました.initializeCoopFilePath:[" + initializeCoopPath + "] initializeCoopFileName:" + initializeCoopFileName + "]");
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                            errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "受信電文にCoopのファイルパス／ファイル名に取得に失敗しました。initializeCoopFilePath:[" + initializeCoopPath + "] initializeCoopFileName: " + initializeCoopFileName + "]");
                            sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                            this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                            return;
                        }

                        // initializeCoopファイルを取得する
                        if (GetFileByFtp(path + LocalFolder, initializeCoopPath, initializeCoopFileName) == false)
                        {
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:initializeCoopファイルの取得に失敗しました.");
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                            errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "initializeCoopファイルの取得に失敗しました。initializeCoopFilePath:[" + initializeCoopPath + "] initializeCoopFileName: " + initializeCoopFileName + "]");
                            sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                            this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                            return;
                        }

                        sendCsiFileName = initializeCoopFileName;

                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "データ同期:initializeCoopファイルの取得に成功しました.");

                        xmlDoc.Load(path + LocalFolder + initializeCoopFileName);
                    }
                    else if ("headsocket".Equals(tbl["Protocol"]))
                    {
                        if (tbl.ContainsKey("Dump") == true)
                        {
                            xmlDoc.LoadXml(tbl["Dump"]);

                            String messageDump = String.Format("データ同期:Dump[{0}]", tbl["Dump"]);
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, messageDump);
                        }
                        else
                        {
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:dump電文の取得に失敗しました.");
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                            errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "受信電文にdump内容の取得に失敗しました。");
                            sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                            // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                            this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                            return;
                        }
                    }

                    Fn3ReturnCode retCode = null;
                    lock(m_lockObject)
                    {
                        retCode = CoopExec(xmlDoc);
                    }

                    // mod 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                    //if (retCode.IsSuccess || retCode.IsWarning)
                    //{
                    //    sendResult = "000008OK";
                    //} 
                    //else
                    //{
                    //    sendResult = "000008NG";
                    //}
                    errMsg = String.Format(errMsgFormat, ERR_FN3, retCode.ErrorCode, retCode.Message);
                    if (retCode.IsSuccess || retCode.IsWarning)
                    {
                        sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "OK", errMsg);
                    }
                    else
                    {
                        sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                    }
                    // mod 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end

                }
                else
                {
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:モードフラグの取得に失敗しました.");
                    // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                    errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "受信電文にモードフラグ[Protocol]の取得に失敗しました。");
                    sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                    // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
                    this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
                    return;
                }
            }
            else
            {
                // ログ記録
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, "データ同期:受信に失敗しました.[" + strdata + "]");
                // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 start
                errMsg = String.Format(errMsgFormat, ERR_CSI, "9999", "受信電文のJSON部分はの取得に失敗しました。");
                sendResult = String.Format(reusltFormat, Encoding.Default.GetByteCount(errMsg)+8, "NG", errMsg);
                // add 2023-03-02 bug #6633 CSI連携のエラー内容が分からない 孫 end
            }

            this.m_socketService.AllSend(Encoding.Default.GetBytes(sendResult));
        }

        private Fn3ReturnCode CoopExec(XmlDocument xmlDoc)
        {
            Fn3ReturnCode retCode = null;

            if ("true".Equals(FNSiCSISetting.DebugMode))
            {
                retCode = this.DebugModeExecute(xmlDoc);
            }
            else
            {
                // Log読み込み
                retCode = this.SetLogInfo(xmlDoc);
                if (!retCode.IsSuccess)
                {
                    return retCode;
                }

                // CSIDllFile読み込み
                this.LoadCSIDllFile(xmlDoc);

                //初期設定のインスタンス化＆スタート

                // InitializeCoopDll
                retCode = this.InitializeCoopExec(xmlDoc);

                // StartCoopDll
                if (retCode.IsSuccess || retCode.IsWarning)
                {
                    retCode = this.StartCoopExec();
                }

                // ExecuteCoopDll
                if (isExecuteFlg && (retCode.IsSuccess || retCode.IsWarning))
                {
                    retCode = this.ExecuteCoopExec(xmlDoc);
                }

                this.StopCoopExec();
                this.ReleaseCoopExec();
            }

            return retCode;
        }

        private Fn3ReturnCode InitializeCoopExec(XmlDocument xmlDoc)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            if (m_iPlugin != null)
            {
                XmlNode coopinfos = xmlDoc.SelectSingleNode("coop_info");
                // 施設コード
                // 施設コード
                String facilityCd = "unknown";
                if (coopinfos != null && coopinfos["facility_cd"] != null)
                {
                    facilityCd = coopinfos["facility_cd"].InnerText;
                    if (String.IsNullOrEmpty(facilityCd))
                    {
                        facilityCd = "unknown";
                    }
                }
                // 通信先系列施設コード
                m_iPlugin.ConnectSeriesCode = facilityCd;
                // 系列施設運用モード
                m_iPlugin.SeriesPracticeMode = SeriesPracticeModeType.NOTSUPPORTED;

                // アラーム送信通知デリゲートを取得または設定します。
                m_iPlugin.SendAlarmDelegate = m_dgtAlarm.SendMessage;

                // この連携を初期化する。
                retCode = m_iPlugin.InitializeCooperation(ChangeXmlToInitializeXml(xmlDoc));
            }
            return retCode;
        }

        private Fn3ReturnCode StartCoopExec()
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            if (m_iPlugin != null)
            {
                retCode = m_iPlugin.StartCooperation();
            }
            return retCode;
        }

        private Fn3ReturnCode ExecuteCoopExec(XmlDocument xmlDoc)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;
            if (m_iPlugin != null)
            {
                retCode = m_iPlugin.ExecuteCooperation(ChangeXmlToExecuteXml(xmlDoc));
            }

            return retCode;
        }

        private void StopCoopExec()
        {

            if (m_iPlugin != null)
            {
                m_iPlugin.StopCooperation();
            }
        }

        private void ReleaseCoopExec()
        {
            if (m_iPlugin != null)
            {
                m_iPlugin.ReleaseCooperation();
            }
        }

        /// <summary>
        /// CSIDllFile読み込み
        /// </summary>
        private void LoadCSIDllFile(XmlDocument xmlDoc)
        {
            try
            {
                XmlNode coopinfos = xmlDoc.SelectSingleNode("coop_info");

                csiDllName = "";
                m_functionDllName = "";
                m_keyInfo = "";
                isExecuteFlg = false;

                switch (coopinfos["coop_cd"].InnerText)
                {
                    case "profile":
                        csiDllName = "CSICoopPatientRcvStd";
                        m_functionDllName = "患者プロファイル";
                        m_keyInfo = ChangeXmlToKeyInfoXml(coopinfos);
                        isExecuteFlg = true;

                        break;
                    case "exam_ord":
                        csiDllName = "CSICoopExaminScheSendStd";
                        m_functionDllName = "検査オーダ";
                        m_keyInfo = ChangeXmlToKeyInfoXml(coopinfos);
                        isExecuteFlg = true;
                        break;
                    case "exam_rst":
                        csiDllName = "CSICoopExaminRcvStd";
                        m_functionDllName = "検査結果";
                        m_keyInfo = "";
                        isExecuteFlg = true;
                        break;

                    case "rep_dial":
                        csiDllName = "CSICoopDialysisReportSendStd";
                        m_functionDllName = "透析レポート";
                        m_keyInfo = ChangeXmlToKeyInfoXml(coopinfos);
                        isExecuteFlg = true;
                        break;

                    case "rst_dial":
                        csiDllName = "CSICoopDialysisSendStd";
                        m_functionDllName = "透析実績";
                        m_keyInfo = ChangeXmlToKeyInfoXml(coopinfos);
                        isExecuteFlg = true;
                        break;

                    case "ind_dial":
                        csiDllName = "CSICoopDialysisScheSendStd";
                        m_functionDllName = "透析予約";
                        m_keyInfo = ChangeXmlToKeyInfoXml(coopinfos);
                        isExecuteFlg = true;
                        break;

                    default:
                        csiDllName = "";
                        m_functionDllName = "";
                        m_keyInfo = "";
                        isExecuteFlg = false;
                        break;
                }

                foreach (Fn3ComPlugIn iPlugin in this.CSIDllInfoList)
                {
                    if (iPlugin.GetType().Name.IndexOf(csiDllName) >= 0)
                    {
                        m_iPlugin = iPlugin;
                        setComPlugInInitProperty(coopinfos);
                        break;
                    }

                }
            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, String.Format("LoadCSIDllFile,{0}", ex.Message));
            }
        }

        private Fn3ReturnCode DebugModeExecute(XmlDocument xmlDocPara)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            try
            {
                // CSIDllFile読み込み
                this.LoadCSIDllFile(xmlDocPara);

                if ("患者プロファイル".Equals(m_functionDllName) || "検査結果".Equals(m_functionDllName))
                {
                    XmlDocument xmlDoc = new XmlDocument();
                    xmlDoc.Load(FNSiCSISetting.DataFolder + csiDllName + "\\" + "Output" + "\\" + csiDllName + "_Output.xml");

                    FNSiSocketClient webDataGetAll = new FNSiSocketClient();
                    // IFエッジサービスのIP
                    webDataGetAll.IFEdgeIPAddress = FNSiCSISetting.IFEdgeIPAddress;
                    // IFエッジサービスのポートNo
                    if ("患者プロファイル".Equals(m_functionDllName))
                    {
                        webDataGetAll.IFEdgePortNo = FNSiCSISetting.IFEdgePatientPortNo;
                    }
                    else if ("検査結果".Equals(m_functionDllName))
                    {
                        webDataGetAll.IFEdgePortNo = FNSiCSISetting.IFEdgeExaminPortNo;
                    }
                    else
                    {
                        webDataGetAll.IFEdgePortNo = FNSiCSISetting.IFEdgePatientPortNo;
                    }

                    // 入力XML
                    webDataGetAll.ToUpdateXml = xmlDoc.OuterXml;

                    webDataGetAll.DoWork();

                    String messageDump = String.Format("OutputData:[{0}]", xmlDoc.OuterXml);
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, messageDump);
                }
            }
            catch (Exception ex)
            {
                retCode = Fn3ReturnCode.Error;
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, ex.Message);
            }

            return retCode;
        }

        private void setComPlugInInitProperty(XmlNode coopinfos)
        {
            m_iPlugin.OutLogDelegate = m_LogManager.OutLog;
        }

        /// <summary>
        /// CoopoXml変更
        /// </summary>
        /// <param name="inXmlDoc">Xml</param>
        /// /// <returns>
        /// CoopoXmlを返す。
        /// </returns>
        private string ChangeXmlToInitializeXml(XmlDocument inXmlDoc)
        {
            StringWriter str = new StringWriter();
            XmlWriter writer = new XmlTextWriter(str);
            XmlNode coopinfos = inXmlDoc.SelectSingleNode("coop_info");
            writer.WriteStartElement("MST_COOP_ID");
            writer.WriteStartElement("COOP_ID");
            writer.WriteString(coopinfos["coop_cd"].InnerText);
            writer.WriteEndElement();
            writer.WriteStartElement("COOP_FUNCTION_NAME");
            writer.WriteString(m_functionDllName);
            writer.WriteEndElement();

            // IFエッジサービスのIP
            writer.WriteStartElement("IFEdgeIPAddress");
            writer.WriteString(FNSiCSISetting.IFEdgeIPAddress);
            writer.WriteEndElement();

            // IFエッジサービスのポートNo
            writer.WriteStartElement("IFEdgePortNo");

            if ("患者プロファイル".Equals(m_functionDllName))
            {
                writer.WriteString(FNSiCSISetting.IFEdgePatientPortNo.ToString());
            }
            else if ("検査結果".Equals(m_functionDllName))
            {
                writer.WriteString(FNSiCSISetting.IFEdgeExaminPortNo.ToString());
            }
            else
            {
                writer.WriteString(FNSiCSISetting.IFEdgePatientPortNo.ToString());
            }

            writer.WriteEndElement();

            // INI_DATA_FILE_PATH
            writer.WriteStartElement("SYS_COOP_INI_FILE_PATH");
            writer.WriteString(path + FNSiCSISetting.SysCoopIniFileName.ToString());
            writer.WriteEndElement();

            // INI_DATA
            XmlNode ini_Node = coopinfos["dump"].SelectSingleNode("//rootNode/SYS_COOP_INI_DATA");
            if (ini_Node != null && ini_Node.InnerText != "")
            {
                writer.WriteStartElement("SYS_COOP_INI_DATA");
                writer.WriteString(ini_Node.InnerXml);
                writer.WriteEndElement();
            }

            // EXEC_DATA
            XmlNode exec_Node = coopinfos["dump"].SelectSingleNode("//rootNode/SYS_COOP_EXEC_DATA");
            if (exec_Node != null && exec_Node.InnerText != "")
            {
                writer.WriteStartElement("SYS_COOP_EXEC_DATA");
                writer.WriteString(exec_Node.InnerXml);
                writer.WriteEndElement();
            }

            writer.WriteEndElement();

            WriteDataFile(path + LocalFolder, "CSI_Init_" + sendCsiFileName, str.ToString());

            return System.Web.HttpUtility.HtmlDecode(str.ToString());
        }

        /// <summary>
        /// CoopXml変更
        /// </summary>
        /// <param name="inXmlDoc">Xml</param>
        /// /// <returns>
        /// CoopoXmlを返す。
        /// </returns>
        private string ChangeXmlToExecuteXml(XmlDocument inXmlDoc)
        {
            StringWriter str = new StringWriter();
            XmlWriter writer = new XmlTextWriter(str);
            XmlNode coopinfos = inXmlDoc.SelectSingleNode("coop_info");

            // part1:イベント管理情報
            writer.WriteStartElement("COP_EVENT_MANAGE");

            // IFエッジサービスのIP
            writer.WriteStartElement("IFEdgeIPAddress");
            writer.WriteString(FNSiCSISetting.IFEdgeIPAddress);
            writer.WriteEndElement();

            // IFエッジサービスのポートNo
            writer.WriteStartElement("IFEdgePortNo");
            if ("患者プロファイル".Equals(m_functionDllName))
            {
                writer.WriteString(FNSiCSISetting.IFEdgePatientPortNo.ToString());
            }
            else if ("検査結果".Equals(m_functionDllName))
            {
                writer.WriteString(FNSiCSISetting.IFEdgeExaminPortNo.ToString());
            }
            else
            {
                writer.WriteString(FNSiCSISetting.IFEdgePatientPortNo.ToString());
            }

            writer.WriteEndElement();

            // 連携ID
            writer.WriteStartElement("COOP_ID");
            writer.WriteString(coopinfos["coop_cd"].InnerText);
            writer.WriteEndElement();

            // 特定キー
            writer.WriteStartElement("SPECIFIC_KEY");
            writer.WriteEndElement();

            // オーダ番号の取得用、採番した番号で、イベント管理情報XMLを更新
            writer.WriteStartElement("EVENT_SEQ_NUMBER");
            writer.WriteEndElement();

            // オーダ番号の取得用、採番した番号で、イベント管理情報XMLを更新
            writer.WriteStartElement("EVENT_OCCUR_DATE");
            writer.WriteEndElement();

            // イベント区分
            writer.WriteStartElement("EVENT_CLASS");
            if (coopinfos["crud"].InnerText != null)
            {
                if (coopinfos["crud"].InnerText == "C")
                {
                    writer.WriteString("0");
                }
                else if (coopinfos["crud"].InnerText == "U")
                {
                    writer.WriteString("1");
                }
                else if (coopinfos["crud"].InnerText == "D")
                {
                    writer.WriteString("2");
                }
                else
                {
                    writer.WriteString("");
                }
            }
            else
            {
                writer.WriteString("");
            }
            writer.WriteEndElement();

            // 処理フラグ
            writer.WriteStartElement("PROC_FLG");
            writer.WriteEndElement();

            // オーダ番号
            writer.WriteStartElement("ORDER_NUMBER");
            writer.WriteString(coopinfos["coop_ord_no"].InnerText);
            writer.WriteEndElement();

            // 連携機能名
            writer.WriteStartElement("COOP_FUNCTION_NAME");
            writer.WriteString(m_functionDllName);
            writer.WriteEndElement();

            // 予備
            writer.WriteStartElement("RESERVE");
            writer.WriteEndElement();

            // 系列施設コード
            writer.WriteStartElement("SERIES_CD");
            writer.WriteEndElement();

            // イベントグループ番号
            writer.WriteStartElement("EVENT_GROUP_NO");
            writer.WriteEndElement();

            // "0":新規区分、その他:変更もしくは削除区分
            writer.WriteStartElement("BASE_EVENT_CLASS");
            writer.WriteEndElement();

            // メモ
            writer.WriteStartElement("MEMO");
            // TODO CNC START
            writer.WriteString("MST_COOP_ID.xml");
            // TODO CNC END
            writer.WriteEndElement();

            // 予備
            writer.WriteStartElement("RESERVE");
            writer.WriteEndElement();

            // キー情報
            writer.WriteStartElement("KEY_INFO");
            writer.WriteString(System.Web.HttpUtility.HtmlDecode(m_keyInfo));
            writer.WriteEndElement();

            //  part2:送信履歴情報
            writer.WriteStartElement("EVENT_COOP_SEND_HST");

            writer.WriteString("<rootNode>");
            writer.WriteString("<COP_COOP_SEND_HST>");
            // 送信区分(処理区分)
            writer.WriteString("<SEND_CLASS>");
            if (coopinfos["crud"].InnerText != null)
            {
                if (coopinfos["crud"].InnerText == "C")
                {
                    writer.WriteString("0");
                }
                else if (coopinfos["crud"].InnerText == "U")
                {
                    writer.WriteString("1");
                }
                else if (coopinfos["crud"].InnerText == "D")
                {
                    writer.WriteString("2");
                }
                else
                {
                    writer.WriteString("");
                }
            }
            else
            {
                writer.WriteString("");
            }
            writer.WriteString("</SEND_CLASS>");

            // 送信ステータス
            writer.WriteString("<SEND_STATE>");
            writer.WriteString("</SEND_STATE>");

            // 送信版数
            writer.WriteString("<SEND_VERSION>");
            writer.WriteString("</SEND_VERSION>");

            // メモ
            writer.WriteString("<MEMO>");
            // TODO CNC START
            writer.WriteString(coopinfos["coop_ord_no"].InnerText);
            // TODO CNC END
            writer.WriteString("</MEMO>");

            // 予備
            writer.WriteString("<RESERVE>");
            writer.WriteString("</RESERVE>");
            writer.WriteString("</COP_COOP_SEND_HST>");
            writer.WriteString("</rootNode>");

            writer.WriteEndElement();

            //  part3:連携情報
            writer.WriteStartElement("EVENT_COOP_INFO");
            writer.WriteString(coopinfos["dump"].InnerXml);
            writer.WriteEndElement();
            writer.WriteEndElement();

            WriteDataFile(path + LocalFolder, "CSI_Data_" + sendCsiFileName, str.ToString());

            return System.Web.HttpUtility.HtmlDecode(str.ToString());
        }

        /// <summary>
        /// CoopKeyInfoXml変更
        /// </summary>
        /// <param name="coopinfos">XmlNode</param>
        /// /// <returns>
        /// CoopoXmlを返す。
        /// </returns>
        private string ChangeXmlToKeyInfoXml(XmlNode coopinfos)
        {
            StringWriter str = new StringWriter();
            XmlWriter writer = new XmlTextWriter(str);

            switch (csiDllName)
            {
                case "CSICoopPatientRcvStd":
                    writer.WriteString("<");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    writer.WriteString(coopinfos["hosp_pat_id"].InnerText);
                    writer.WriteString("</");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    break;

                case "CSICoopExaminScheSendStd":
                    // TODO
                    writer.WriteString("<");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    writer.WriteString(coopinfos["dump"].InnerXml);
                    writer.WriteString("</");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    break;

                case "CSICoopDialysisSendStd":
                    // TODO
                    XmlNode xmlNode = coopinfos["dump"].SelectSingleNode("//rootNode/PAT_BASIC_INFO");
                    writer.WriteString("<");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    writer.WriteString(xmlNode.InnerXml);
                    writer.WriteString("</");
                    writer.WriteString(m_functionDllName);
                    writer.WriteString(">");
                    break;

                default:
                    writer.WriteString("");
                    break;
            }

            return str.ToString();
        }

        /// <summary>
        /// ファイルを取得する
        /// </summary>
        /// <param name="localPath">Localパス</param>
        /// <param name="sourceFilePath">ファイルパス</param>
        /// <param name="sourceFileName">ファイル名</param>
        /// <returns></returns>
        private Boolean GetFileByFtp(String localPath, String sourceFilePath, String sourceFileName)
        {
            try
            {
                FNSiFtpClient ftpCLient = new FNSiFtpClient(FNSiCSISetting.FtpIPAddress, FNSiCSISetting.FtpPortNo,
                    FNSiCSISetting.FtpUserId, FNSiCSISetting.FtpPW);

                ftpCLient.FtpPath = sourceFilePath;
                ftpCLient.FtpFileName = sourceFileName;
                ftpCLient.LocalPath = localPath;
                ftpCLient.LocalFileName = sourceFileName;

                if (ftpCLient.GetData() == false)
                {
                    return false;
                }
            }
            catch (Exception ex)
            {
                this.Error = ex;

                return false;
            }

            return true;
        }

        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        private Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    this.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
                }
            }
        }

        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, SERVICE_NAME, LoggingClass, strMesssage);
        }

        private LogSetting ReadConfigLog()
        {
            LogSetting LogSet = new LogSetting();
            try
            {
                if (String.IsNullOrEmpty(FNSiCSISetting.LogFolder))
                {
                    LogSet.traceFolder = path + "LOG";
                    LogSet.errorFolder = path + "LOG";
                }
                else
                {
                    LogSet.traceFolder = FNSiCSISetting.LogFolder;
                    LogSet.errorFolder = FNSiCSISetting.LogFolder;
                }

                LogSet.traceFile = ConfigurationManager.AppSettings["TraceFile"];
                LogSet.traceSize = GetFileSize(ConfigurationManager.AppSettings["TraceSize"]);
                LogSet.traceNumber = int.Parse(ConfigurationManager.AppSettings["TraceNumber"]);
                LogSet.traceSpan = GetFileSpan(ConfigurationManager.AppSettings["TraceSpan"]);
                LogSet.traceIsZip = bool.Parse(ConfigurationManager.AppSettings["TraceIsZip"]);

                LogSet.errorFile = ConfigurationManager.AppSettings["ErrorFile"];
                LogSet.errorSize = GetFileSize(ConfigurationManager.AppSettings["ErrorSize"]);
                LogSet.errorNumber = int.Parse(ConfigurationManager.AppSettings["ErrorNumber"]);
                LogSet.errorSpan = GetFileSpan(ConfigurationManager.AppSettings["ErrorSpan"]);
                LogSet.errorIsZip = bool.Parse(ConfigurationManager.AppSettings["ErrorIsZip"]);

            }
            catch//(Exception e)
            {
                //ログ出力不可
            }
            return LogSet;
        }

        /// <summary>
        /// 設定ファイルからサイズの値を作成 
        /// </summary>
        /// <param name="size">サイズを表す文字列</param>
        /// <returns>数値変換されたサイズ</returns>
        private static int GetFileSize(string size)
        {
            string buf = size.Replace(",", "");
            int MB = buf.ToUpper().IndexOf("MB");
            int KB = buf.ToUpper().IndexOf("KB");

            if (MB == (buf.Length - 2))
            {
                buf = buf.Substring(0, MB);
                MB = 1024 * 1024;
                KB = 1;
            }
            else if (KB == (buf.Length - 2))
            {
                buf = buf.Substring(0, KB);
                MB = 1;
                KB = 1024;
            }
            else
            {
                MB = 1;
                KB = 1;
            }

            int work;
            if (true == int.TryParse(buf, out work))
            {
                return work * MB * KB;
            }
            else
            {
                return 1 * 1024 * 1024;
            }
        }

        /// <summary>
        /// 設定ファイルからファイル保持期間を作成 
        /// </summary>
        /// <param name="span">保持期間を表す文字列</param>
        /// <returns>保持期間に変換された期間</returns>
        private static TimeSpan GetFileSpan(string span)
        {
            TimeSpan work;
            if (TimeSpan.TryParse(span, out work))
            {
                return work;
            }
            else
            {
                return TimeSpan.Zero;
            }
        }

        /// <summary>
        /// ファイルを作成する
        /// </summary>
        /// <param name="localPath">Localパス</param>
        /// <param name="sourceFileName">ファイル名</param>
        /// <param name="dataBuff">ファイル内容</param>
        /// <returns></returns>
        private Boolean WriteDataFile(String localPath, String sourceFileName, String dataBuff)
        {
            try
            {
                FileStream streamWrite = new FileStream(localPath + sourceFileName, FileMode.OpenOrCreate, FileAccess.Write);
                byte[] buffer = Encoding.Default.GetBytes(dataBuff);
                streamWrite.Write(buffer, 0, buffer.Length);
                streamWrite.Close();
            }
            catch (Exception ex)
            {
                this.Error = ex;

                return false;
            }

            return true;
        }

        private Fn3ReturnCode SetLogInfo(XmlDocument xmlDoc)
        {
            Fn3ReturnCode retCode = Fn3ReturnCode.Success;

            // ログ設定
            LogSetting logSet;
            logSet = ReadConfigLog();

            try
            {
                XmlNode coopinfos = xmlDoc.SelectSingleNode("coop_info");

                // 施設コード
                String facilityCd = "unknown";
                if (coopinfos != null && coopinfos["facility_cd"] != null)
                {
                    facilityCd = coopinfos["facility_cd"].InnerText;
                    if (String.IsNullOrEmpty(facilityCd))
                    {
                        facilityCd = "unknown";
                    }
                }

                // 電文種別
                String coopName = "unknown"; 
                if (coopinfos != null && coopinfos["coop_cd"] != null)
                {
                    coopName = coopinfos["coop_cd"].InnerText;
                    if (String.IsNullOrEmpty(coopName))
                    {
                        coopName = "unknown";
                    }
                }

                // 患者番号
                String hospPatId = "unknown";
                if (coopinfos != null && coopinfos["hosp_pat_id"] != null)
                {
                    hospPatId = coopinfos["hosp_pat_id"].InnerText;
                    if (String.IsNullOrEmpty(hospPatId))
                    {
                        hospPatId = "unknown";
                    }
                }

                //ログクラスのインスタンス
                m_LogManager = CoopLogManager.getInstance();

                // ログ設定
                m_LogManager.SetLogSetting = logSet;
                m_LogManager.LogManagerInit();

                //初期設定のインスタンス化＆スタート
                m_IniDATA = new InitialDataManager();

                // 初期設定のインスタンスを設定
                // 通信ログ-出力先パス
                m_IniDATA.DmpOutputPath = String.IsNullOrEmpty(FNSiCSISetting.LogFolder)?(path + "LOG") : FNSiCSISetting.LogFolder;
                // 通信ログ-出力先ファイル名
                //m_IniDATA.DmpOutputFilename = hospPatId + "_" + coopName + "_" + DateTime.Now.ToString("yyyyMMddHHmmss");
                m_IniDATA.DmpOutputFilename = facilityCd + "_" + hospPatId;

                // 通信ログ-保存期間
                int month = (int)(FNSiCSISetting.LogKeepNumberOfDays / 30);
                m_IniDATA.DmpInterval = (month>0)? month.ToString() : "1";
                // 通信ログ-ログ種別
                m_IniDATA.MinOutputLevel = "1";

                // ログクラス初期設定取得
                m_LogManager.setdgtGetInitialData = m_IniDATA.GetData;

                //ログ初期化失敗時
                if (m_LogManager.Initialize() == false)
                {
                    this.Error = new Exception("ログクラス初期化失敗。");
                    return Fn3ReturnCode.Error;
                }

                // --------------------------------
                // アラームクラス　インスタンス生成
                // --------------------------------
                m_dgtAlarm = AlarmManager.GetInstance();
                // ログ出力設定
                m_dgtAlarm.setdgtOutLog = m_LogManager.OutLog;
                // 連携初期設定取得クラス設定
                m_dgtAlarm.setdgtGetInitialData = m_IniDATA.GetData;
                m_dgtAlarm.SeriesPracticeMode = SeriesPracticeModeType.NOTSUPPORTED; ;
                m_dgtAlarm.LocalSeriesCode = facilityCd;
                m_dgtAlarm.TargetSeriesCode = facilityCd;

                //アラーム初期化失敗時
                m_dgtAlarm.Initialize();
                if (m_dgtAlarm.Initialize() == false)
                {
                    this.Error = new Exception("アラーム初期化失敗。");
                    return Fn3ReturnCode.Error;
                }
            }
            catch (Exception ex)
            {
                this.Error = ex;

                return Fn3ReturnCode.Exception;
            }
            return retCode;
        }

        #endregion
    }
}
