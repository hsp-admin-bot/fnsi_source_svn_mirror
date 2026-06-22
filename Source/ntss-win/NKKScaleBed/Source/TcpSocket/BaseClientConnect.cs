///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信 クライアント接続用ベースクラス
// ファイル名 ：BaseClientConnect.cs
// 説明       ：クライアント接続のベース機能を提供する。
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/04/17	中村 竜也			新規作成（スタブ）
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Threading;

namespace NKK.FN3.Common.Library.TcpSocket
{
    /// <summary>
    /// ＦＮ３システムでのクライアントソケット接続の基本機能を提供する。
    /// </summary>
    /// 
    /// <remarks>
    /// BaseClientConnectクラスはＦＮ３システムでソケットのクライアント接続を行う場合に使用する。
    /// BaseClientConnectクラスは登録された接続先リストの情報を使用して、全ての接続先への接続処理を平行して行う。
    /// 接続に成功した場合、ソケットオブジェクトをソケット管理リストに登録する。
    /// ソケットの接続状態と接続処理は周期で監視を行い、切断されたソケットや、接続処理に失敗を検知した場合、再度接続処理を行う。<br />
    /// 
    /// <para>
    /// BaseClientConnectクラスで接続を行うにはInitializeDeviceInformationメソッドで
    /// 接続先リストの登録を行う。登録完了後、StartConnectメソッドを呼び出し接続処理を開始する。
    /// StartConnectメソッドは接続処理監視を行う為のスレッドを作成し起動する。
    /// </para>
    /// 
    /// <para>
    /// 接続処理スレッドでは、接続先リストのＩＰアドレスとポート番号を元に、.NET FrameworkのTcpClientクラスを使用して接続を行う。
    /// TcpClientで接続が成功した場合、接続相手の情報を取得し接続対象としての正当性を検証する。
    /// BaseClientConnectクラスで行う正当性検証処理は接続相手のＭＡＣアドレスを接続先リストの情報と比較する事で行う。
    /// 接続先リストの情報と接続相手の情報が一致した場合はBaseSocketクラスを作成しソケット管理リストに登録する。
    /// 正当性検証処理を独自に実装したい場合、ConnectHandlerプロパティを使用して接続通知ハンドラを登録し、ハンドラ内に処理を実装する。
    /// TcpClientでの接続に失敗した場合や正当な接続相手ではない場合、作成されたTcpClientオブジェクトは破棄される。
    /// 接続が確立できなかった接続先は次周期で再度接続処理が行われる。
    /// </para>
    /// 
    /// <para>
    /// アプリケーションでBaseClientConnectクラスで発生した例外をハンドルしたい場合は、
    /// ExceptionHandlerプロパティを使用して、例外発生時に呼び出すメソッドの登録を行う。
    /// </para>
    /// 
    /// <para>
    /// 接続処理を終了する場合はEndConnectメソッドを呼び出す。
    /// EndConnectメソッドは接続処理スレッドを停止し接続処理を終了する。
    /// 接続中のソケットは全てクローズしインスタンスは破棄する。
    /// </para>
    /// 
    /// <para>
    /// 接続先リストを変更したい場合はReleaseDeviceInformationを呼び出し内部で保持している接続先リストを
    /// 破棄し、その後InitializeDeviceInformationメソッドを呼び出して装置情報リストを登録しなおす。
    /// ReleaseDeviceInformationを呼び出さずにInitializeDeviceInformationで装置情報を書き換える事は出来ない。
    /// EndListenerを呼び出さずにReleaseDeviceInformationを呼び出した場合、内部でEndConnectメソッドを呼び出して
    /// 接続処理の終了を行う。
    /// </para>
    /// 
    /// <para>
    /// 以下にBaseServerConnectの使用例を示す。
    /// </para>
    /// </remarks>
    /// 
    /// <example>
    /// 作成
    /// <code>
    /// BaseClientConnect client = null;
    /// DeviceInformation[] devInfo = null;
    ///
    /// {
    ///		client = new BaseClientConnect();
    /// }
    /// </code>
    /// </example>
    /// 
    /// <example>
    /// 装置情報初期化
    /// <code>
    ///	{
    ///		//接続先装置情報リストの初期化(設定値は適切な値を設定する事)
    ///		devInfo = new DeviceInformation[3];
    ///		devInfo[0] = new DeviceInformation();
    ///		devInfo[0]._ipAddress = "localhost";
    ///		devInfo[0]._portNo = 10000;
    ///		devInfo[0]._deviceId = "DEVID001";
    ///		devInfo[0]._macAddress = "";
    ///		devInfo[1] = new DeviceInformation();
    ///		devInfo[1]._ipAddress = "localhost";
    ///		devInfo[1]._portNo = 10001;
    ///		devInfo[1]._deviceId = "DEVID002";
    ///		devInfo[1]._macAddress = "";
    ///		devInfo[2] = new DeviceInformation();
    ///		devInfo[2]._ipAddress = "localhost";
    ///		devInfo[2]._portNo = 10002;
    ///		devInfo[2]._deviceId = "DEVID003";
    ///		devInfo[2]._macAddress = "";
    /// 
    ///		//接続先装置情報リストの登録
    ///		client.InitializeDeviceInformation(devInfo);	
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// ハンドラ登録
    /// <code>
    /// //例外ハンドラ定義
    ///	public void MyException(Exception e)
    /// {
    /// }
    /// 
    /// //接続イベントハンドラ定義
    /// public void MyConnect(TcpClient sock, DeviceInformation devInf)
    /// {
    /// }
    /// 
    /// {
    ///		//ハンドラの登録
    ///		client.ExceptionHandler = MyException;	//例外ハンドラ
    ///		client.AcceptHandler = MyConnect;		//接続イベントハンドラ
    /// }
    /// </code>
    /// </example>
    /// 
    /// <example>
    /// 接続処理開始
    /// <code>
    /// {
    /// 	//接続待ち処理開始
    ///		client.StartConnect();
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 装置情報解放
    /// <code>
    /// {
    ///		client.ReleaseDeviceInformation();
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 接続処理終了
    /// <code>
    /// {
    ///		//接続処理の終了
    ///		client.EndConnect();
    ///	}
    /// </code>
    /// </example>
    public class BaseClientConnect : BaseConnect
    {
        /// <summary>
        /// 接続処理周期（単位：ｍｓ）
        /// </summary>
        private static int m_connectCycle = 1000;

        /// <summary>
        /// 接続イベント用デリゲート定義
        /// </summary>
        /// <remarks>
        /// TcpClientレベルでの接続が確立した場合にBaseClientConnectから呼び出されるハンドラを登録する為のデリゲートである。
        /// アプリケーション実装者は本メソッドの中でBaseSocketクラス（又はその継承クラス）のインスタンスを作成し、
        /// 本メソッドの戻り値としてBaseClientConnectクラスに渡す。
        /// BaseClientConnectは取得したBaseSocketクラス（又はその継承クラス）のインスタンスをソケット管理リストに登録し
        /// 以降、内部で管理を行う。
        /// </remarks>
        public delegate BaseSocket dgtOnConnect(TcpClient sock, dgtOnException_Mng eHander, DeviceInformation devInf);

        private dgtOnConnect m_dgtConnect = null;
        private AsyncCallback m_cbConnect = null;

        /// <summary>
        /// 接続処理ワーカースレッド管理用リスト
        /// </summary>
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
        //private ConnectWorkerThread[] m_worker = null;
        private List<ConnectWorkerThread> m_worker = null;
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）

        #region プロパティ
        /// <summary>
        /// コネクトハンドラを登録する。
        /// </summary>
        public dgtOnConnect ConnectHandler
        {
            set
            {
                m_dgtConnect = new dgtOnConnect(value);
                m_cbConnect = new AsyncCallback(ConnectCallBack);
            }
        }

        #region ConnectCycle: 接続処理周期値取得＆設定
        /// <summary>
        /// 接続処理周期値取得＆設定
        /// </summary>
        /// <remarks>
        /// 接続処理スレッドの処理周期を取得または設定する。
        /// 単位はmsで設定する。処理周期の設定値は1以上～int.MaxValueの範囲で設定する。
        /// 設定値が範囲を超えた場合、設定されない。
        /// 初期値は1000。
        /// </remarks>
        public static int ConnectCycle
        {
            get { return BaseClientConnect.m_connectCycle; }
            set
            {
                if (1 <= value && value < int.MaxValue)
                {
                    BaseClientConnect.m_connectCycle = value;
                }
            }
        }
        #endregion

        #endregion

        #region BaseClientConnect
        /// <summary>
        /// BaseSocketクラスのコンストラクタ
        /// </summary>
        /// <remarks>
        /// BaseSocketクラスのインスタンスの作成を行う。
        /// </remarks>
        public BaseClientConnect()
            : base()
        {
        }
        #endregion

        #region 接続処理を開始する。
        /// <summary>
        /// 接続処理を開始する。
        /// </summary>
        /// <remarks>
        /// 接続処理を行う為のスレッドを作成し、実行する。
        /// </remarks>
        /// <returns>
        /// 正常終了の場合、trueを返す。
        /// 接続先装置情報が未登録の場合や、接続処理スレッドが既に起動している場合はfalseを返す。
        /// </returns>
        public bool StartConnect()
        {
            bool ret = false;
            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            //if (m_devInfo != null && m_devInfo.Length > 0)
            if (m_devInfo != null && m_devInfo.Count > 0)
            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            {
                if (m_thread == null)
                {
                    m_threadRun = true;
                    m_thread = new Thread(new ThreadStart(ConnectThread));
                    m_thread.Start();

                    ret = true;
                    TraceWrite(
                        "{0} クライアント接続処理開始",
                        System.Diagnostics.Process.GetCurrentProcess().ProcessName
                    );
                }
            }

            return ret;
        }
        #endregion

        #region EndConnect: 接続処理を終了する。
        /// <summary>
        /// 接続処理を終了する。
        /// </summary>
        /// <remarks>
        /// 接続処理を行う為のスレッドを終了し、破棄する。
        /// </remarks>
        public void EndConnect()
        {
            if (m_thread != null)
            {
                m_threadRun = false;
                //thread.Abort();
                m_thread = null;

                //m_lw.Write( "クライアント接続処理終了");
                TraceWrite(
                    "{0} クライアント接続処理終了",
                    System.Diagnostics.Process.GetCurrentProcess().ProcessName
                );
            }
        }
        #endregion

        #region protectedメソッド
        ///// <summary>
        ///// 接続確立時の処理を行う。
        ///// </summary>
        ///// <remarks>
        ///// 接続確立時に接続処理スレッドから呼び出される。接続確立時に独自の処理を行いたい場合は
        ///// 本メソッドをオーバーライドし処理を記述する。
        ///// </remarks>
        ///// <param name="sock">
        ///// 接続が確立したソケットオブジェクト。
        ///// </param>
        ///// <param name="devInf">
        ///// 接続時に使用した接続先情報。
        ///// </param>
        ///// <returns>
        ///// BaseSocketクラス（又はその継承クラス）のインスタンスを返す。
        ///// </returns>
        //protected virtual BaseSocket ConnectProc(TcpClient sock, DeviceInformation devInf)
        //{
        //    BaseSocket baseSock = new BaseSocket(sock);
        //    return baseSock;
        //}
        #endregion

        #region privateメソッド

        #region ConnectCallBack: 接続通知ハンドラコールバック
        /// <summary>
        /// 接続通知ハンドラコールバック
        /// </summary>
        private void ConnectCallBack(IAsyncResult ar)
        {
            dgtOnConnect dgt = (dgtOnConnect)(((System.Runtime.Remoting.Messaging.AsyncResult)ar).AsyncDelegate);
            // 非同期メソッドの結果を得るためにEndInvokeを呼ぶ
            BaseSocket bs = dgt.EndInvoke(ar);
            DeviceInformation di = bs.DevInfo;
            int index = SearchDevList(di);
            if (index > -1)
            {
                m_sockList[index] = bs;
                TraceWrite(
                    "No.{0} 接続完了 : {1}",
                    index.ToString("000"), bs.DevInfo.DevInfoStr
                );
                // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                //新規追加の接続の場合
                if (m_worker.Count != m_sockList.Count)
                {
                    ConnectWorkerThread l_worker = null;
                    m_worker.Add(l_worker);
                }
                // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）                
                m_worker[index] = null;
            }
            //すでに接続済みの場合はエラー
            else
            {
                //接続解放
                bs.Release();
                bs = null;
                TraceWrite(
                    "{0} 指定接続外接続発生！！ {1}",
                    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    bs.DevInfo.DevInfoStr
                );
            }
        }
        #endregion

        #region ConnectThread: 接続処理スレッド
        /// <summary>
        /// 接続処理スレッド
        /// </summary>
        private void ConnectThread()
        {
            try
            {
                if (m_worker == null)
                {
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    //m_worker = new ConnectWorkerThread[m_devInfo.Length];
                    ConnectWorkerThread[] m_workerBuff = new ConnectWorkerThread[m_devInfo.Count];
                    m_worker = new List<ConnectWorkerThread>(m_workerBuff);
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                }

                while (m_threadRun)
                {
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    //for (int i = 0; i < m_sockList.Length; i++)
                    for (int i = 0; i < m_sockList.Count; i++)
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    {
                        //すでに接続されている場合は、nullではないため中の処理に入らない
                        if (m_sockList[i] == null)
                        {
                            if (m_worker[i] == null)
                            {
                                m_worker[i] = new ConnectWorkerThread(m_devInfo[i]);
                            }
                            else if (m_worker[i].ConnectMode == ConnectWorkerThread.CONNECTMODE.CONNECTED)
                            {
                                //接続イベントハンドラが登録されている
                                if (m_dgtConnect != null)
                                {
                                    //ハンドラの呼び出し（非同期で呼び出し）
                                    m_dgtConnect.BeginInvoke(m_worker[i].ClientSocket, this.ExceptionProc, m_devInfo[i], m_cbConnect, null);
                                }
                                //接続イベントハンドラが登録されていない
                                else
                                {
                                    BaseSocket bs = new BaseSocket(m_worker[i].ClientSocket, ExceptionProc, m_devInfo[i]);
                                    m_sockList[i] = bs;
                                    //lw.Write( "No.{0} 接続完了", i.ToString("000"));
                                    //m_lw.Write(
                                    //     
                                    //    "No.{0} 接続完了 : {1}",
                                    //    i.ToString("000"), m_devInfo[i].DevInfoStr
                                    //);
                                    TraceWrite(
                                        "{0} No.{1} 接続完了 : {2}",
                                        System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                                        i.ToString("000"), m_devInfo[i].DevInfoStr
                                    );
                                    m_worker[i] = null;
                                }
                            }
                            else if (m_worker[i].ConnectMode == ConnectWorkerThread.CONNECTMODE.ERROR)
                            {
                                m_worker[i] = null;
                            }
                        }
                    }

                    Thread.Sleep(m_connectCycle);
                }

                if (m_worker != null)
                {
                    for (int i = 0; i < m_worker.Count; i++)
                    {
                        try
                        {
                            m_worker[i]?.End();
                        }
                        catch
                        {
                            m_worker[i] = null;
                        }
                    }

                    m_worker.Clear();
                    m_worker = null;
                }
            }
            catch (Exception e)
            {
                ErrorWrite(e, "{0} 接続処理スレッド例外発生 ！！", System.Diagnostics.Process.GetCurrentProcess().ProcessName);
            }
        }
        #endregion

        #endregion
    }
}
