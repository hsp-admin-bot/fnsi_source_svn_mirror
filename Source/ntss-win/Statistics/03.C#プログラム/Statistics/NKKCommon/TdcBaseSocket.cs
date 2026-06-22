//----------------------------------------------------------------------------------------------------
//  TDC製ベースソケット処理クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.IO;
using System.Data;
using System.Net;
using System.Net.Sockets;
//using System.Net.Security;
using System.Collections.Generic;
using System.Text;
using System.Threading;

#if DEBUG
    using System.Diagnostics;
#endif


//----------------------------------------------------------------------------------------------------
//  TdcLib名前空間
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  TdcLib名前空間
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
    /// 接続/切断通知用デリゲート定義
    /// </summary>
    /// <param name="Sender">ベースオブジェクト</param>
    /// <param name="Status">接続状態</param>
    //----------------------------------------------------------------------------------------------------
    public delegate void dgtTdcBaseSocketConnected(Object Sender, TdcBaseSocket.ConnectionStatus Status);
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// データ非同期送信完了通知用デリゲート定義
    /// </summary>
    /// <param name="Sender">ベースオブジェクト</param>
    /// <param name="bSendCompleted">送信完了フラグ</param>
    //----------------------------------------------------------------------------------------------------
    public delegate void dgtTdcBaseSocketSendCompleted(Object Sender, bool bSendCompleted);
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// データ受信通知用デリゲート定義
    /// </summary>
    /// <param name="Sender">ベースオブジェクト</param>
    /// <param name="cRecvData">受信バッファ</param>
    /// <param name="nRecvSize">受信サイズ</param>
    //----------------------------------------------------------------------------------------------------
    public delegate void dgtTdcBaseSocketReceived(Object Sender, Byte[] cRecvData, int nRecvSize);
    //----------------------------------------------------------------------------------------------------
#endregion

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// TDC製ベースソケット処理クラス定義
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class TdcBaseSocket
    {

#region 接続状態定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続状態
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public enum ConnectionStatus
        {
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 接続開始
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            CONNECTION_START = 0,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 接続検出
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            CONNECTING,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 接続完了
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            CONNECT,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 切断開始
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            DISCONECT_START,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 切断検出
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            DISCONECTING,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 切断完了
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            DISCONNECT,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 接続終了
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            CLOSE,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 再接続開始(指定ミリ秒待ち)
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            RECONNECT_START,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// 再接続実施
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            RECONNECT,
            //----------------------------------------------------------------------------------------------------
            /// <summary>
            /// エラー発生
            /// </summary>
            //----------------------------------------------------------------------------------------------------
            ERROR,
            //----------------------------------------------------------------------------------------------------
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続状態文字列
        /// </summary>
        /// <param name="Status">接続状態</param>
        /// <returns>接続状態文字列</returns>
        //----------------------------------------------------------------------------------------------------
        public static String ConnectionStatusString(ConnectionStatus Status)
        {
            String strret = String.Empty;

            switch (Status)
            {
                case ConnectionStatus.CONNECTION_START: // 接続開始
                    strret = "接続開始";
                    break;

                case ConnectionStatus.CONNECTING:       // 接続検出
                    strret = "接続検出";
                    break;

                case ConnectionStatus.CONNECT:          // 接続完了
                    strret = "接続完了";
                    break;

                case ConnectionStatus.DISCONECT_START:  // 切断開始
                    strret = "切断開始";
                    break;

                case ConnectionStatus.DISCONECTING:     // 切断検出
                    strret = "切断検出";
                    break;

                case ConnectionStatus.DISCONNECT:       // 切断完了
                    strret = "切断完了";
                    break;

                case ConnectionStatus.CLOSE:            // 接続終了
                    strret = "接続終了";
                    break;

                case ConnectionStatus.RECONNECT_START:  // 再接続開始
                    strret = "再接続開始";
                    break;

                case ConnectionStatus.RECONNECT:        // 再接続
                    strret = "再接続実施";
                    break;

                case ConnectionStatus.ERROR:            // エラー検出
                    strret = "エラー検出";
                    break;
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        #endregion

#region プライベート変数

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //private String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        private String m_strServiceName = "Socket";
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
        /// 汎用データ保持用オブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Object m_objData = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 一時受信バッファサイズ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
        //protected int m_nRecvBufferSize = 2 * 1024;
        protected int m_nRecvBufferSize = 10 * 1024;
        // mod FNSI-4749 不要プリンターの削除機能対応 夏 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 一時受信バッファ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Byte[] m_cRecvTempBuffer = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理用接続先情報
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private IPEndPoint m_IPRemote = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理用ソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Socket m_Socket = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 処理用ソケットStreamオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Stream m_Stream = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 最終処理TickCount値
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private uint m_nLastTickCount = 0;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続/切断通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketConnected m_dgtConnectedHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット非同期送信完了通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketSendCompleted m_dgtSendCompletedHandler = null;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット受信通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketReceived m_dgtReceivedHandler = null;
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
                    String strlogdata = String.Format("TdcBaseSocket.{0}, {1}", this.GetType().Name, value.ToString().Replace("\r\n", "{CRLF}"));

                    // 履歴に追記
                    log.AddLogInfo(dtlog, this.ServiceName, NKKLogging.LOGGING_CLASS.ERROR, strlogdata);
#if DEBUG
                    Debug.WriteLine(this.ServiceName + " " + strlogdata);
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
            set { this.m_strServiceName = value;  }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信バッファサイズ参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public int RecvBufferSize
        {
            get { return (this.m_nRecvBufferSize); }
            set { }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 実際のソケットクラスオブジェクト参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public Socket Socket
        {
            get { return (this.m_Socket); }
            set { }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 最終処理TickCount値設定/参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public uint LastTickCount
        {
            get { return (this.m_nLastTickCount); }
            set { this.m_nLastTickCount = value; }
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
#endregion

#region アクセスは、コンテナ クラス、またはコンテナ クラスから派生した型に制限

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続/切断通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected dgtTdcBaseSocketConnected BaseConnectedHandler
        {
            get { return (this.m_dgtConnectedHandler); }
            set { this.m_dgtConnectedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット非同期送信完了通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected dgtTdcBaseSocketSendCompleted BaseSendCompletedHandler
        {
            get { return (this.m_dgtSendCompletedHandler); }
            set { this.m_dgtSendCompletedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット受信通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        protected dgtTdcBaseSocketReceived BaseReceivedHandler
        {
            get { return (this.m_dgtReceivedHandler); }
            set { this.m_dgtReceivedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
#endregion


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="intBufferSize">一時受信バッファサイズ</param>
        //----------------------------------------------------------------------------------------------------
        public TdcBaseSocket(int intBufferSize)
        {
            // 一時受信サイズ[2KBを超える場合に再設定]
            if( this.m_nRecvBufferSize < intBufferSize )
            {
                this.m_nRecvBufferSize = intBufferSize;
            }

            // 一時受信バッファ構築
            this.m_cRecvTempBuffer = new Byte[this.m_nRecvBufferSize];
        }
        //----------------------------------------------------------------------------------------------------


#region プライベートメソッド
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続/切断イベント呼び出し
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void evConnected(ConnectionStatus Status)
        {
            // 接続/切断通知
            this.BaseConnectedHandler?.Invoke( this, Status);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 非同期送信完了後イベント呼び出し
        /// </summary>
        /// <param name="bSendCompleted">送信完了フラグ</param>
        //----------------------------------------------------------------------------------------------------
        private void evSendCompleted(bool bSendCompleted)
        {
            // 送信完了通知
            this.BaseSendCompletedHandler?.Invoke(this, bSendCompleted);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 受信後イベント呼び出し
        /// </summary>
        /// <param name="cRecvData">受信バッファ</param>
        /// <param name="nRecvSize">受信サイズ</param>
        //----------------------------------------------------------------------------------------------------
        private void evReceived( Byte[] cRecvData, int nRecvSize)
        {
            // 受信データ通知
            this.BaseReceivedHandler?.Invoke(this, cRecvData, nRecvSize);
        }
        //----------------------------------------------------------------------------------------------------
#endregion

#region パブリックメソッド
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続情報
        /// <param name="strAddress">接続先アドレス</param>
        /// <param name="nPortNo">接続先ポート番号</param>
        /// </summary>
        /// <returns>接続情報(文字列："接続先IP:？,接続先ポート番号:？")</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetConnectionString(String strAddress, int nPortNo)
        {
            return (String.Format("接続先IP:{0},接続先ポート番号:{1}", strAddress, nPortNo));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続情報
        /// <param name="RemoteEndPoint">リモートエンドポイントオブジェクト</param>
        /// </summary>
        /// <returns>Empty：未接続/else：接続情報(文字列："接続先IP:？,接続先ポート番号:？")</returns>
        //----------------------------------------------------------------------------------------------------
        public static String GetConnectionString(EndPoint RemoteEndPoint)
        {
            String strret = String.Empty;

            try
            {
                // 接続先情報有無チェック
                if (RemoteEndPoint is IPEndPoint ipremote)
                {
                    // 接続先情報を返す
                    strret = TdcBaseSocket.GetConnectionString (ipremote.Address.ToString(), ipremote.Port );
                }
            }
            catch
            {
            }

            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット登録
        /// </summary>
        /// <param name="Soc">ソケット</param>
        //----------------------------------------------------------------------------------------------------
        public virtual void AssignSocket(ref Socket Soc)
        {
            try
            {
                // ソケット設定
                this.m_Socket = Soc;

                // 接続先情報
                this.m_IPRemote = (IPEndPoint)(this.m_Socket.RemoteEndPoint);
            }
            catch (Exception ex)
            {
                // 登録失敗

                this.Error = ex;

                throw ex;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット登録＋受信イベント登録
        /// </summary>
        /// <param name="Soc">ソケット</param>
        //----------------------------------------------------------------------------------------------------
        public virtual void SetSocket(ref Socket Soc)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = string.Empty;

            try
            {
                // ソケット登録
                this.AssignSocket(ref Soc);

                // 接続文字列取得
                strlogdata += this.GetConnectionString() + ",";
                strlogdata += TdcBaseSocket.ConnectionStatusString(ConnectionStatus.CONNECT);

                // ソケットストリーム取得
                //// SSL使用判定
                //if (bSSLEnable == true)
                //{
                //    // SSL使用
                //    this.m_Pop3SSLStream = new SslStream(this.m_Pop3Stream, false);
                //    this.m_Pop3SSLStream.AuthenticateAsClient(strServerName);

                //    this.m_Pop3Writer = this.m_Pop3SSLStream;
                //    this.m_Pop3Reader = new StreamReader(this.m_Pop3SSLStream);
                //}
                //else
                {
                    // SSL未使用
                    this.m_Stream = new NetworkStream(this.m_Socket);
                }

                // 各種イベント登録

                // 受信
                this.m_Stream.BeginRead(this.m_cRecvTempBuffer, 0, this.m_cRecvTempBuffer.Length, new AsyncCallback(evRecvCallBack), this.m_Stream);

                // 履歴に追記
                log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                Debug.WriteLine(strservice + " " + strlogdata);
#endif

                // 接続通知
                this.evConnected(ConnectionStatus.CONNECT);
            }
            catch(Exception ex)
            {
                // 登録失敗

                this.Error = ex;

                throw ex;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 内部ソケット接続情報
        /// </summary>
        /// <returns>Empty：未接続/else：接続情報(文字列："接続先IP:？,接続先ポート番号:？")</returns>
        //----------------------------------------------------------------------------------------------------
        public String GetConnectionString()
        {
            return ( TdcBaseSocket.GetConnectionString( this.m_IPRemote ));
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続状態
        /// </summary>
        /// <returns>true：接続中/false：未接続[接続確定前(処理中)含む]</returns>
        //----------------------------------------------------------------------------------------------------
        public bool CheckConnected()
        {
            bool bret = false;

            // ソケット有無チェック
            if (this.m_Socket != null)
            {
                // 接続状態取得
                bret = this.m_Socket.Connected;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット送信処理
        /// </summary>
        /// <param name="cSendData">送信データ</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public bool Write(Byte[] cSendData)
        {
            bool bret = false;

            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                //
                strlogdata += this.GetConnectionString() + ",";

                // 最終処理時刻保持
                this.LastTickCount = (uint)System.Environment.TickCount;

                // 送信
                this.m_Stream.Write(cSendData, 0, cSendData.Length);

                // Bin→Hex文字列化
                strlogdata += "送信," + TdcLib.TdcLib.GetByteToHexString(cSendData, 0, cSendData.Length);

                //// 履歴に追記
                //log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                Debug.WriteLine(strservice + " " + strlogdata);
#endif

                bret = true;
            }
            catch(Exception ex)
            {
                // 送信失敗

                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット非同期送信処理
        /// ※送信成功/失敗が必要な場合は事前にBaseSendCompletedHandlerの登録が必要
        /// </summary>
        /// <param name="cSendData">送信データ</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public bool AsyncWrite(Byte[] cSendData)
        {
            bool bret = false;

            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                //
                strlogdata += this.GetConnectionString() + ",";

                // 最終処理時刻保持
                this.LastTickCount = (uint)System.Environment.TickCount;

                // 送信[非同期]
                this.m_Stream.BeginWrite(cSendData, 0, cSendData.Length, new AsyncCallback(this.evSendCallBack), this.m_Stream);

                // 送信完了
                bret = true;

                // Bin→Hex文字列化
                strlogdata += "送信[非同期]," + TdcLib.TdcLib.GetByteToHexString(cSendData, 0, cSendData.Length);

                //// 履歴に追記
                //log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                Debug.WriteLine(strservice + " " +  strlogdata);
#endif
            }
            catch (Exception ex)
            {
                // 送信失敗

                this.Error = ex;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット終了処理
        /// </summary>
        /// <returns>true：切断実施(接続されていない場合含む)/false：切断未実施</returns>
        //----------------------------------------------------------------------------------------------------
        public bool Close()
        {
            bool bret = true;

            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty; ;

            try
            {
                // ソケットが構築されている場合
                if (this.m_Socket != null)
                {
                    // 接続情報
                    strlogdata += this.GetConnectionString() + ",";

                    // 接続している場合
                    if (this.m_Socket.Connected == true)
                    {

                        // ソケット切断開始通知
                        this.evConnected(ConnectionStatus.DISCONECT_START);

                        // 履歴に追記
                        strlogdata += TdcBaseSocket.ConnectionStatusString(ConnectionStatus.DISCONECT_START);
                        log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                        Debug.WriteLine(strservice + " " + strlogdata);
#endif                  
                        // シャットダウン
                        //this.m_Socket.Shutdown(SocketShutdown.Both);
                        try
                        {
                            this.m_Socket.Shutdown(SocketShutdown.Both);
                        }
                        catch (Exception)
                        {
                            log.AddLogInfo(DateTime.Now, strservice, NKKLogging.LOGGING_CLASS.INFO, "切断完了");
                        }
                    }
                }
                else
                {
                    bret = false;
                }
            }
            catch (Exception ex)
            {
                // ソケット終了時

                this.Error = ex;

                // ソケットエラー通知
                this.evConnected(ConnectionStatus.ERROR);
            }
            finally
            {

                // ストリーム破棄
                try
                {
                    if (this.m_Stream != null)
                    {
                        // ストリーム終了
                        this.m_Stream.Close();
                    }
                }
                catch
                {
                }
                finally
                {
                    this.m_Stream = null;
                }

                // ソケット破棄
                try
                {
                    if (this.m_Socket != null)
                    {
                        // ソケット切断
                        this.m_Socket.Close();
                    }
                }
                catch
                {
                }
                finally
                {
                    this.m_Socket = null;
                }

                // 実際に終了を行った場合
                if (bret == true)
                {
                    // 接続情報
                    strlogdata = this.GetConnectionString() + ",";

                    // 履歴に追記
                    strlogdata += TdcBaseSocket.ConnectionStatusString(ConnectionStatus.CLOSE);
                    log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                    Debug.WriteLine(strservice + " " + strlogdata);
#endif

                    // ソケット終了通知
                    this.evConnected(ConnectionStatus.CLOSE);
                }

                this.m_IPRemote = null;
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
#endregion

#region イベント定義
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通信ソケット送信CallBack関数
        /// </summary>
        /// <param name="ar"></param>
        //----------------------------------------------------------------------------------------------------
        private void evSendCallBack(IAsyncResult ar)
        {
            bool bret = false;

            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 接続情報
                strlogdata += this.GetConnectionString() + ",";

                Stream stream = (Stream)ar.AsyncState;
                if (stream.CanWrite == true)
                {
                    // 送信完了待ち
                    stream.EndWrite(ar);

                    // 最終処理時刻保持
                    this.LastTickCount = (uint)System.Environment.TickCount;

                    // 送信完了
                    bret = true;

                    // Bin→Hex文字列化
                    strlogdata += "送信完了[非同期]";

                    //// 履歴に追記
                    //log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                    Debug.WriteLine(strservice + " " + strlogdata);
#endif
                }
            }
            catch (Exception ex)
            {
                // エラー発生

                this.Error = ex;
            }

            // 送信通知を行う
            this.evSendCompleted(bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通信ソケット受信CallBack関数
        /// </summary>
        /// <param name="ar"></param>
        //----------------------------------------------------------------------------------------------------
        private void evRecvCallBack(IAsyncResult ar)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 接続情報
                strlogdata += this.GetConnectionString() + ",";

                // 最終処理時刻保持
                this.LastTickCount = (uint)System.Environment.TickCount;

                // 受信サイズ取得
                int intrecvsize = 0;
                //Socket soc = (Socket)ar.AsyncState;
                //if (soc.Login == true)
                Stream stream = (Stream)ar.AsyncState;
                if (stream.CanRead == true)
                {
                    //intrecvsize = soc.EndReceive(ar);
                    intrecvsize = stream.EndRead(ar);
                    if (0 < intrecvsize)
                    {
                        Byte[] cdata = new Byte[intrecvsize];
                        Array.Copy(this.m_cRecvTempBuffer, 0, cdata, 0, intrecvsize);

                        // Bin→Hex文字列化
                        strlogdata += "受信," + TdcLib.TdcLib.GetByteToHexString(cdata, 0, intrecvsize);

                        //// 履歴に追記
                        //log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                        Debug.WriteLine(strservice + " " + strlogdata);
#endif

                        // 受信通知を行う
                        this.evReceived(cdata, intrecvsize);

                        //// 受信イベント再定義
                        ////this.m_Socket.BeginReceive(this.m_cRecvTempBuffer, 0, this.m_nRecvBufferSize, 0, new AsyncCallback(evRecvCallBack), this.m_Socket);
                        //this.m_Stream.BeginRead(this.m_cRecvTempBuffer, 0, this.m_cRecvTempBuffer.Length, new AsyncCallback(evRecvCallBack), this.m_Stream);

                        // ソケットストリームチェック(受信通知先で切断される可能性があるため)
                        if (this.m_Stream != null)
                        {
                            // 受信イベント再定義
                            this.m_Stream.BeginRead(this.m_cRecvTempBuffer, 0, this.m_cRecvTempBuffer.Length, new AsyncCallback(evRecvCallBack), this.m_Stream);
                        }
                    }
                    else
                    {
                        // 切断検出

                        strlogdata += TdcBaseSocket.ConnectionStatusString(ConnectionStatus.DISCONECTING);

                        // 履歴に追記
                        log.AddLogInfo( dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
                        Debug.WriteLine(strservice + " " + strlogdata);
#endif

                        // ソケット切断検出通知
                        this.evConnected(ConnectionStatus.DISCONECTING);

                        // ソケット終了
                        this.Close();
                    }
                }
            }
            catch (Exception ex)
            {
                // ソケット破棄時

                this.Error = ex;

                // ソケットエラー通知
                this.evConnected(ConnectionStatus.ERROR);

                // ソケット終了
                this.Close();
            }
        }
        //----------------------------------------------------------------------------------------------------
#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
