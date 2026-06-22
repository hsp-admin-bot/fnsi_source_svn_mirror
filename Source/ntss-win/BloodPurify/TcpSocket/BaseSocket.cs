///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信用ベースクラス
// ファイル名 ：BaseSocket.cs
// 説明       ：
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/04/17	中村 竜也			新規作成
//  2009/03/02  細井 俊一           切断手順を追加
//  2009/05/15  細井 俊一           不要ログ削除
//  2009/06/19  細井 俊一           #335対応 ソケットクラスオブジェクト解放漏れ修正
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections;
using System.IO;
using System.Net.Sockets;
using System.Reflection;
using System.Threading;
using NKKLoggingLib;

namespace NKK.FN3.Common.Library.TcpSocket
{
    /// <summary>
    /// TCP/IPソケット通信の基本機能を提供する。
    /// </summary>
    /// <remarks>
    /// BaseSocketクラスはＦＮ３システムでTCP/IPを使用してのデータの送受信を行う為の機能を提供する。<br />
    /// 送信機能は同期での機能を、受信機能は非同期での機能を提供する。
    /// BaseSocketクラスは受信機能を非同期で行う為にインスタンス作成時、受信待機用スレッドを作成し起動する。
    /// 
    /// <para>
    /// BaseSocketクラスはTCP/IP通信を実現するためにTcpClientクラスの機能を使用する。
    /// BaseSocketクラス内部で使用するTcpClientクラスのインスタンスはBaseSocketクラスのインスタンス作成時にパラメータで渡す。
    /// BaseSocketクラスで使用するTcpClientはインスタンス作成時のパラメータで渡される。
    /// この時に指定するTcpClientのインスタンスは接続が確立していなければならない。接続が確立していないTcpClientのインスタンスを
    /// 指定した場合、BaseSocketクラスのコンストラクタは例外を発生する。
    /// </para>
    /// 
    /// <para>
    /// 以下にBaseSocketの使用例を示す。
    /// </para>
    /// </remarks>
    /// <example>
    /// ソケットオブジェクト取得
    /// <code>
    /// BaseServerConnect server;
    /// 
    /// {
    ///		DeviceInformation devInf = new DeviceInformation();
    ///		//装置情報を設定する
    ///		devInf._ipAddress = "xxx.xxx.xxx.xxx";
    ///			.
    ///			.
    ///			.
    /// 
    ///		BaseSocket sock = server.GetObject(devInf);
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 送信
    /// <code>
    /// {
    ///		byte[] buf = new byte[1024];
    ///		//メッセージ設定を行う
    ///		buf[nn] = nn;
    ///			.
    ///			.
    ///			.
    /// 
    ///		sock.Send(buf, buf.Length);
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 受信
    /// <code>
    /// 
    /// void MyReceive()
    /// {
    ///		ReceiveStream rcvMsg = sock.GetReceiveData();
    ///		if(rcvMsg != null)
    ///		{
    ///			//メッセージ解析処理
    ///				.
    ///				.
    ///				.
    ///		}
    /// }
    /// 
    /// //受信ハンドラ登録
    /// {
    ///		sock.ReceiveHandler = MyReceive;
    /// }
    /// </code>
    /// </example>
    public class BaseSocket
    {
        /// <summary>
        /// 受信イベント用デリゲート定義
        /// </summary>
        /// <remarks>
        /// データ受信時に呼び出されるハンドラを登録する為のデリゲートである。
        /// </remarks>
        public delegate void dgtOnReceived(BaseSocket sender);
        /// <summary>
        /// 例外イベント用デリゲート定義
        /// </summary>
        /// <remarks>
        /// 例外発生時に呼び出されるハンドラを登録する為のデリゲートである。
        /// </remarks>
        public delegate void dgtOnException(BaseSocket sender, System.Exception e);

        private int m_receiveThreadCycle = 500;
        private int m_receiveBufferSize = 1024;
        private int m_receiveTimeOut = 1;
        private int m_sendTimeOut = 30000;

        private dgtOnReceived m_dgtReceive = null;
        private dgtOnException m_dgtException = null;
        private dgtOnException_Mng m_dgtException_Mng = null;

        private DeviceInformation m_devInfo = null;
        private TcpClient m_sock = null;
        private NetworkStream m_ns = null;
        private object m_syncSocket = new object();

        private Thread m_rcvThread = null;
        private bool m_runFlg = true;
        private ArrayList m_rcvList = new ArrayList();

        #region プロパティ
        /// <summary>
        /// 受信ハンドラを登録する。
        /// </summary>
        public dgtOnReceived ReceiveHandler
        {
            set
            {
                m_dgtReceive = new dgtOnReceived(value);
            }
        }

        /// <summary>
        /// 例外ハンドラを登録する。
        /// </summary>
        public dgtOnException ExceptionHandler
        {
            set
            {
                m_dgtException = new dgtOnException(value);
            }
        }

        /// <summary>
        /// ソケットが接続している装置の情報を取得する。
        /// </summary>
        public DeviceInformation DevInfo
        {
            get
            {
                return m_devInfo;
            }
        }

        /// <summary>
        /// 受信データ確認周期の取得、設定
        /// </summary>
        /// <remarks>
        /// 受信スレッドで受信データ有無を確認する周期を取得、設定する。
        /// </remarks>
        public int ReceiveCycle
        {
            get { return m_receiveThreadCycle; }
            set
            {
                if (1 <= value && value < int.MaxValue)
                {
                    m_receiveThreadCycle = value;
                }
            }
        }

        /// <summary>
        /// 受信バッファサイズの取得、設定
        /// </summary>
        public int ReceiveBufferSize
        {
            get { return m_receiveBufferSize; }
            set { m_receiveBufferSize = value; }
        }

        /// <summary>
        /// 受信待ちタイムアウト値の取得、設定
        /// </summary>
        public int ReceiveTimeOut
        {
            get { return m_receiveTimeOut; }
            set { m_receiveTimeOut = value; }
        }

        /// <summary>
        /// 送信完了待ちタイムアウト値の取得、設定
        /// </summary>
        public int SendTimeOut
        {
            get { return m_sendTimeOut; }
            set { m_sendTimeOut = value; }
        }
        #endregion

        /// <summary>
        /// BaseSocketクラスのコンストラクタ
        /// </summary>
        /// <remarks>
        /// 引数で渡すTcpClientは接続が確立している事。
        /// </remarks>
        /// <param name="sock">
        /// TcpClient型のソケットオブジェクト。ソケットは接続が確立している事（※必須）。
        /// </param>
        /// <exception cref="System.Exception">
        /// 引数で渡すソケットオブジェクトで接続が確立していない場合に発生する。
        /// </exception>
        //[Obsolete("このコンストラクタは使用しないで下さい。")]
        public BaseSocket(TcpClient sock)
        {
            Initialize(sock);
        }

        /// <summary>
        /// BaseSocketクラスのコンストラクタ
        /// </summary>
        /// <remarks>
        /// 引数で渡すTcpClientは接続が確立している事。
        /// </remarks>
        /// <param name="sock">
        /// TcpClient型のソケットオブジェクト。ソケットは接続が確立している事（※必須）。
        /// </param>
        /// <param name="mngHandler">
        /// 例外発生時に接続処理を行う、BaseConnectクラス（又はその継承クラス）のインスタンス
        /// </param>
        /// <param name="devInfo">
        /// ソケットの接続先の装置情報
        /// </param>
        /// <exception cref="System.Exception">
        /// 引数で渡すソケットオブジェクトで接続が確立していない場合に発生する。
        /// </exception>
        public BaseSocket(TcpClient sock, dgtOnException_Mng mngHandler, DeviceInformation devInfo)
        {
            Initialize(sock);
            m_dgtException_Mng = mngHandler;
            m_devInfo = devInfo;
        }

        private string ConvertEscapeSequence(string aMsg)
        {
            string ret = aMsg;
            ret = ret.Replace(",", "、");
            ret = ret.Replace("\r\n", "{CRLF}");
            ret = ret.Replace("\r", "{CRLF}"); // CR だけど {CRLF} に
            ret = ret.Replace("\n", "{CRLF}"); // LF だけど {CRLF} に

            return ret;
        }

        private string GetAsmProductName()
        {
            object[] productarray = Assembly.GetExecutingAssembly().GetCustomAttributes(typeof(AssemblyProductAttribute), false);
            return ((AssemblyProductAttribute)productarray[0]).Product;
        }

        private void AddLogInfo(DateTime aDt, string aServiceName, string aGUICode, NKKLogging.LOGGING_CLASS aLoggingClass, string aMsg)
        {
            if ("" == NKKLogging.GetInstance().LogExt) { return; } // アプリ終了時にDeleteInstanceした後も残スレッドがログ吐きしてファイル2個になる対策(通信系スレッドの例外 など)

            NKKLogging.GetInstance().AddLogInfo(aDt, aServiceName, aGUICode, aLoggingClass, aMsg);
        }

        /// <summary>
        /// エラーログ書き込み
        /// </summary>
        /// <param name="logCode">ログコード</param>
        /// <param name="ex">例外情報</param>
        /// <param name="mes">メッセージ</param>
        /// <param name="paramList">パラメータリスト</param>
        protected void ErrorWrite(string logCode, Exception ex, string mes, params object[] paramList)
        {
            if ((null == paramList) || (0 == paramList.Length))
            {
                string formattedMsg = ("" == mes ? "" : mes + " ")
                    + (null != ex ? "ExMsg[" + ex.Message + "] StackTrace[" + ex.StackTrace + "]" : "");
                formattedMsg = ConvertEscapeSequence(formattedMsg);

                AddLogInfo(DateTime.Now, GetAsmProductName(), GetType().Name, NKKLogging.LOGGING_CLASS.ERROR, formattedMsg);
            }
            else
            {
                string formattedMsg = ("" == mes ? "" : string.Format(mes, paramList) + " ")
                    + (null != ex ? "ExMsg[" + ex.Message + "] StackTrace[" + ex.StackTrace + "]" : "");
                formattedMsg = ConvertEscapeSequence(formattedMsg);

                AddLogInfo(DateTime.Now, GetAsmProductName(), GetType().Name, NKKLogging.LOGGING_CLASS.ERROR, formattedMsg);
            }
        }

        /// <summary>
        /// トレースログ書き込み
        /// </summary>
        /// <param name="logCode">ログコード</param>
        /// <param name="mes">メッセージ</param>
        /// <param name="paramList">パラメータリスト</param>
        protected void TraceWrite(string logCode, string mes, params object[] paramList)
        {
            if ((null == paramList) || (0 == paramList.Length))
            {
                AddLogInfo(DateTime.Now, GetAsmProductName(), GetType().Name, NKKLogging.LOGGING_CLASS.INFO, ConvertEscapeSequence(mes));
            }
            else
            {
                AddLogInfo(DateTime.Now, GetAsmProductName(), GetType().Name, NKKLogging.LOGGING_CLASS.INFO, ConvertEscapeSequence(string.Format(mes, paramList)));
            }
        }

        /// <summary> @@@@
        /// BaseSocket内部リソース解放処理
        /// </summary>
        /// <remarks>
        /// BaseSocketクラスが使用している内部リソースの解放を行う。
        /// 受信待機用のスレッドの終了待ちの為、[_receiveThreadCycle] ms 時間がかかる。
        /// </remarks>
        public void Release()
        {
            lock (m_syncSocket)
            {
                if (m_runFlg == true)
                {
                    m_runFlg = false;
                    Thread.Sleep(m_receiveThreadCycle);
                }
                if (m_rcvThread != null)
                {
                    m_rcvThread.Abort();
                    m_rcvThread = null;
                }
                if (m_ns != null)
                {
                    //m_ns.Close();
                    //m_ns = null;
                }
                if (m_sock != null)
                {
                    if (m_sock.Client != null)
                    {
                        // ADD 2009/03/02 切断手順を追加
                        m_sock.Client.Shutdown(SocketShutdown.Receive);
                        // ADD 2009/03/02 切断手順を追加
                        // ADD 2009/06/19 #335
                        if (m_ns != null)
                        {
                            m_ns.Close();
                            m_ns = null;
                        }
                        m_sock.Client.Close();
                    }
                    // ADD 2009/06/19 #335
                    m_sock.Close();
                    m_sock = null;
                }
            }
        }

        /// <summary>
        /// データを送信する。
        /// </summary>
        /// <remarks>
        /// 引数で渡されたデータの送信を行う。
        /// </remarks>
        /// <param name="data">
        /// 送信したいデータ
        /// </param>
        /// <param name="size">
        /// 送信データ長
        /// </param>
        /// <returns>
        /// 正常終了時は送信完了したデータサイズを返す。
        /// </returns>
        /// <exception cref="ArgumentNullException">
        /// buffer が null 参照。
        /// </exception>
        /// <exception cref="ArgumentOutOfRangeException">
        /// size が 0 未満。または、size が、buffer の長さを超えている。 
        /// </exception>
        /// <exception cref="IOException">
        /// ネットワークへの書き込み中にエラーが発生した。 
        /// またはソケットへのアクセス中にエラーが発生した。
        /// </exception>
        /// <exception cref="ObjectDisposedException">
        /// NetworkStream が閉じている。 
        /// </exception>
        public int SendData(byte[] data, int size)
        {
            int ret = 0;

            try
            {
                //if (_sock != null)
                {
                    lock (m_syncSocket)
                    {
                        //if (_sock != null)
                        {
                            m_ns.Write(data, 0, size);
                            ret = size;
                        }
                    }
                }
            }
            catch (Exception e)
            {
                if (m_devInfo != null)
                {
                    //m_lw.Write(
                    //    
                    //    
                    //    "0630030006",
                    //    "{0}.BaseSocket.SendData 例外発生！！ {1} {2}",
                    //    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    //    m_devInfo.DevInfoStr,
                    //    e.Message
                    //);
                }
                else
                {
                    ErrorWrite(
                        "0630030007",
                        e,
                        "{0}.BaseSocket.ReceveThread 例外発生！！ {1}",
                        System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                        e.Message
                    );
                }

                //BaseSocketのリソース解放処理
                InRelease();

                //接続管理クラスへの通知
                if (m_dgtException_Mng != null)
                {
                    m_dgtException_Mng(this, e);
                }

                //アプリケーションへの通知
                if (m_dgtException != null)
                {
                    m_dgtException.BeginInvoke(this, e, null, null);
                }
            }

            return ret;
        }

        /// <summary>
        /// 受信キューから受信データを取得する。
        /// </summary>
        /// <remarks>
        /// 受信キューに保持している受信データから最古の受信データを取得する。
        /// 受信データを取得するとキューからそのデータは削除される。
        /// </remarks>
        /// <returns>
        /// 受信データを格納したReceiveStreamクラスのインスタンスを返す。
        /// 受信キューにデータが存在しない場合、nullを返す。
        /// </returns>
        public ReceiveStream GetReceiveData()
        {
            ReceiveStream rs = null;
            lock (m_rcvList)
            {
                if (m_rcvList.Count > 0)
                {
                    rs = (ReceiveStream)m_rcvList[0];
                    m_rcvList.RemoveAt(0);
                }
            }
            return rs;
        }

        #region privateメソッド
        /// <summary>
        /// 内部メンバー初期化処理
        /// </summary>
        /// <param name="sock">
        /// 接続が確立されたソケットのインスタンス
        /// </param>
        private void Initialize(TcpClient sock)
        {
            m_sock = sock;
            m_sock.ReceiveTimeout = m_receiveTimeOut;
            m_sock.SendTimeout = m_sendTimeOut;
            m_ns = sock.GetStream();

            m_rcvThread = new Thread(new ThreadStart(ReceiveThread));
            m_rcvThread.Start();
        }

        /// <summary>
        /// 受信処理を行う
        /// </summary>
        private void ReceiveThread()
        {
            bool closeFlg = false;
            // ADD S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
            bool waitFlg = false;
            // ADD S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
            try
            {
#if NO_RELEASE
				m_lw.Write(
					
					
					"9999999999",
					"LingerState:[{0}][{1}]",
					m_sock.Client.LingerState.Enabled,
					m_sock.Client.LingerState.LingerTime);
				m_lw.Write(
					
					
					"9999999999",
					"  NoDelay {0}",
					m_sock.Client.NoDelay);

				m_lw.Write(
					
					
					"9999999999",
					"  ReceiveBufferSize {0}",
					m_sock.Client.ReceiveBufferSize);

				m_lw.Write(
					
					
					"9999999999",
					"  ReceiveTimeout {0}",
					m_sock.Client.ReceiveTimeout);

				m_lw.Write(
					
					
					"9999999999",
					"  SendBufferSize {0}",
					m_sock.Client.SendBufferSize);

				m_lw.Write(
					
					
					"9999999999",
					"  SendTimeout {0}",
					m_sock.Client.SendTimeout);

				m_lw.Write(
					
					
					"9999999999",
					"  Ttl {0}",
					m_sock.Client.Ttl);
               m_lw.Write(
					
					
					"9999999999",
				   "  IsBound {0}",
					m_sock.Client.IsBound);
#endif

                byte[] buf = new byte[m_receiveBufferSize];
                while (m_runFlg)
                {
                    //if (_sock != null)
                    {
                        lock (m_syncSocket)
                        {
                            //if (_sock != null)
                            {
                                //受信データの有無を判定
                                if (m_sock.Client.Poll(1, SelectMode.SelectRead))
                                {
                                    //受信可能データ数を取得する
                                    if (m_sock.Client.Available > 0)
                                    {
                                        int readSize = m_ns.Read(buf, 0, buf.Length);
                                        if (readSize > 0)
                                        {
                                            ReceiveStream rs = new ReceiveStream();
                                            rs.rcvData = buf;
                                            rs.rcvSize = readSize;

                                            //受信データを受信データキューにセット
                                            lock (m_rcvList)
                                            {
                                                m_rcvList.Add(rs);
                                            }
                                            buf = new byte[m_receiveBufferSize];

                                            //受信イベントハンドラが設定されている場合、呼び出しを行う。
                                            if (m_dgtReceive != null)
                                            {
                                                m_dgtReceive.BeginInvoke(this, null, null);
                                            }
                                        }
                                    }
                                    // 0の場合は、受信データ終了の合図
                                    else if (m_sock.Client.Available == 0)
                                    {
                                        throw new Exception();
                                    }
                                    //受信データ有りなのに受信可能データ数が０以下の場合
                                    //※切断されたと判定
                                    else
                                    {
                                        if (m_sock.Client != null)
                                        {
                                            // ADD 2009/03/02 切断手順を追加
                                            m_sock.Client.Shutdown(SocketShutdown.Receive);
                                            // ADD 2009/03/02 切断手順を追加
                                            m_sock.Client.Close();
                                        }
                                        m_sock.Close();
                                        m_sock = null;

                                        closeFlg = true;
                                        throw new Exception();
                                    }
                                }
                                else
                                {
                                    // CHG S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
                                    //Thread.Sleep(m_receiveThreadCycle);
                                    waitFlg = true;
                                    // CHG S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
                                }
                            }
                        }
                        // ADD S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
                        if (waitFlg == true)
                        {
                            Thread.Sleep(m_receiveThreadCycle);
                            waitFlg = false;
                        }
                        // ADD S.Hosoi 2008/10/15 パフォーマンス改善対応（不具合番号：XXXXX）
                    }
                    //else
                    //{
                    //    Thread.Sleep(_receiveThreadCycle);
                    //}
                }

                TraceWrite(
                    "0610030008",
                    "{0}.BaseSocket.ReceiveThread 終了 {1}",
                    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    m_devInfo.DevInfoStr
                );
            }
            catch (Exception e)
            {
                string msg = string.Empty;
                if (closeFlg == true)
                {
                    msg = "接続断発生！！";
                }
                else
                {
                    msg = "例外発生！！";
                }

                if (m_devInfo != null)
                {
                    //m_lw.Write(
                    //    
                    //    
                    //    "0630030009",
                    //    "{0}.BaseSocket.ReceiveThread {1} {2} {3}",
                    //    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    //    msg,
                    //    m_devInfo.DevInfoStr,
                    //    e.Message
                    //);
                }
                else
                {
                    //m_lw.Write(
                    //    
                    //    
                    //    "0630030010",
                    //    "{0}.BaseSocket.ReceiveThread {1} {2}",
                    //    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    //    msg,
                    //    e.Message
                    //);
                }

                // CHG S.Hosoi 2008/10/01 例外ハンドラが呼び出されない不具合対応（不具合番号：XXXXX）
                //BaseSocketのリソース解放処理
                //Release();
                InRelease();
                // CHG S.Hosoi 2008/10/01 例外ハンドラが呼び出されない不具合対応（不具合番号：XXXXX）


                //アプリケーションへの通知
                if (m_dgtException != null)
                {
                    m_dgtException.BeginInvoke(this, e, null, null);
                }

                //接続管理クラスへの通知
                if (m_dgtException_Mng != null)
                {
                    m_dgtException_Mng(this, e);
                }
            }
        }

        // ADD S.Hosoi 2008/10/01 例外ハンドラが呼び出されない不具合対応（不具合番号：XXXXX）

        /// <summary> @@@@
        /// BaseSocket内部リソース解放処理
        /// </summary>
        /// <remarks>
        /// BaseSocketクラスが使用している内部リソースの解放を行う。
        /// 受信待機用のスレッドの終了待ちの為、[_receiveThreadCycle] ms 時間がかかる。
        /// </remarks>
        private void InRelease()
        {
            lock (m_syncSocket)
            {
                if (m_runFlg == true)
                {
                    m_runFlg = false;
                    Thread.Sleep(m_receiveThreadCycle);
                }

                if (m_ns != null)
                {
                    //m_ns.Close();
                    //m_ns = null;
                }
                if (m_sock != null)
                {
                    if (m_sock.Client != null)
                    {
                        // ADD 2009/03/02 切断手順を追加
                        m_sock.Client.Shutdown(SocketShutdown.Both);
                        // ADD 2009/03/02 切断手順を追加
                        m_sock.Client.Close();
                    }
                    // ADD 2009/06/19 #335
                    if (m_ns != null)
                    {
                        m_ns.Close();
                        m_ns = null;
                    }
                    m_sock.Client.Close();
                    // ADD 2009/06/19 #335
                    m_sock.Close();
                    m_sock = null;
                }
            }
        }

        // ADD S.Hosoi 2008/10/01 例外ハンドラが呼び出されない不具合対応（不具合番号：XXXXX）

        #endregion
    }
}
