//----------------------------------------------------------------------------------------------------
//  TDC製ベースソケットサーバー処理クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.IO;
using System.Data;
using System.Net;
using System.Net.Sockets;
using System.Net.NetworkInformation;
//using System.Net.Security;
using System.Collections.Generic;
using System.Text;
using System.Text.RegularExpressions;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcSocketLib
//----------------------------------------------------------------------------------------------------
namespace TdcSocketLib
{

#region デリゲート定義
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// サーバー内クライアントオブジェクト接続時許可判定用デリゲート定義
    /// </summary>
    /// <param name="Soc">接続要求ソケットオブジェクト</param>
    /// <param name="bConnected">内部接続許可リスト判定結果</param>
    /// <returns>true：接続許可/false：接続不許可</returns>
    //----------------------------------------------------------------------------------------------------
    public delegate bool dgtTdcBaseSocketServerConnectionPermission(Socket Soc, bool bConnected);
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// サーバー内クライアントオブジェクト接続件数オーバー時報告用デリゲート定義
    /// </summary>
    /// <param name="Soc">切断するソケットオブジェクト</param>
    //----------------------------------------------------------------------------------------------------
    public delegate void dgtTdcBaseSocketServerConnectionCountOver(Socket Soc);
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// サーバー内クライアントオブジェクト接続判定結果報告用デリゲート定義
    /// </summary>
    /// <param name="Soc">接続要求ソケットオブジェクト</param>
    /// <param name="nResult">接続判定結果[]</param>
    //----------------------------------------------------------------------------------------------------
    public delegate void dgtTdcBaseSocketServerAccepted(Socket Soc, int nResult);
    //----------------------------------------------------------------------------------------------------
#endregion

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// TDC製ベースソケットサーバー処理クラス定義
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class TdcBaseSocketServer
    {
#region 接続制限定義
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限種類
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public enum CONNECTION_LIMIT_TYPE
        {

            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 制限しない
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            NON = 0,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// IPアドレス
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            IP_ADDRESS_MODE,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// ソケット
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            SOCKET_MODE
            //----------------------------------------------------------------------------------------------------
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限方法
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public enum CONNECTION_LIMIT_MODE
        {
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 古い接続を切断
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            OLD_DISCONNECTION = 0,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 新しい接続を切断
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            NEW_DISCONNECTION,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 最終処理TickCount値が古い接続を切断
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            OLD_TICKCOUNT_DISCONNECTION
            //----------------------------------------------------------------------------------------------------
        }
        //----------------------------------------------------------------------------------------------------
        #endregion

#region プライベート定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //private String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        private String m_strServiceName = "ServerSocket";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 任意データ保持用オブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Object m_objData = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 一時受信バッファーサイズ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nRecvBufferSize = 2000;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限数
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nConnectionLimitCount = 0;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限種類
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private CONNECTION_LIMIT_TYPE m_ConnectionLimitType = CONNECTION_LIMIT_TYPE.NON;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限方法
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private CONNECTION_LIMIT_MODE m_ConnectionLimitMode = CONNECTION_LIMIT_MODE.OLD_TICKCOUNT_DISCONNECTION;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバッグモードフラグ[0：なし/1：履歴記録/2：詳細履歴記録]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nDebugMode = 0;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 待ち受け停止フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bListnerStop = true;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 待ち受け用ソケット
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected internal Socket m_socListener = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内接続クライアントオブジェクト一覧
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected internal List<Object> m_Clients = new List<Object>();
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続許可アドレス一覧[接続判定処理は正規表現クラスにて実施]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String[] m_strConnectionPermissionIPAddress = new String[] { };
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト接続時接続許可判定通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketServerConnectionPermission m_dgtClientConnectionPermissionHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト接続件数オーバー時通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketServerConnectionCountOver m_dgtClientConnectionCountOverHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト接続判定結果通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketServerAccepted m_dgtClientAcceptedHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト接続/切断通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketConnected m_dgtClientConnectedHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト非同期送信完了通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketSendCompleted m_dgtClientSendCompletedHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト受信時通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketReceived m_dgtClientReceivedHandler = null;
        //----------------------------------------------------------------------------------------------------
#endregion

#region パブリックプロパティ
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前に発生したエラーオブジェクト取得/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Exception Error
        {
            get { return (this.m_Exception); }
            set
            {
                m_Exception = value;

                if (value != null)
                {
                    // ログ記録クラス取得
                    NKKLogging log = NKKLogging.GetInstance();

                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strservice = this.ServiceName;
                    String strlogdata = String.Format("TdcSocketLib:{0}", this.GetType().Name);

                    // 履歴作成
                    strlogdata += "," + TdcBaseSocket.GetConnectionString( (IPEndPoint)this.m_socListener.RemoteEndPoint ) + ",";
                    strlogdata += String.Format("{0}", value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(strservice + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログに記録されるサービス名設定/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String ServiceName
        {
            get { return (this.m_strServiceName); }
            set { this.m_strServiceName = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアント受信バッファーサイズ参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int ClientRecvBufferSize
        {
            get { return (this.m_nRecvBufferSize); }
            set { this.m_nRecvBufferSize = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デバッグモードフラグ参照/設定用プロパティ[0：なし/1：履歴記録/2：詳細履歴記録]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int DebugMode
        {
            get { return (this.m_nDebugMode); }
            set { this.m_nDebugMode = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続許可アドレス一覧参照/設定用プロパティ[接続判定処理は正規表現クラスにて実施]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String[] ConnectionPermissionIPAddress
        {
            get { return (this.m_strConnectionPermissionIPAddress); }
            set { this.m_strConnectionPermissionIPAddress = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限数参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int ConnectionLimitCount
        {
            get{ return( this.m_nConnectionLimitCount ); }
            set{this.m_nConnectionLimitCount = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限種類参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public CONNECTION_LIMIT_TYPE ConnectionLimitType
        {
            get{ return( this.m_ConnectionLimitType ); }
            set{ this.m_ConnectionLimitType = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続制限方法参照/設定用プロパティ
        /// </summary>
        public CONNECTION_LIMIT_MODE ConnectionLimitMode
        {
            get{ return(this.m_ConnectionLimitMode); }
            set{ this.m_ConnectionLimitMode = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 任意データ設定/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Object Data
        {
            get { return (this.m_objData); }
            set { this.m_objData = value; }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  サーバー内クライアントオブジェクト接続許可判定用イベントハンドラー登録/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketServerConnectionPermission ClientConnectionPermissionHandler
        {
            get { return (this.m_dgtClientConnectionPermissionHandler); }
            set { this.m_dgtClientConnectionPermissionHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  サーバー内クライアントオブジェクト接続件数オーバー時報告用イベントハンドラー登録/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketServerConnectionCountOver ClientConnectionCountOverHandler
        {
            get { return (this.m_dgtClientConnectionCountOverHandler); }
            set { this.m_dgtClientConnectionCountOverHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  サーバー内クライアントオブジェクト接続判定結果通知用イベントハンドラー登録/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketServerAccepted ClientAcceptedHandler
        {
            get { return (this.m_dgtClientAcceptedHandler); }
            set { this.m_dgtClientAcceptedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  サーバー内クライアントオブジェクト切断/切断通知用イベントハンドラー登録/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketConnected ClientConnectedHandler
        {
            get { return (this.m_dgtClientConnectedHandler); }
            set { this.m_dgtClientConnectedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内クライアントオブジェクト非同期送信完了通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketSendCompleted ClientSendCompletedHandler
        {
            get { return (this.m_dgtClientSendCompletedHandler); }
            set { this.m_dgtClientSendCompletedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  サーバー内クライアントオブジェクト受信時通知用イベントハンドラー登録/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketReceived ClientReceivedHandler
        {
            get { return (this.m_dgtClientReceivedHandler); }
            set { this.m_dgtClientReceivedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 待ち受け状態[true：待ち受け中/false：未待ち受け]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public bool IsListen
        {
            get 
            {
                bool bret = true;
                if (this.m_socListener == null)
                {
                    bret = false;
                }

                return (bret);
            }
            set { }
        }
        //----------------------------------------------------------------------------------------------------
#endregion


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public TdcBaseSocketServer()
        {
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~TdcBaseSocketServer()
        {
        }
        //----------------------------------------------------------------------------------------------------


#region パブリックメソッド
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー待ち受け処理開始
        /// </summary>
        /// <param name="strIPAddress">接続元IPアドレス(NICを限定する場合)</param>
        /// <param name="nPortNo">待ち受けポート番号</param>
        /// <param name="nBackLogCount">接続保留数</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public virtual bool StartListener(String strIPAddress, int nPortNo, int nBackLogCount)
        {
            return( this.StartListener( strIPAddress, nPortNo, nBackLogCount, 0 ));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー待ち受け処理開始
        /// </summary>
        /// <param name="strIPAddress">接続元IPアドレス(NICを限定する場合)</param>
        /// <param name="nPortNo">待ち受けポート番号</param>
        /// <param name="nBackLogCount">接続保留数</param>
        /// <param name="nConnectionLimitCount">接続可能最大数</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public virtual bool StartListener( String strIPAddress, int nPortNo, int nBackLogCount, int nConnectionLimitCount )
        {
            bool bret = false;

            // ログ記録クラス起動
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 既に待ち受け処理を行っている場合
                if (this.m_socListener != null)
                {
                    // 待ち受け処理停止
                    this.m_socListener.Close();
                }
                this.m_socListener = null;

                // 接続制限数
                if (0 < nConnectionLimitCount)
                {
                    this.m_nConnectionLimitCount = nConnectionLimitCount;
                }

                // ソケット構築
                this.m_socListener = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                // 接続元IPアドレス設定
                IPAddress ipaddr = null;

#region DNSサーバーを使用する場合
                /*

                IPAddress[] addrlists = null;
                  
                //// ホスト名からIPアドレスを取得する[.NET Framework 1.x]
                //IPHostEntry iphost = System.Net.Dns.GetHostEntry(Dns.GetHostName());
                //addrlists = iphost.AddressList;

                // ホスト名からIPアドレスを取得する[.NET Framework 2.0以降]
                addrlists = Dns.GetHostAddresses(Dns.GetHostName());

                // 接続元IPアドレスが設定されているかどうか
                if (String.IsNullOrEmpty(strIPAddress) == true)
                {
                    // 未設定

                    // すべてのPCアドレス                               
                    ipaddr = IPAddress.Any;

                    //// IPアドレス一覧取得
                    //foreach (IPAddress addr in addrlists)
                    //{
                    //    //
                    //    if (0 < strIPAddress.Length)
                    //        strIPAddress += "/";
                    //    strIPAddress += addr.ToString();

                    //}
                    strIPAddress = "すべて";
                }
                else
                {
                    // 設定済

                    // すべてのアドレス分
                    foreach (IPAddress addr in addrlists)
                    {
                        //// IPV6除去チェック
                        //if (ipinfo.Address.AddressFamily.Equals(AddressFamily.InterNetwork) == true )
                        // 指定されているIPかどうか
                        if ( addr.ToString().Equals(strIPAddress) == true)
                        {
                            // 該当あり

                            ipaddr = addr;
                            break;
                        }
                    }

                    // IPアドレス不備
                    if (ipaddr == null)
                    {
                        throw (new Exception(String.Format("待ち受けIPアドレス不備:{0}", stripaddr)));
                    }
                }
*/
#endregion

#region ネットワークインターフェースを使用する場合

                // 接続元IPアドレスが設定されているかどうか
                if (String.IsNullOrEmpty(strIPAddress) == true)
                {
                    // 未設定

                    // すべてのPCアドレス                               
                    ipaddr = IPAddress.Any;

                    // IPアドレス一覧取得

                    strIPAddress = "すべて";
                }
                else
                {
                    // 設定済

                    // すべてのネットワークインターフェース分
                    NetworkInterface[] adapters = NetworkInterface.GetAllNetworkInterfaces();
                    foreach (NetworkInterface adapter in adapters)
                    {
                        // ネットワークインターフェースが有効な場合
                        if (adapter.OperationalStatus.Equals(OperationalStatus.Up) == true)
                        {
                            // ネットワークアダプターのプロパティからIPアドレス取得
                            IPInterfaceProperties properties = adapter.GetIPProperties();
                            foreach (UnicastIPAddressInformation ipInfo in properties.UnicastAddresses)
                            {
                                //// IPV6除去チェック
                                //if (ipinfo.Address.AddressFamily.Equals(AddressFamily.InterNetwork) == true )
                                // 指定されているIPかどうか
                                if (ipInfo.Address.ToString().Equals(strIPAddress) == true)
                                {
                                    // 合致

                                    ipaddr = ipInfo.Address;

                                    break;
                                }
                            }
                        }
                    }

                    // IPアドレス不備
                    if (ipaddr == null)
                    {
                        throw (new Exception(String.Format("待ち受けIPアドレス不備:{0}", strIPAddress)));
                    }
                }
#endregion

                // バインド
                IPEndPoint iplocal = new IPEndPoint(ipaddr, nPortNo);
                this.m_socListener.Bind(iplocal);

                // 待ち受け停止を解除
                this.m_bListnerStop = false;

                // 接続イベント定義
                this.m_socListener.Listen(nBackLogCount);
                this.m_socListener.BeginAccept(new AsyncCallback(AcceptCallBack), this.m_socListener);

                // デバックモードが有効な場合
                if (0 < this.DebugMode)
                {
                    // 履歴に追記
                    strlogdata = String.Format("待ち受け開始,IP:{0},ポートNo:{1},最大接続保留許可数:{2}", strIPAddress, nPortNo, nBackLogCount);
                    if( 0 < this.m_nConnectionLimitCount )
                    {
                        strlogdata += String.Format(",最大接続許可数:{0}", this.m_nConnectionLimitCount );
                    }
                    log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
                }
#if DEBUG
                Debug.WriteLine(strlogdata);
#endif

                bret = true;
            }
            catch (Exception ex)
            {
                // 待ちうけ失敗

                throw (new Exception(String.Format("{0}", ex.Message.Replace("\r\n", "{CRLF}"))));
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー待ち受け処理停止
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void StopListner()
        {
            // ログ記録クラス起動
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 接続クライアント一覧取得
                Object[] list = null;
                lock (this.m_Clients)
                {
                    list = this.m_Clients.ToArray();
                }

                // 接続クライアントがある場合
                foreach (Object obj in list)
                {
                    if (obj is TdcBaseSocketServerClient cl)
                    {
                        // オブジェクト破棄
                        cl.Close();
                    }
                }

                // ソケット待ちうけオブジェクトが有効な場合
                if (this.m_socListener != null)
                {
                    // デバックモードが有効な場合
                    if (0 < this.DebugMode)
                    {
                        // IP、待ち受けポート番号取得
                        IPEndPoint ip = (IPEndPoint)this.m_socListener.LocalEndPoint;
                        String strip = ip.Address.ToString();
                        if (ip.Address == IPAddress.Any)
                        {
                            strip = "すべて";
                        }

                        // 履歴に追記
                        strlogdata = String.Format("待ち受け停止,IP:{0},ポートNo:{1}", strip, ip.Port);
                        log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
                    }
#if DEBUG
                    Debug.WriteLine(strlogdata);
#endif
                    // 待ち受け停止を設定
                    this.m_bListnerStop = true;

                    // ソケット待ちうけ終了
                    this.m_socListener.Close();
                }
            }
            catch (Exception ex)
            {
                throw ex;
            }
            finally
            {
                this.m_socListener = null;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// すべての接続ソケットへ一斉送信
        /// </summary>
        /// <param name="cData">送信データ</param>
        //----------------------------------------------------------------------------------------------------
        public virtual void AllSend(Byte[] cData)
        {
            try
            {
                // 切断一覧
                List<Object> dellist = new List<Object>();

                // 接続クライアント一覧を取得する
                List<Object> listclients = new List<Object>();
                lock (this.m_Clients)
                {
                    listclients.AddRange(this.m_Clients);
                }

                // 接続クライアントがある場合
                foreach (TdcBaseSocketServerClient cl in listclients)
                {
                    // 接続クライアントへ送信
                    if (cl.Write(cData) == false)
                    {
                        // 送信失敗

                        // 切断一覧に追加
                        dellist.Add(cl);
                    }
                }

                // 切断一覧がある場合
                if (0 < dellist.Count)
                {
                    foreach (TdcBaseSocketServerClient cl in dellist)
                    {
                        // 切断
                        cl.Close();
                    }
                }
            }
            catch
            {
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// すべての接続ソケットへ一斉非同期送信
        /// ※送信成功/失敗が必要な場合は構築時にClientSendCompletedHandlerの登録が必要
        /// </summary>
        /// <param name="cData">送信データ</param>
        //----------------------------------------------------------------------------------------------------
        public virtual void AsyncAllSend(Byte[] cData)
        {
            try
            {
                // 接続クライアント一覧を取得する
                List<Object> listclients = new List<Object>();
                lock (this.m_Clients)
                {
                    listclients.AddRange(this.m_Clients);
                }

                // 接続クライアントがある場合
                foreach (TdcBaseSocketServerClient cl in listclients)
                {
                    // 接続クライアントへ非同期送信
                    cl.AsyncWrite(cData);
                }
            }
            catch
            {
            }
        }
        //----------------------------------------------------------------------------------------------------
#endregion

#region Listenerイベント定義
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// IPアドレスによる接続許可チェック
        /// </summary>
        /// <param name="Soc">接続要求ソケット</param>
        /// <returns>true：接続許可/false：接続不許可</returns>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual bool CheckIPAccept(Socket Soc)
        {
            bool bret = true;

            // 接続許可判定
            try
            {
                // 接続元IPアドレス取得
                String straddr = ((IPEndPoint)(Soc.RemoteEndPoint)).Address.ToString();

                // 接続許可IPアドレスリストチェック
                if (0 < this.ConnectionPermissionIPAddress.Length)
                {
                    // 設定あり

                    bret = false;

                    // 設定分の照合
                    foreach (String strpattern in this.ConnectionPermissionIPAddress)
                    {
                        // 設定が有効な場合
                        if (String.IsNullOrEmpty(strpattern) == false)
                        {
                            // 正規表現によるパターンマッチング
                            Regex reg = new Regex(strpattern, RegexOptions.IgnoreCase);
                            if (reg.Match(straddr).Success == true)
                            {
                                // 合致あり

                                // 接続許可
                                bret = true;

                                break;
                            }
                        }
                    }
                }
                else
                {
                    // 設定なし

                    // 接続許可
                    bret = true;
                }

                // ログ記録クラス起動
                NKKLogging log = NKKLogging.GetInstance();

                // 履歴作成
                DateTime dtlog = DateTime.Now;
                String strservice = this.ServiceName;
                String strlogdata = String.Empty;

                // 履歴に追記
                if (bret == true)
                {
                    strlogdata = "IPアドレス接続許可";
                }
                else
                {
                    strlogdata = "IPアドレス接続不許可";
                }
                strlogdata += String.Format(",接続先IP: {0}", straddr);
                log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);

                // イベントハンドラーチェック
                if (this.ClientConnectionPermissionHandler != null)
                {
                    bret = this.ClientConnectionPermissionHandler(Soc, bret);
                }
            }
            catch
            {
            }

            return(bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続クライアントオブジェクト作成
        /// </summary>
        /// <returns>作成された接続クライアントオブジェクト</returns>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual TdcBaseSocketServerClient CreateClient()
        {
            // 接続クライアントオブジェクト構築
            TdcBaseSocketServerClient client = new TdcBaseSocketServerClient(this.ClientRecvBufferSize)
            {
                // 処理通知イベント設定

                // 接続/切断(終了)時イベント設定
                ConnectedHandler = this.ClientConnected,

                // 送信完了時イベント設定
                SendCompletedHandler = this.ClientSendCompleted,

                // 受信時イベント設定
                ReceivedHandler = this.ClientReceived
            };

            return (client);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続件数チェック処理
        /// </summary>
        /// <param name="Soc">接続するソケット</param>
        /// <returns>true：接続許可/false：接続不許可</returns>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual bool CheckConnectionCount(Socket Soc)
        {
            bool bret = true;

            try
            {
                // 接続制限実施判定
                if( this.ConnectionLimitType != CONNECTION_LIMIT_TYPE.NON && 0 < this.ConnectionLimitCount )
                {
                    // 接続制限がある場合

                    // 接続クライアント一覧を取得する
                    List<Object> listclients = new List<Object>();
                    lock (this.m_Clients)
                    {
                        listclients.AddRange(this.m_Clients);
                    }

                    TdcBaseSocketServerClient cl = null;
                    UInt32 ntickcountdiff = UInt32.MinValue;
                    List<Object> listdelcl = new List<Object>();

                    // ログ記録クラス起動
                    NKKLogging log = NKKLogging.GetInstance();

                    // 履歴作成
                    DateTime dtlog = DateTime.Now;
                    String strservice = this.ServiceName;
                    String strlogdata = String.Format(",待受:{0},", TdcBaseSocket.GetConnectionString((IPEndPoint)Soc.RemoteEndPoint));

                    // 接続制限種類判定
                    if ( this.ConnectionLimitType == CONNECTION_LIMIT_TYPE.SOCKET_MODE)
                    {
                        // ソケット制限

                        // 履歴
                        strlogdata += "ソケット接続許可件数";

                        // 接続制限数判定
                        if( this.ConnectionLimitCount <= listclients.Count )
                        {
                            // 履歴
                            strlogdata += String.Format("を超えました,接続件数:{0}→{1},接続許可件数:{2}", listclients.Count, listclients.Count + 1, this.ConnectionLimitCount);

                            // 接続制限以上の場合

                            // 接続制限方法判別
                            if( this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.OLD_DISCONNECTION )
                            {
                                // 古い接続を切断

                                cl = (TdcBaseSocketServerClient)listclients[0];

                                // 履歴
                                strlogdata += String.Format(",古いソケット接続を切断,{0}",cl.GetConnectionString());
                            }
                            else if( this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.NEW_DISCONNECTION)
                            {
                                // 新しい接続を切断

                                // 履歴
                                strlogdata += ",新しいソケット接続を切断";

                                bret = false;
                            }
                            else if (this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.OLD_TICKCOUNT_DISCONNECTION)
                            {
                                // TickCount値が古い接続を切断

                                // 最終処理TickCount値が古い(現在値からの差が大きい)を検索
                                foreach (TdcBaseSocketServerClient client in listclients)
                                {
                                    // 現在値との差算出
                                    UInt32 ntickcount = TdcLib.TdcLib.GetTickCountDiff(client.LastTickCount, (uint)System.Environment.TickCount);
                                    if( ntickcountdiff <= ntickcount )
                                    {
                                        cl = client;
                                        ntickcountdiff = ntickcount;
                                    }
                                }

                                // 履歴
                                strlogdata += String.Format(",最終処理TickCount値が古いソケット接続を切断,接続先:{0},TickCount差:{1}", cl.GetConnectionString(), ntickcountdiff);
                            }
                        }
                        else
                        {
                            // 接続制限内

                            strlogdata += String.Format("接続件数:{0}→{1},接続許可件数:{2}", listclients.Count, listclients.Count + 1, this.ConnectionLimitCount);
                        }
                    }
                    else  if( this.ConnectionLimitType == CONNECTION_LIMIT_TYPE.IP_ADDRESS_MODE)
                    {
                        // IPアドレス制限

                        String strdelip = String.Empty;

                        // 新しい接続のIPアドレスを取得
                        String strnewip = ((IPEndPoint)Soc.RemoteEndPoint).Address.ToString();

                        // 履歴
                        strlogdata += "IPアドレス接続許可件数";

                        // 接続しているIPアドレス一覧を作成
                        List<String> listip = new List<String>();
                        foreach (TdcBaseSocketServerClient client in listclients)
                        {
                            String strip = ((IPEndPoint)(client.Socket.RemoteEndPoint)).Address.ToString();
                            if( listip.Contains( strip ) == false )
                            {
                                listip.Add( strip );
                            }
                        }

                        // 接続制限数判定(＋新しいIPアドレスがリストにない場合)
                        if (this.ConnectionLimitCount <= listip.Count && listip.Contains(strnewip) == false)
                        {
                            // 履歴
                            strlogdata += String.Format("を超えました,接続件数:{0}→{1},接続許可件数:{2}", listip.Count, listip.Count + 1, this.ConnectionLimitCount);

                            // 接続制限以上の場合

                            // 接続制限方法判別
                            if( this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.OLD_DISCONNECTION )
                            {
                                // 古い接続を切断

                                // 切断対象となるIPアドレス取得
                                strdelip = listip[0];

                                // 履歴
                                strlogdata += String.Format(",古いIPアドレス接続を切断,接続先IP:{0}", strdelip);
                            }
                            else if (this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.NEW_DISCONNECTION)
                            {
                                // 新しい接続を切断

                                // 履歴
                                strlogdata += ",新しいソケット接続を切断";

                                bret = false;
                            }
                            else if (this.ConnectionLimitMode == CONNECTION_LIMIT_MODE.OLD_TICKCOUNT_DISCONNECTION)
                            {
                                // TickCount値が古い接続を切断

                                // 最終処理TickCount値が古い(現在値からの差が大きい)を検索
                                foreach (TdcBaseSocketServerClient client in listclients)
                                {
                                    // 現在値との差算出
                                    UInt32 ntickcount = TdcLib.TdcLib.GetTickCountDiff(client.LastTickCount, (uint)System.Environment.TickCount);
                                    if (ntickcountdiff <= ntickcount)
                                    {
                                        cl = client;
                                        ntickcountdiff = ntickcount;
                                    }
                                }

                                // 切断対象となるIPアドレス取得
                                strdelip = ((IPEndPoint)cl.Socket.RemoteEndPoint).Address.ToString();

                                // 履歴
                                strlogdata += String.Format(",最終処理TickCount値が古いソケットを持つIPアドレス接続を切断,接続先IP:{0},TickCount差:{1}", strdelip, ntickcountdiff);
                            }

                            // 切断対象となるIPアドレスがある場合
                            if (String.IsNullOrEmpty(strdelip) == false)
                            {
                                // 切断対象となるクライアント一覧を作成

                                // 同一IPアドレスのソケットを検索
                                foreach (TdcBaseSocketServerClient client in listclients)
                                {
                                    String strip = ((IPEndPoint)(client.Socket.RemoteEndPoint)).Address.ToString();
                                    if (strip == strdelip)
                                    {
                                        listdelcl.Add(client);

                                        // CLを消去
                                        cl = null;
                                    }
                                }
                            }
                        }
                        else
                        {
                            // 接続制限内

                            int ncount = listip.Count;
                            if (listip.Contains(strnewip) == false)
                            {
                                ncount++;
                            }
                            strlogdata += String.Format(",接続件数:{0}→{1},接続許可件数:{2}", listip.Count, ncount, this.ConnectionLimitCount);
                        }
                    }

                    // 履歴記録
                    log.AddLogInfo( dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);

                    // クライアント切断
                    // ソケット制限[1件]
                    if (cl != null)
                    {
                        // 切断するソケットを通知
                        this.ClientConnectionCountOverHandler?.Invoke(cl.Socket);

                        // 切断
                        cl.Close();
                    }
                    // IPアドレス制限[複数件]
                    foreach (TdcBaseSocketServerClient clwork in listdelcl)
                    {
                        // 切断するソケットを通知
                        this.ClientConnectionCountOverHandler?.Invoke(clwork.Socket);

                        // 切断
                        clwork.Close();
                    }
                }
            }
            catch(Exception ex )
            {
                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続処理
        /// </summary>
        /// <param name="Soc">接続するソケット</param>
        /// <param name="objClient">接続クライアントオブジェクト</param>
        /// <returns>0:接続許可/1:IPアドレス不許可/2:接続拒否(件数制限オーバー)</returns>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual int Accept(Socket Soc, ref Object objClient)
        {
            int intret = 1;

            // 接続クライアントオブジェクト作成
            TdcBaseSocketServerClient client = this.CreateClient();
            objClient = client;

            // IPアドレス接続許可判定
            if (this.CheckIPAccept(Soc) == true)
            {
                // 接続許可

                // 接続件数チェック処理
                if (this.CheckConnectionCount(Soc) == true)
                {
                    // 接続許可

                    intret = 0;
                }
                else
                {
                    // 接続拒否

                    intret = 2;
                }
            }

            // 接続許可/不許可判定
            if( intret == 0 )
            {
                // 接続許可

                // ソケット登録(+接続通知)
                client.SetSocket(ref Soc);
            }
            else
            {
                // 接続不許可

                // ソケット登録
                client.AssignSocket(ref Soc);

                // ソケット終了
                client.Close();
            }

            return (intret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続完了CallBack関数
        /// </summary>
        /// <param name="ar"></param>
        //----------------------------------------------------------------------------------------------------
        private void AcceptCallBack(IAsyncResult ar)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            // 待ち受け停止設定確認
            if (this.m_bListnerStop == false)
            {
                try
                {
                    Object client = null;

                    // 送受信用ソケット定義
                    Socket listner = (Socket)ar.AsyncState;
                    try
                    {
                        Socket soc = listner.EndAccept(ar);

                        // 接続許可判定処理
                        int intret = this.Accept(soc, ref client);

                        // イベント呼び出し
                        this.ClientAcceptedHandler?.Invoke(soc, intret);
                    }
                    catch (Exception ex)
                    {
                        // 履歴に追記
                        strlogdata = "接続失敗,内容:" + ex.Message.Replace("\r\n", "{CRLF}");
                        log.AddLogInfo( dtlog, strservice, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                        Debug.WriteLine(strservice + " " + strlogdata);
#endif

                        // 接続失敗通知
                        this.ClientConnected(client, TdcBaseSocket.ConnectionStatus.ERROR);
                    }
                }
                catch
                //catch (Exception ex)
                {
                    // リスナーソケット破棄時

                    // 履歴に追記
                    //strlogkind = "Error,";
                    //strlogdata = "Listener接続失敗,内容:" + ex.Message.Replace("\r\n", "{CRLF}");
                    //log.AddLogInfo(this.LogExt, dtlog, strlogkind + strlogdata);
#if DEBUG
                    Debug.WriteLine(strservice + " " + strlogdata);
#endif
                }
                finally
                {
                    try
                    {
                        // 待ちうけ再開
                        this.m_socListener.BeginAccept(new AsyncCallback(AcceptCallBack), this.m_socListener);

                        // デバッグありの場合
                        if (0 < this.DebugMode)
                        {
                            // IP、待ち受けポート番号取得
                            IPEndPoint ip = (IPEndPoint)this.m_socListener.LocalEndPoint;

                            // 履歴に追記
                            strlogdata = String.Format("待ち受け再開,IP:{0},ポートNo:{1}", ip.Address, ip.Port);
                            log.AddLogInfo( dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                            Debug.WriteLine(strservice + " " + strlogdata);
#endif
                        }
                    }
                    catch (Exception ex)
                    {
                        // リスナーソケット破棄時

                        // 履歴に追記
                        strlogdata = "Listener待ち受け再開失敗,内容:" + ex.Message.Replace("\r\n", "{CRLF}");
                        log.AddLogInfo( dtlog, strservice, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                        Debug.WriteLine(strservice + " " + strlogdata);
#endif
                    }
                }

            }
        }
        //----------------------------------------------------------------------------------------------------
#endregion

#region Clientイベント定義
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内接続クライアントオブジェクト接続/切断(終了)時に呼び出されるイベント
        /// </summary>
        /// <param name="Sender">サーバー内接続クライアントオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual void ClientConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            try
            {
                if (Sender is TdcBaseSocketServerClient cl)
                {
                    // 接続クライアント一覧
                    List<Object> listclients = new List<Object>();

                    lock (this.m_Clients)
                    {
                        // 接続状態判定
                        if (Status == TdcBaseSocket.ConnectionStatus.CONNECT)
                        {
                            // 接続完了

                            // 接続一覧に追加
                            this.m_Clients.Add(cl);
                        }
                        else if (Status == TdcBaseSocket.ConnectionStatus.DISCONECTING || Status == TdcBaseSocket.ConnectionStatus.CLOSE || Status == TdcBaseSocket.ConnectionStatus.ERROR)
                        {
                            // 切断検出/接続終了/接続エラー

                            // 接続クライアント一覧に存在するかどうか
                            if (0 <= this.m_Clients.IndexOf(cl))
                            {
                                // 一覧から破棄
                                this.m_Clients.Remove(cl);
                            }
                        }

                        // 接続クライアント一覧を取得する
                        listclients.AddRange(this.m_Clients);
                    }

                    // 接続件数に変化があった場合
                    if (Status == TdcBaseSocket.ConnectionStatus.CONNECT || Status == TdcBaseSocket.ConnectionStatus.CLOSE || Status == TdcBaseSocket.ConnectionStatus.ERROR)
                    {
                        // 接続制限実施判定
                        if (this.ConnectionLimitType != CONNECTION_LIMIT_TYPE.NON && 0 < this.ConnectionLimitCount)
                        {
                            // 接続制限がある場合

                            // ログ記録クラス起動
                            NKKLogging log = NKKLogging.GetInstance();

                            // 履歴作成
                            DateTime dtlog = DateTime.Now;
                            String strservice = this.ServiceName;
                            String strlogdata = String.Empty;

                            int ncount = 0;

                            // 接続制限種類判定
                            if (this.ConnectionLimitType == CONNECTION_LIMIT_TYPE.SOCKET_MODE)
                            {
                                // ソケット制限

                                // 履歴
                                strlogdata = "ソケット接続件数";

                                // 接続件数
                                ncount = listclients.Count;
                            }
                            else if (this.ConnectionLimitType == CONNECTION_LIMIT_TYPE.IP_ADDRESS_MODE)
                            {
                                // IPアドレス制限

                                // 履歴
                                strlogdata = "IPアドレス接続件数";

                                // 接続しているIPアドレス一覧を作成
                                List<String> listip = new List<String>();
                                foreach (TdcBaseSocketServerClient clwork in listclients)
                                {
                                    String strip = ((IPEndPoint)(clwork.Socket.RemoteEndPoint)).Address.ToString();
                                    if (listip.Contains(strip) == false)
                                    {
                                        listip.Add(strip);
                                    }
                                }

                                // 接続件数
                                ncount = listip.Count;
                            }

                            // 接続件数記録
                            strlogdata += String.Format("が変更されました,接続件数:{0},接続許可件数:{1}", ncount, this.ConnectionLimitCount);
                            strlogdata += "," + cl.GetConnectionString();
                            log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
                        }
                    }
                }
            }
            finally
            {
                // イベント呼び出し
                this.ClientConnectedHandler?.Invoke(Sender, Status);
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内接続クライアントオブジェクトで非同期送信完了時に呼び出されるイベント
        /// </summary>
        /// <param name="Sender">サーバー内接続クライアントオブジェクト</param>
        /// <param name="bSendCompleted">送信完了フラグ</param>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual void ClientSendCompleted(Object Sender, bool bSendCompleted)
        {
            // イベント呼び出し
            this.ClientSendCompletedHandler?.Invoke(Sender, bSendCompleted);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サーバー内接続クライアントオブジェクトで受信した場合に呼び出されるイベント
        /// </summary>
        /// <param name="Sender">サーバー内接続クライアントオブジェクト</param>
        /// <param name="cData">受信バッファ</param>
        /// <param name="nRecieveSize">受信byte数</param>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual void ClientReceived(Object Sender, Byte[] cData, int nRecieveSize)
        {
            // イベント呼び出し
            this.ClientReceivedHandler?.Invoke( Sender, cData, nRecieveSize);
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
