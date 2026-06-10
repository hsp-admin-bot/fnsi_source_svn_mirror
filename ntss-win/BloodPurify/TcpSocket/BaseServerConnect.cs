///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信 サーバー接続用ベースクラス
// ファイル名 ：BaseServerConnect.cs
// 説明       ：サーバー接続のベース機能を提供する。
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/04/17	中村 竜也			新規作成
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Sockets;
using System.Threading;

namespace NKK.FN3.Common.Library.TcpSocket
{
    /// <summary>
    /// ＦＮ３システムでのサーバー接続の基本機能を提供する。
    /// </summary>
    /// <remarks>
    /// BaseServerConnectクラスはＦＮ３システムでソケットのサーバー接続を行う場合に使用する。
    /// BaseServerConnectクラスで接続要求を待機するにはInitializeDeviceInformationメソッドで
    /// 接続先リストの登録を行う。登録完了後、StartListenerメソッドを呼び出し受信待機処理を開始する。
    /// 
    /// <para>
    /// 接続要求が発生した場合、接続対象となる相手からの要求か判定を行う。
    /// BaseServerConnectクラスで行う判定処理は接続相手のＩＰアドレスとポート番号、ＭＡＣアドレスを
    /// 接続先リストに登録された情報と比較する。接続先リストにこれら情報が存在し、かつ未接続の場合は
    /// 接続要求を受け付ける。接続先リストに存在しない接続先からの接続要求の場合や既に接続が確立した
    /// 接続先から再度接続要求が発生した場合、接続要求は破棄される。
    /// </para>
    /// 
    /// <para>
    /// 接続受付判定を独自に実装したい場合、AcceptHandlerプロパティを使用して接続要求発生時に呼び出す
    /// メソッドの登録を行い、そのメソッド内で接続判定処理を実装する。
    /// また、アプリケーションでBaseServerConnectクラスで発生した例外をハンドルしたい場合は、
    /// ExceptionHandlerプロパティを使用して、例外発生時に呼び出すメソッドの登録を行う。
    /// </para>
    /// 
    /// <para>
    /// 接続待機処理を終了する場合はEndListenerメソッドを呼び出す。
    /// EndListenerメソッドでは接続待機用スレッドを停止し接続待機を終了する。
    /// 接続中のソケットは全てクローズしインスタンスは破棄する。
    /// </para>
    /// 
    /// <para>
    /// 接続先リストを変更したい場合はReleaseDeviceInformationを呼び出し内部で保持している接続先リストを
    /// 破棄し、その後InitializeDeviceInformationメソッドを呼び出して装置情報リストを登録しなおす。
    /// ReleaseDeviceInformationを呼び出さずにInitializeDeviceInformationで装置情報を書き換える事は出来ない。
    /// EndListenerを呼び出さずにReleaseDeviceInformationを呼び出した場合、内部でEndListenerメソッドを呼び出して
    /// 接続処理の終了を行う。
    /// </para>
    /// 
    /// <para>
    /// 以下にBaseServerConnectの使用例を示す。
    /// </para>
    /// </remarks>
    /// <example>
    /// 作成
    /// <code>
    /// BaseServerConnect server = null;
    ///	DeviceInformation[] devInfo = null;
    /// 
    ///	{
    ///		server = new BaseServerConnect();
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 装置情報初期化
    /// <code>
    /// {
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
    ///		server.InitializeDeviceInformation(20000, devInfo);
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
    /// //アクセプトハンドラ定義
    /// public void MyAccept(TcpClient sock, DeviceInformation devInf)
    /// {
    /// }
    /// 
    /// {
    ///		//ハンドラの登録
    ///		server.ExceptionHandler = MyException;	//例外ハンドラ
    ///		server.AcceptHandler = MyAccept;		//アクセプトハンドラ
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 接続待機処理開始
    /// <code>
    /// {
    /// 	//接続待ち処理開始
    ///		server.StartListener();
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 装置情報解放
    /// <code>
    /// {
    ///		server.ReleaseDeviceInformation();
    /// }
    /// </code>
    /// </example>
    /// <example>
    /// 接続待機処理終了
    /// <code>
    /// {
    ///		//接続待ち処理の終了
    ///		server.EndListener();
    ///	}
    /// </code>
    /// </example>
    public class BaseServerConnect : BaseConnect
    {
        /// <summary>
        /// AcceptでのException発生通知
        /// </summary>
        public delegate void AcceptException();

        /// <summary>
        /// AcceptThread内で例外が発生した事を通知するイベント
        /// </summary>
        public event AcceptException OnAcceptException;

        // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
        #region DefinitionInformation
        /// <summary>
        /// 接続要求受付ポートMIN番号
        /// </summary>
        private const int m_minPort = 1;
        /// <summary>
        /// 接続要求受付ポートMAX番号
        /// </summary>
        private const int m_maxPort = 65535;


        #endregion
        // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）

        /// <summary>
        /// 接続要求待ち確認周期（単位：ms）
        /// </summary>
        private static int m_acceptCycle = 1000;

        #region Delegate
        /// <summary>
        /// アクセプトイベント用デリゲート定義
        /// </summary>
        public delegate BaseSocket dgtOnAccept(TcpClient sock, dgtOnException_Mng eHandler, DeviceInformation devInf);
        #endregion

        private dgtOnAccept dgtAccept = null;
        private AsyncCallback cbAccept = null;

        /// <summary>
        /// 接続要求待機ポート番号
        /// </summary>
        private int m_svrPortNo = -1;

        #region プロパティ
        /// <summary>
        /// アクセプトハンドラを登録する。
        /// </summary>
        public dgtOnAccept AcceptHandler
        {
            set
            {
                dgtAccept = new dgtOnAccept(value);
                cbAccept = new AsyncCallback(AcceptCallBack);
            }
        }

        /// <summary>
        /// 接続要求待ち確認周期値取得＆設定
        /// </summary>
        /// <remarks>
        /// 接続要求待ちスレッドの確認周期を取得または設定する。
        /// 単位はmsで設定する。確認周期の設定値は1以上～int.MaxValueの範囲で設定する。
        /// 設定値が範囲を超えた場合、設定されない。
        /// 初期値は1000。
        /// </remarks>
        public static int AcceptCycle
        {
            get { return BaseServerConnect.m_acceptCycle; }
            set
            {
                if (1 <= value && value < int.MaxValue)
                {
                    BaseServerConnect.m_acceptCycle = value;
                }
            }
        }
        #endregion

        /// <summary>
        /// 接続先装置情報リストの登録を行う。
        /// </summary>
        /// <remarks>
        /// 接続先装置情報リストの登録を行う。登録は一度行われると、ReleaseDeviceInformationメソッドを呼び出して
        /// 解放してからでないと再度登録は出来ない。
        /// </remarks>
        /// <param name="portNo">
        /// 接続の待ち受けポートＮｏ
        /// </param>
        /// <param name="devInf">
        /// 接続先装置情報が格納されたDeviceInformation型の配列。
        /// </param>
        /// <returns>
        /// 正常に登録されるとtrueを返す。
        /// 接続先装置情報リストが登録済みの場合、falseを返す。
        /// </returns>
        public bool InitializeDeviceInformation(int portNo, DeviceInformation[] devInf)
        {
            bool ret = false;
            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            //if (1 <= portNo && portNo <= 65535)
            if (m_minPort <= portNo && portNo <= m_maxPort)
            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            {
                if (devInf != null)
                {
                    ret = base.InitializeDeviceInformation(devInf);
                }
                // 接続先装置情報指定がない場合は、ポート番号のみ設定する
                else
                {
                    ret = true;
                }
                // ポート番号を設定する
                if (ret == true)
                {
                    m_svrPortNo = portNo;
                }
            }

            return ret;
        }

        /// <summary>
        /// 接続先装置情報リストの解放を行う。
        /// </summary>
        /// <remarks>
        /// 接続先装置情報リストの解放を行う。接続先装置情報リストを解放すると、InitializeDeviceInformationメソッドで再び
        /// 有効な接続先装置情報を登録するまで接続待ち受けは行えない。
        /// </remarks>
        public override void ReleaseDeviceInformation()
        {
            m_svrPortNo = -1;
            base.ReleaseDeviceInformation();
        }

        /// <summary>
        /// 接続待機処理を開始する。
        /// </summary>
        /// <remarks>
        /// 接続待機処理を行う為のスレッドを作成し、実行する。
        /// </remarks>
        /// <returns>
        /// 正常終了の場合、trueを返す。
        /// 接続待機ポート番号や接続先装置情報が未登録の場合、接続処理スレッドが既に起動している場合はfalseを返す。
        /// </returns>
        public bool StartListener()
        {
            bool ret = false;

            if (m_svrPortNo != -1)
            {
                if (m_thread == null)
                {
                    m_threadRun = true;
                    m_thread = new Thread(new ThreadStart(AcceptThread));
                    m_thread.Start();
                    ret = true;
                    TraceWrite("0640030011", "サーバー接続待ち開始");
                }
            }

            return ret;
        }

        /// <summary>
        /// 接続待機処理を終了する。
        /// </summary>
        /// <remarks>
        /// 接続待機処理を行う為のスレッドを終了し、破棄する。
        /// </remarks>
        public void EndListener()
        {
            //スレッドが起動中の場合
            if (m_thread != null)
            {
                m_threadRun = false;
                Thread.Sleep(m_acceptCycle);
                m_thread.Abort();
                m_thread = null;
                TraceWrite("0640030012", "サーバー接続待ち終了");
            }
        }

        #region privateメソッド
        /// <summary>
        /// ソケット接続通知ハンドラ呼び出しのコールバック
        /// </summary>
        /// <remarks>
        /// 非同期デリゲート呼び出しで実行された接続通知イベントハンドラの処理が終了した時に本メソッドが呼び出される。
        /// ハンドラの戻り値でBaseSocketクラス（又はその派生クラス）のインスタンスを取得し、ソケット管理リストに登録する。
        /// ソケットの接続先装置情報とBaseServerConnectクラスで保持する接続先装置情報リストの内容を比較し、リストに登録されて
        /// いない装置情報を持つソケットの場合は、接続を閉じソケットのインスタンスを破棄する。
        /// </remarks>
        private void AcceptCallBack(IAsyncResult ar)
        {
            dgtOnAccept dgt = (dgtOnAccept)(((System.Runtime.Remoting.Messaging.AsyncResult)ar).AsyncDelegate);
            BaseSocket bs = dgt.EndInvoke(ar);
            DeviceInformation di = bs.DevInfo;
            int index = SearchDevList(di);
            //接続先装置情報リストにソケットの接続先情報が存在した場合
            if (index > -1)
            {
                m_sockList[index] = bs;
                TraceWrite(
                    "0610030002",
                    "No.{0} 接続完了 : {1}",
                    index.ToString("000"), bs.DevInfo.DevInfoStr
                );
            }
            //既に接続済みの場合
            else
            {
                //接続解放
                bs.Release();
                bs = null;
                TraceWrite(
                    "0620030003",
                    "{0} 指定接続外接続発生！！ {1}",
                    System.Diagnostics.Process.GetCurrentProcess().ProcessName,
                    bs.DevInfo.DevInfoStr
                );
            }
        }

        /// <summary>
        /// 接続待ちスレッド
        /// </summary>
        private void AcceptThread()
        {
            try
            {
                // CHG S.Hosoi 2008/11/05 Vista対応（不具合番号：XXXXX）
                //IPAddress ipAddress = Dns.GetHostEntry(Dns.GetHostName()).AddressList[0];
                IPAddress ipAddress = IPAddress.Parse("0.0.0.0");
                //IPAddress[] ipAddressAll = Dns.GetHostAddresses("");
                //Int32 index = 0;
                //for (Int16 i = 0; i < ipAddressAll.Length; i++)
                //{
                //    index = 0;
                //    // IPv4アドレスを検索する
                //    index = ipAddressAll[i].ToString().IndexOf(".", 0);
                //    if (index > 0)
                //    {
                //        ipAddress = ipAddressAll[i];
                //        break;
                //    }
                //}
                // CHG S.Hosoi 2008/11/05 Vista対応（不具合番号：XXXXX）

                TcpListener listener = null;
                // CHG S.Hosoi 2008/11/07 複数NIC対応（不具合番号：XXXXX）
                //IPEndPoint ipLocalEndPoint = new IPEndPoint(ipAddress, m_svrPortNo);
                IPEndPoint ipLocalEndPoint = new IPEndPoint(IPAddress.Any, m_svrPortNo);
                // CHG S.Hosoi 2008/11/07 複数NIC対応（不具合番号：XXXXX）
                listener = new TcpListener(ipLocalEndPoint);

                listener.Start();
                while (m_threadRun)
                {
                    if (listener.Pending())
                    {
                        TcpClient client = listener.AcceptTcpClient();
                        if (client != null)
                        {
                            //リモートポイントの情報を取得
                            Socket sock = client.Client;
                            System.Net.IPEndPoint endPoint = sock.RemoteEndPoint as IPEndPoint;
                            int portNo = endPoint.Port;
                            //ＭＡＣアドレス取得
                            string macAdr = GetMacAddress(endPoint.Address);

                            bool illegalConnectFlg = true;
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            bool illegalInfoFlg = true;
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            // ADD S.Hosoi 2008/10/07 InitializeDeviceInformationを行わなくても接続可能とするための対応（不具合番号：XXXXX）
                            int m_devInfoCount = 0;
                            if (m_devInfo != null)
                            {
                                m_devInfoCount = m_devInfo.Count;
                            }
                            // ADD S.Hosoi 2008/10/07 InitializeDeviceInformationを行わなくても接続可能とするための対応（不具合番号：XXXXX）
                            //接続先情報のチェック
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //for (int i = 0; i < m_devInfo.Length; i++)
                            for (int i = 0; i < m_devInfoCount; i++)
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            {
                                IPAddress[] devIpAdr = Dns.GetHostAddresses(m_devInfo[i].IpAddress);

                                //接続先情報とリモートポイントのＩＰアドレスを比較
                                if (endPoint.Address.Equals(devIpAdr[0]))
                                {
                                    int pn = m_devInfo[i].PortNo;

                                    //接続先情報とリモートポイントのポート番号を比較
                                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                                    //if (portNo == pn)
                                    if (portNo == pn)
                                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                                    {
                                        //接続先情報とリモートポイントのＭＡＣアドレスを比較
                                        if (macAdr.Equals(m_devInfo[i].MacAddress))
                                        {
                                            illegalConnectFlg = false;
                                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                                            illegalInfoFlg = false;
                                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                                            if (m_sockList[i] == null)
                                            {
                                                //アクセプトイベントハンドラが登録されている
                                                if (dgtAccept != null)
                                                {
                                                    //ハンドラの呼び出し（非同期で呼び出し）
                                                    dgtAccept.BeginInvoke(client, ExceptionProc, m_devInfo[i], cbAccept, null);
                                                }
                                                //アクセプトイベントハンドラが登録されていない
                                                else
                                                {
                                                    m_sockList[i] = new BaseSocket(client, ExceptionProc, m_devInfo[i]);
                                                    TraceWrite(
                                                        "0610030002",
                                                        "No.{0} 接続完了 : {1}",
                                                        i.ToString("000"), m_devInfo[i].DevInfoStr
                                                    );
                                                }
                                            }
                                            else
                                            {
                                                illegalConnectFlg = true;
                                            }

                                            break;
                                        }
                                    }
                                }
                            }
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //接続先装置情報リストに登録されていない場合
                            if (illegalInfoFlg == true)
                            {
                                DeviceInformation l_devInfo = new DeviceInformation(
                                                        endPoint.Address.ToString(),
                                                        portNo,
                                                        macAdr,
                                                        "");

                                illegalConnectFlg = false;

                                //アクセプトイベントハンドラが登録されている
                                if (dgtAccept != null)
                                {
                                    //ハンドラの呼び出し（非同期で呼び出し）
                                    dgtAccept.BeginInvoke(client, ExceptionProc, l_devInfo, cbAccept, null);
                                }
                                //アクセプトイベントハンドラが登録されていない
                                else
                                {
                                    // ADD S.Hosoi 2008/10/07 InitializeDeviceInformationを行わなくても接続可能とするための対応（不具合番号：XXXXX）
                                    if (m_devInfo == null)
                                    {
                                        m_devInfo = new List<DeviceInformation>();
                                    }
                                    if (m_sockList == null)
                                    {
                                        m_sockList = new List<object>();
                                    }
                                    // ADD S.Hosoi 2008/10/07 InitializeDeviceInformationを行わなくても接続可能とするための対応（不具合番号：XXXXX）
                                    m_devInfo.Add(l_devInfo);
                                    BaseSocket l_sockList = new BaseSocket(client, ExceptionProc, l_devInfo); ;
                                    m_sockList.Add(l_sockList);
                                    int l_connectNo = m_devInfo.Count - 1;
                                    TraceWrite(
                                              "0610030002",
                                              "No.{0} 接続完了 : {1}",
                                              l_connectNo.ToString("000"), l_devInfo.DevInfoStr
                                     );
                                }
                            }
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //接続先装置情報リストに登録されているが、既に接続されていた場合
                            if (illegalConnectFlg == true)
                            {
                                TraceWrite(
                                    "0610030004",
                                    "指定接続外接続発生！！ : IPAddress = {0}, PortNo = {1}, MACAddress = {2}",
                                    endPoint.Address.ToString(), endPoint.Port, macAdr
                                );
                                client.Close();
                                client = null;
                            }
                        }
                    }
                    else
                    {
                        Thread.Sleep(m_acceptCycle);
                    }
                }

                listener.Stop();
                listener = null;
            }
            catch (Exception e)
            {
                ErrorWrite("0630030005", e, "接続待ちスレッド例外発生 ！！{0}", e.Message);

                if (null != OnAcceptException)
                {
                    try
                    {
                        OnAcceptException.BeginInvoke(null, null);
                    }
                    catch (Exception ex)
                    {
                        ErrorWrite("0630030055", ex, "エラー通知に失敗");
                    }
                }
            }
            finally
            {
            }
        }
        #endregion
    }
}
