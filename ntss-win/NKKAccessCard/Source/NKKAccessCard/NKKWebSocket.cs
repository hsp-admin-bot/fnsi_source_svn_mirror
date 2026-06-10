//----------------------------------------------------------------------------------------------------
//  NKKWebSocketクラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Threading;
using System.Threading.Tasks;
using System.Reflection;
using WebSocket4Net;

#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKAccessCardLib
//----------------------------------------------------------------------------------------------------
using NKKAccessCardLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebAccessLib
//----------------------------------------------------------------------------------------------------
using NKKWebAccessLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:ToGUILib
//----------------------------------------------------------------------------------------------------
using ToGUILib;
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWebSocketLib
//----------------------------------------------------------------------------------------------------
namespace NKKWebSocketLib
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// NKKWebSocketクラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class NKKWebSocket : ToGUI
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = "WebSocket";
        //----------------------------------------------------------------------------------------------------


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocketURI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String POST_WEB_SOCKET_KEY_URI = "/ntss-admin-web/api/websocketcertification/";
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 直前で発生したエラーオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Exception m_Exception = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッドオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly Thread m_Thread = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// スレッド終了用シグナル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly System.Threading.ManualResetEvent m_evFinish = new ManualResetEvent(false);
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocket識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strWSIdentifier = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocket識別子番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strWSIdentifierNo = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocketクライアントオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private WebSocket m_wscl = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続先URI
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strUri = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocket接続用認証キー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strAuthenticationKey = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// KeepAlive間隔
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private uint m_nKeepAliveInterval = 20;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// KeepAlive送信中フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Boolean m_bKeepAliveSending = false;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WatchDog実施日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int nWatchDogCount = System.Environment.TickCount;
        //----------------------------------------------------------------------------------------------------

        #region デリゲート定義
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信用デリゲート定義
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="strMessage">受信したメッセージ</param>
        //----------------------------------------------------------------------------------------------------
        public delegate void dgtReceiveMessage(DateTime dtNow, String strMessage);
        //----------------------------------------------------------------------------------------------------
#endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtReceiveMessage m_dgtReceiveMessageHandler = null;
        //----------------------------------------------------------------------------------------------------

#region パブリックプロパティ

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通信状態参照用プロパティ[true：通信中/false：未通信]
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Boolean IsConnected
        {
            get
            {
                Boolean bret = false;
                try
                {
                    bret = (this.m_wscl.State == WebSocketState.Open);
                }
                catch
                {
                }
                return bret;
            }
        }
        //----------------------------------------------------------------------------------------------------

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
                    String strlogdata = String.Format("{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    log.AddLogInfo(dtlog, this.SERVICE_NAME, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.SERVICE_NAME + " " + strlogdata);
#endif
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 識別子番号参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String IdentityNo
        {
            get { return this.m_strWSIdentifierNo; }
            set { this.m_strWSIdentifierNo = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続先URI参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public String Uri
        {
            get { return (this.m_strUri); }
            set { this.m_strUri = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// WebSocket KeepAlive間隔参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public uint KeepAlive
        {
            get { return this.m_nKeepAliveInterval; }
            set { this.m_nKeepAliveInterval = value; }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtReceiveMessage ReceiveMessage
        {
            get { return (this.m_dgtReceiveMessageHandler); }
            set { this.m_dgtReceiveMessageHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public NKKWebSocket(String strWebSocketId)
        {
            // 構築処理

            // WebSocket識別子
            this.m_strWSIdentifier = strWebSocketId;

            // 接続/WatchDoc用スレッド構築
            this.m_Thread = new Thread(this.DoWork)
            {
                Name = "NKKWebSocket処理スレッド",
                IsBackground = false
            };
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// デストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        ~NKKWebSocket()
        {
            // 処理終了
            this.Stop();
        }
        //----------------------------------------------------------------------------------------------------

#region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理開始
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public Boolean Start()
        {
            Boolean bret = true;

            DateTime dtnow = DateTime.Now;

            try
            {
                // 処理開始成功時
                if (bret == true && this.m_Thread != null)
                {
                    // 接続/WatchDoc用スレッド開始
                    this.m_Thread.Start();
                }

                // ログ記録
                String strlog = "処理開始";
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

                // GUIへ通知
                this.SendMessageToGUI("未接続", dtnow, strlog);
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Stop()
        {
            DateTime dtnow = DateTime.Now;

            try
            {
                // WebSocket接続状態判定
                if( this.IsConnected == true )
                {
                    // 接続している場合

                    // WebSocket終了
                    //await this.m_wscl.CloseAsync(WebSocketCloseStatus.NormalClosure, String.Empty, CancellationToken.None);

                    // WebSocket破棄
                    this.m_wscl.Dispose();
                }

                // 接続/WatchDoc用スレッド停止
                if (this.m_Thread != null)
                {
                    // カウンタ値初期化
                    uint dwtickcount = (uint)System.Environment.TickCount;
                    // スレッドが終了するか10秒間待つ
                    while (!TdcLib.TdcLib.CheckTickCount(10 * 1000, dwtickcount, (uint)System.Environment.TickCount))
                    {
                        // スレッド停止
                        this.m_evFinish.Set();

                        // スレッドが終了した場合
                        if (this.m_Thread.IsAlive == false)
                        {
                            // 処理を抜ける
                            break;
                        }
                    };
                }

                // ログ記録
                String strlog = "処理終了";
                this.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, strlog);

                // GUIへ通知
                this.SendMessageToGUI("未接続", dtnow, strlog);
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

#region プライベートメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ記録
        /// </summary>
        /// <param name="dtNow">発生日時</param>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMesssage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void AddLogInfo(DateTime dtNow, NKKLogging.LOGGING_CLASS LoggingClass, String strMesssage)
        {
            // ログオブジェクト取得
            NKKLogging log = NKKLogging.GetInstance();

            // ログ記録
            log.AddLogInfo(dtNow, this.SERVICE_NAME, LoggingClass, strMesssage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI通知
        /// </summary>
        /// <param name="strStatus">状態</param>
        /// <param name="dtOccurDate">発生日時</param>
        /// <param name="strMessage">内容</param>
        //----------------------------------------------------------------------------------------------------
        private void SendMessageToGUI(String strStatus, DateTime dtOccurDate, String strMessage)
        {
            // GUIへ通知
            base.SendMessageToGUI(this.SERVICE_NAME, strStatus, dtOccurDate, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続/WatchDoc用スレッド実行処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void DoWork()
        {
            String strlog = String.Empty;

            // スレッド開始
            this.m_evFinish.Reset();

            while (true)
            {
                try
                {
                    // 
                    // 接続状態判定
                    if (this.IsConnected == true )
                    {
                        // 接続中


                        // 設定秒間隔判定
                        if (TdcLib.TdcLib.CheckTickCount(this.KeepAlive * 1000, (uint)this.nWatchDogCount, (uint)System.Environment.TickCount) == true)
                        {
                            // 設定秒間隔の処理

                            // 処理実施
                            nWatchDogCount = System.Environment.TickCount;

                            // WatchDog送信中判定
                            if (this.m_bKeepAliveSending == false)
                            {
                                // 未送信

                                // WatchDog送信中をセット
                                this.m_bKeepAliveSending = true;

                                // GUIへ通知
                                this.SendMessageToGUI("接続中", DateTime.Now, "WatchDog送信");

                                // WatchDog送信
                                Task sendWatchDog = Task.Run(()=>this.m_wscl.Send(" "));
                                sendWatchDog.Wait();
                                if(sendWatchDog.Status == TaskStatus.RanToCompletion )
                                {
                                    // 送信成功

                                    // 接続判定
                                    if (this.m_wscl.State != WebSocketState.Open)
                                    {
                                        // 切断検出
                                        strlog = "WatchDog送信後に切断検出";
                                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                                        // GUIへ通知
                                        this.SendMessageToGUI("未接続", DateTime.Now, strlog);
                                    }
                                }
                                else
                                {
                                    // 送信失敗

                                    strlog = "WatchDog送信失敗";
                                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                                    // GUIへ通知
                                    this.SendMessageToGUI("未接続", DateTime.Now, strlog);

                                    // 切断
                                    this.m_wscl.Close();
                                }
                            }
                            else
                            {
                                // 送信中(WatchDog応答なし)

                                // 接続異常
                                strlog = "接続異常検出";
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                                // GUIへ通知
                                this.SendMessageToGUI("未接続", DateTime.Now, "エラー発生:接続異常検出");

                                // 切断
                                this.m_wscl.Close();
                            }
                        }
                    }
                    else
                    {
                        // 未接続

                        // WatchDog送信中解除
                        this.m_bKeepAliveSending = false;

                        // WebSocket認証コード作成
                        this.m_strAuthenticationKey = String.Empty;

                        // Uri作成
                        String struri = String.Format("{0}{1}?_={2}"
                            , NKKWebAccess.BaseUri
                            , this.POST_WEB_SOCKET_KEY_URI
                            , DateTime.Now.Ticks);
                        String strbody = String.Format("{{\"facilityCd\":\"{0}\"}}", NKKWebAccess.FacilityCd);
                        NKKWebAccessResponse res = NKKWebAccess.Post("WebSocket接続認証キー生成", struri, strbody).Result;
                        if( res.response.IsSuccessStatusCode == true )
                        {
                            this.m_strAuthenticationKey = res.strContent;
                        }
                        if (String.IsNullOrEmpty(this.m_strAuthenticationKey) == false)
                        {
                            //
                            // 依頼成功
                            strlog = String.Format("WebSocket接続認証キー生成成功,{0}", this.m_strAuthenticationKey);
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                            // WebSocketオブジェクトを破棄
                            if (this.m_wscl != null)
                            {
                                this.m_wscl.Dispose();
                            }

                            // WebSocketオブジェクトを構築
                            this.m_wscl = new WebSocket(this.m_strUri);

                            // イベント登録
                            this.m_wscl.Opened += this.WS_Opened;
                            this.m_wscl.MessageReceived += this.WS_MessageReceived;
                            this.m_wscl.DataReceived += this.WS_DataReceived;
                            this.m_wscl.Closed += this.WS_Closed;
                            this.m_wscl.Error += this.WS_Error;

                            //// パラメータ設定[自動でpingを行う場合だと思う]
                            //this.m_wscl.AutoSendPingInterval = 30; 
                            //this.m_wscl.EnableAutoSendPing = true;


                            // WebSocket接続開始
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続開始");

                            // WebSocket接続
                            this.m_wscl.Open();
                        }
                        else
                        {
                            // 依頼失敗
                            strlog = String.Format("キー生成失敗,{0}", struri);
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog);

                            // GUIへ通知
                            this.SendMessageToGUI("SERVER", "未接続", DateTime.Now, "キー生成失敗");
                        }
                    }
                }
                catch (Exception ex)
                {
                    this.Error = ex;

                    // GUIへ通知
                    this.SendMessageToGUI("未接続", DateTime.Now, String.Format("エラー発生:{0}", ex.Message));
                }

                // 10秒間、又はシグナル待ち
                if ( this.m_evFinish.WaitOne(10 * 1000) == true)
                {
                    // スレッド終了
                    break;
                }
            };
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// オープンイベント
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WS_Opened(object sender, EventArgs e)
        {
            String strlog = String.Empty;
            String strstate = "接続中";
            NKKLogging.LOGGING_CLASS kind = NKKLogging.LOGGING_CLASS.INFO;

            // 接続完了
            strlog = "接続完了";
            this.AddLogInfo(DateTime.Now, kind, strlog);

            // GUIへ通知
            this.SendMessageToGUI(strstate, DateTime.Now, strlog);

            // 処理実施
            this.nWatchDogCount = System.Environment.TickCount;

            // 接続完了
            strlog = "認証情報送信";
            this.AddLogInfo(DateTime.Now, kind, strlog);

            // 認証コードを通知
            String strkey = String.Format("NTSS@{0}{1}{2}"
                , this.m_strAuthenticationKey
                , this.m_strWSIdentifier
                , this.m_strWSIdentifierNo.PadLeft(2, '0'));
            this.m_wscl.Send(strkey);
            //Task sendWatchDog = Task.Run(() => this.m_wscl.Send(strkey));
            //sendWatchDog.Wait();
            //if (sendWatchDog.Status == TaskStatus.RanToCompletion)
            //{
            //    // 送信成功

            //    // 接続判定
            //    if (this.m_wscl.State == WebSocketState.Open)
            //    {
            //        // 認証成功
            //        strlog = "認証成功";
            //    }
            //    else
            //    {
            //        // 認証失敗
            //        strlog = "認証失敗";
            //        strstate = "未接続";
            //        kind = NKKLogging.LOGGING_CLASS.ERROR;

            //        // 切断
            //        this.m_wscl.Close();
            //    }
            //}
            //else
            //{
            //    // 送信失敗
            //    strlog = "認証送信失敗";
            //    strstate = "未接続";
            //    kind = NKKLogging.LOGGING_CLASS.ERROR;

            //    // 切断
            //    this.m_wscl.Close();
            //}

            //// ログ記録
            //this.AddLogInfo(DateTime.Now, kind, strlog);

            //// GUIへ通知
            //this.SendMessageToGUI(strstate, DateTime.Now, strlog);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// メッセージ受信イベント
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WS_MessageReceived(object sender, MessageReceivedEventArgs e)
        {

            String strlog = string.Empty;

            try
            {
                // 受信
                String strrecv = e.Message.Trim();

                if (0 < strrecv.Length)
                {
                    // 受信
                    strlog = String.Format("受信[Message]:{0}", strrecv);
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                    // 受信データによる個別処理
                    Task task = Task.Run(() => {
                        this.ReceiveMessage?.Invoke(DateTime.Now, strrecv);
                    });
                }
                else
                {
                    strlog = "WatchDog受信";

                    // WatchDog送信中解除
                    this.m_bKeepAliveSending = false;
                }

                // GUIへ通知
                this.SendMessageToGUI("接続中", DateTime.Now, strlog);
            }
            catch (Exception ex)
            {
                this.Error = ex;

                // WatchDog送信中解除
                this.m_bKeepAliveSending = false;

                // GUIへ通知
                this.SendMessageToGUI("未接続", DateTime.Now, String.Format("エラー発生:{0}", ex.Message));
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// データ受信イベント
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WS_DataReceived(object sender, WebSocket4Net.DataReceivedEventArgs e)
        {
            String strlog = String.Empty;

            try
            {
                // 受信
                String strrecv = System.Text.Encoding.UTF8.GetString(e.Data).Trim(); ;

                if (0 < strrecv.Length)
                {
                    // 受信
                    strlog = String.Format("受信[Data]:{0}", strrecv);
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, strlog);

                    // 受信データによる個別処理
                    Task task = Task.Run(() => {
                        this.ReceiveMessage?.Invoke(DateTime.Now, strrecv);
                    });
                }

                // GUIへ通知
                this.SendMessageToGUI("接続中", DateTime.Now, strlog);
            }
            catch (Exception ex)
            {
                this.Error = ex;

                // GUIへ通知
                this.SendMessageToGUI("未接続", DateTime.Now, String.Format("エラー発生:{0}", ex.Message));
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// クローズイベント
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WS_Closed(object sender, EventArgs e)
        {
            //
            WebSocket4Net.ClosedEventArgs ex = e as WebSocket4Net.ClosedEventArgs;

            // 切断検出
            String strlog = "切断検出";
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("{0}, {1}({2})", strlog, ex.Reason, ex.Code));

            // GUIへ通知
            this.SendMessageToGUI("未接続", DateTime.Now, strlog);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// エラーイベント
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WS_Error(object sender, SuperSocket.ClientEngine.ErrorEventArgs e)
        {
            // エラー検出
            String strlog = "エラー検出";
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, strlog + ", " + e.Exception.ToString().Replace("\r\n", "{ CRLF}"));

            // GUIへ通知
            this.SendMessageToGUI("未接続", DateTime.Now, strlog);
        }
        //----------------------------------------------------------------------------------------------------

        #endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
