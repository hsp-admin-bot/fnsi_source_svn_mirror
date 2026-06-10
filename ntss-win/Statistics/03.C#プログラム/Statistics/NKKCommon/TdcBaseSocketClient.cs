//----------------------------------------------------------------------------------------------------
//  TDC製ベースソケットクライアント処理クラス定義
//      派生元：TdcBaseSocke.cs
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
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------


//----------------------------------------------------------------------------------------------------
//  TdcSocketLib名前空間
//----------------------------------------------------------------------------------------------------
namespace TdcSocketLib
{

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// TDC製ベースソケットクライアント処理クラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class TdcBaseSocketClient : TdcBaseSocket
    {

#region プライベート変数
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続先IPアドレス
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strIPAddress = String.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続先ポート番号
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nPortNo = 0;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bExit = false;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続施行間隔
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nConnectInterval = 30 * 1000;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続処理有効フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bReconnectEnable = true;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続中フラグ(再接続中での時間経過待ちを行っている場合true)
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bReConnection = false;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続強制シグナル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private AutoResetEvent m_evForceConnection = new AutoResetEvent(false);
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続/切断通知用イベントハンドラー
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private dgtTdcBaseSocketConnected m_dgtConnectedHandler = null;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続処理スレッド
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Thread m_trdReConnect = null;
        //----------------------------------------------------------------------------------------------------

#endregion


        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="nRecvBufferSize">一時受信バッファサイズ</param>
        //----------------------------------------------------------------------------------------------------
        public TdcBaseSocketClient( int nRecvBufferSize) : 
            base( nRecvBufferSize)
        {
            // 接続/切断(終了)通知(再接続処理で使用)
            base.BaseConnectedHandler = this.ReConnect;
        }
        //----------------------------------------------------------------------------------------------------


#region パブリックプロパティ
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続処理中参照用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public bool Reconnecting
        {
            get { return (this.m_trdReConnect != null); }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット接続/切断通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketConnected ConnectedHandler
        {
            get { return (this.m_dgtConnectedHandler); }
            set { this.m_dgtConnectedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット非同期送信完了通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketSendCompleted SendCompletedHandler
        {
            get { return (base.BaseSendCompletedHandler); }
            set { base.BaseSendCompletedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ソケット受信通知用イベントハンドラー参照/設定用プロパティ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public dgtTdcBaseSocketReceived ReceivedHandler
        {
            get { return (base.BaseReceivedHandler); }
            set { base.BaseReceivedHandler = value; }
        }
        //----------------------------------------------------------------------------------------------------
#endregion

#region プライベートメソッド
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続処理
        /// </summary>
        /// <param name="Sender">ベースクラスオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        private void ReConnect(Object Sender, ConnectionStatus Status)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            // 接続文字列取得
            strlogdata += this.GetConnectionString() + ",";
            // 履歴作成
            strlogdata += TdcBaseSocket.ConnectionStatusString(Status);
#if DEBUG
            Debug.WriteLine(strservice + strlogdata);
#endif

            // 接続/切断通知
            this.evConnected(this, Status);

            // ソケット接続状態判定
            if ( this.CheckConnected() == false )
            {
                // 再接続処理が有効で終了しない場合
                if (this.m_bReconnectEnable == true && this.m_bExit == false)
                {
                    // 再接続実施

                    // 再接続処理が行われているかどうか
                    if (this.m_trdReConnect == null)
                    {
                        // 行われていない場合

                        try
                        {
                            // 再処理スレッド実施
                            this.m_trdReConnect = new Thread(this.ReConnectThread);
                            this.m_trdReConnect.IsBackground = true;
                            this.m_trdReConnect.Name = String.Format("{0}-再接続処理スレッド", this.GetConnectionString());
                            this.m_trdReConnect.Start();

                            // 再接続待ち開始通知
                            this.evConnected(this, ConnectionStatus.RECONNECT_START);
                        }
                        catch (Exception ex)
                        {
                            this.Error = ex;

                            this.m_trdReConnect = null;

                            // 再接続実施
                            this.ReConnect(Sender, ConnectionStatus.ERROR);
                        }
                        finally
                        {
                        }
                    }
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続処理スレッド
        /// ※指定時間経過後に再接続処理が実施される
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void ReConnectThread()
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 再接続処理を無効とする
                this.m_bReconnectEnable = false;

                // 再接続中フラグセット
                this.m_bReConnection = true;

                // 再接続強制シグナルリセット
                this.m_evForceConnection.Reset();

                // 再接続強制シグナルがセットされるか、指定時間が経過するまで待つ
                this.m_evForceConnection.WaitOne(this.m_nConnectInterval);

                // 再接続中フラグリセット
                this.m_bReConnection = false;

                // 現在時刻再設定
                dtlog = DateTime.Now;

                // 接続終了でない場合
                if (this.m_bExit == false)
                {
#if DEBUG
                    // 接続文字列取得
                    strlogdata += this.GetConnectionString() + ",";
                    // 履歴作成
                    strlogdata += TdcBaseSocket.ConnectionStatusString(TdcBaseSocket.ConnectionStatus.RECONNECT);

                    Debug.WriteLine(strservice + strlogdata);
#endif

                    // 再接続実施
                    this.evConnected(this, ConnectionStatus.RECONNECT);

                    // 再接続処理
                    this.StartConnect();
                }
            }
            catch (Exception ex)
            {
                this.Error = ex;
            }
            finally
            {
                // 再接続処理を有効にする
                this.m_bReconnectEnable = true;

                // 再接続処理スレッドをクリアする
                m_trdReConnect = null;
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続/切断通知
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        protected internal virtual void evConnected(Object Sender, ConnectionStatus Status)
        {
            // 通知処理
            if (this.ConnectedHandler != null)
            {
                this.ConnectedHandler(this, Status);
            }
        }
        ////----------------------------------------------------------------------------------------------------
        ///// <summary>
        ///// 受信通知
        ///// </summary>
        ///// <param name="Sender">ベースオブジェクト</param>
        ///// <param name="cData">受信バッファ</param>
        ///// <param name="nReceivedSize">受信バッファ内byte数</param>
        ////----------------------------------------------------------------------------------------------------
        //protected internal virtual void evReceived(Object Sender, Byte[] cData, int nReceivedSize)
        //{
        //    // イベントハンドラーチェック
        //    if (this.BaseReceivedHandler != null)
        //    {
        //        this.BaseReceivedHandler(this, cData, nReceivedSize);
        //    }
        //}
        //----------------------------------------------------------------------------------------------------

#endregion

#region パブリックメソッド

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初期設定
        /// </summary>
        /// <param name="strIPAddress">IPアドレス</param>
        /// <param name="nPortNo">接続先ポート番号</param>
        /// <param name="nConnetctInterval">再接続施行間隔[ミリ秒]</param>
        /// <returns>true：成功/false：失敗</returns>
        //----------------------------------------------------------------------------------------------------
        public void SetParams( String strIPAddress, int nPortNo, int nConnetctInterval)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            // 接続先IPアドレス
            this.m_strIPAddress = strIPAddress;

            // 接続先ポートNo設定
            this.m_nPortNo = nPortNo;

            // 再接続施行間隔
            this.m_nConnectInterval = nConnetctInterval;

            // 設定値
            strlogdata = String.Format("接続先情報,IP:{0},ポートNo:{1},再接続施行間隔:{2}", this.m_strIPAddress, this.m_nPortNo, this.m_nConnectInterval);

            // 履歴に追記
            log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);
#if DEBUG
            Debug.WriteLine(strlogdata);
#endif
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 内部ソケット接続情報
        /// </summary>
        /// <returns>接続情報(文字列："接続先IP:？,接続先ポート番号:？")</returns>
        //----------------------------------------------------------------------------------------------------
        public new String GetConnectionString()
        {
            String strret = base.GetConnectionString();
            if( String.IsNullOrEmpty (strret) == true )
            {
                // 未接続時
                strret = TdcBaseSocket.GetConnectionString ( this.m_strIPAddress, this.m_nPortNo );
            }
            return (strret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続開始
        /// </summary>
        /// <returns></returns>
        //----------------------------------------------------------------------------------------------------
        public bool StartConnect()
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
                // 接続解除
                this.Close();

#if DEBUG
                // 履歴作成
                strlogdata = TdcBaseSocket.ConnectionStatusString(TdcBaseSocket.ConnectionStatus.CONNECTION_START);
                Debug.WriteLine(strservice + " " + strlogdata);
#endif
                // 接続開始
                this.evConnected(this, ConnectionStatus.CONNECTION_START);

                // ソケット構築
                Socket soc = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                // 接続開始
                soc.BeginConnect(this.m_strIPAddress, this.m_nPortNo, new AsyncCallback(evConnectCallBack), soc);

                bret = true;
            }
            catch(Exception ex)
            {
                this.Error = ex;

                // 再接続処理
                this.ReConnect(this, ConnectionStatus.ERROR);
            }

            return (bret);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続停止
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void StopConnect()
        {
            // 再接続処理終了
            this.m_bExit = true;

            // 再接続待ち解除
            this.m_evForceConnection.Set();

            // ソケット終了
            this.Close();
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続強制指示
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void ForceConnection()
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            // 強制接続実施
            strlogdata = "強制接続実施";

            log.AddLogInfo(dtlog, strservice, NKKLogging.LOGGING_CLASS.INFO, strlogdata);

            // 再接続中チェック
            if (this.m_bReConnection == true)
            {
                // 再接続処理中の場合

                // 再接続強制シグナルセット
                this.m_evForceConnection.Set();
            }
            else
            {
                // 再接続中でない場合

                // 再接続処理を無効とする
                this.m_bReconnectEnable = false;

                // 接続開始(接続している場合は内部で一度切断してから接続処理を行う)
                this.StartConnect();

                // 再接続処理を有効とする
                this.m_bReconnectEnable = true;
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

#region イベント定義

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 接続完了CallBack関数
        /// </summary>
        /// <param name="ar"></param>
        //----------------------------------------------------------------------------------------------------
        private void evConnectCallBack(IAsyncResult ar)
        {
            // ログ記録クラス取得
            NKKLogging log = NKKLogging.GetInstance();

            // 履歴作成
            DateTime dtlog = DateTime.Now;
            String strservice = this.ServiceName;
            String strlogdata = String.Empty;

            try
            {
                // 接続通知
                this.evConnected( this, ConnectionStatus.CONNECTING);

#if DEBUG
                // 履歴作成
                strlogdata = TdcBaseSocket.ConnectionStatusString(TdcBaseSocket.ConnectionStatus.CONNECTING);
                Debug.WriteLine(strservice + " " + strlogdata);
#endif

                Socket soc = (Socket)ar.AsyncState;
                soc.EndConnect(ar);

                // ソケット登録(接続検出)
                this.SetSocket(ref soc);
            }
            catch (Exception ex)
            {
                this.Error = ex;

                // 再接続処理
                this.ReConnect(this, ConnectionStatus.ERROR);
            }
        }
        //----------------------------------------------------------------------------------------------------

#endregion

    }
    //----------------------------------------------------------------------------------------------------
}
//----------------------------------------------------------------------------------------------------
