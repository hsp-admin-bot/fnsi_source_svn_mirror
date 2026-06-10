using FNSiViewSyncLogicLib.Common.Utilities;
using FNSiViewSyncLogicLib.Service;
using FNSiViewSyncLogicLib.Services;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NKKLoggingLib;
using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;
using TdcLib;
using TdcSocketLib;

namespace FNSiViewSyncLogicLib
{
    /// <summary>
    /// FNSiLocalSocketServiceクラス
    /// </summary>
    class FNSiLocalSocketService
    {
        #region プライベート定義

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

        ///// <summary>
        ///// 出力先テーブル情報配列
        ///// </summary>
        //private ArrayList m_viewTableInfoList = new ArrayList();

        /// <summary>
        /// TdcBaseSocketServerオブジェクト
        /// </summary>
        private readonly TdcBaseSocketServer m_socketService = new TdcBaseSocketServer();

        /// <summary>
        /// 出力先テーブル情報配列
        /// </summary>
        public static List<ViewTableInfo> m_viewTableInfoListAll = new List<ViewTableInfo>();

        /// <summary>
        /// 出力先テーブル情報配列(間隔同期)
        /// </summary>
        public static List<ViewTableInfo> m_intervalViewTableInfoList = new List<ViewTableInfo>();

        /// <summary>
        /// 出力先テーブル情報配列(固定同期)
        /// </summary>
        public static List<ViewTableInfo> m_fixViewTableInfoList = new List<ViewTableInfo>();

        /// <summary>
        /// XMLファイル名
        /// </summary>
        private readonly String XMLG_FILE_NAME = "FNSiViewSync.xml";

        /// <summary>
        /// ベースディレクトリ
        /// </summary>
        private string strFolder = "";

        /// <summary>
        /// TdcBaseSocketServerオブジェクト
        /// </summary>
        public FNSiViewSyncLogic m_viewSyncLogic = null;

        #endregion

        #region パブリックメソッド

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FNSiLocalSocketService()
        {
            // 構築処理

            // クライアント接続時
            this.m_socketService.ServiceName = this.SERVICE_NAME;
            this.m_socketService.ClientConnectedHandler = this.ClientConnected;
            this.m_socketService.ClientReceivedHandler = this.ClientReceived;

            // Socket Server用スレッド構築
            this.m_Thread = new Thread(this.DoWork)
            {
                Name = "FNSiLocalSocketService処理スレッド",
                IsBackground = false
            };
        }

        /// <summary>
        /// デストラクタ
        /// </summary>
        ~FNSiLocalSocketService()
        {
            // 処理終了
            this.Stop();
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
                LogService.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理開始");
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
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理終了");
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
                        Thread.Sleep(100);
                    };
                }

                // ログ記録
                LogService.AddLogInfo(dtnow, NKKLogging.LOGGING_CLASS.INFO, "処理終了");
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

        ///// <summary>
        ///// 出力先テーブル情報配列 参照/設定用プロパティ
        ///// </summary>
        //public ArrayList ViewTableInfoList
        //{
        //    get { return this.m_viewTableInfoList; }
        //    set { this.m_viewTableInfoList = new ArrayList(value); }
        //}

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
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, this.m_socketService.ServiceName.Trim() + "処理開始");
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
                    // ログ記録
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.DEBUG, "Client Socket Connected.[" + cl.GetConnectionString() + "]");
                }
            }
        }

        /// クライアントソケット受信時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cData">受信バッファ</param>
        /// <param name="nRecieveSize">受信byte数</param>
        private void ClientReceived(Object Sender, Byte[] cData, int nRecieveSize)
        {
            string errorCode;

            // 受信データ
            string strdata = Encoding.UTF8.GetString(cData, 0, nRecieveSize);

            // 同期データを作成する
            List<string> keyNameList = new List<string>();

            // 受信データがJSONか
            if (JSONLib.IsJSONData(strdata))
            {
                try
                {
                    JArray jArray = JArray.Parse(strdata);
                    for (int index = 0; index < jArray.Count; index++)
                    {
                        // JSON分解
                        Dictionary<String, String>  tbl = JsonConvert.DeserializeObject<Dictionary<string, string>>(jArray[index].ToString());
                        keyNameList.Add(tbl["key_name"]);
                    }

                    // OK送信データ
                    errorCode = "0000";
                }
                catch(Exception ex)
                {
                    // NG送信データ
                    errorCode = "9999";
                    LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：受信データが不正, result={ex.Message}");
                }
            }
            else
            {
                // NG送信データ
                errorCode = "9001";
                LogService.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"status=400, message=要求部：受信データが不正, result={string.Join(",", keyNameList)}");
            }

            // 再同期
            if ("0000".Equals(errorCode))
            {
                ViewSyncService viewSyncService = new ViewSyncService();
                foreach(string keyName in keyNameList)
                {
                    viewSyncService.ManualSync(keyName);
                }
            }
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
                    LogService.AddLogInfo(dtlog, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
                }
            }
        }
        #endregion
    }
}
