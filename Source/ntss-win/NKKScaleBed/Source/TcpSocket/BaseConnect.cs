///////////////////////////////////////////////////////////////////////////////
//
// システム名 ：FutureNetⅢ
// 機能名     ：FN3システム TCP/IPソケット通信 接続処理ベースクラス
// ファイル名 ：BaseConnect.cs
// 説明       ：接続処理のベース機能を提供する。
//
//	Copyright(C) 2008 NIKKISO CO., LTD. All Rights Reserved.
//
// 更新履歴
//	日付		担当				理由
//	2008/04/24	中村 竜也			新規作成（スタブ）
//
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Net;
using System.Runtime.InteropServices;
using System.Threading;

using NKKLoggingLib;

namespace NKK.FN3.Common.Library.TcpSocket
{
    /// <summary>
    /// ＦＮ３システムでの接続処理の基本機能を提供する。
    /// </summary>
    /// <remarks>
    /// BaseConnectクラスはＦＮ３システムでソケット接続を行うクラスの基底クラスである。
    /// BaseConnectクラスはソケット接続や接続したソケットの管理を行う為に必要な機能を提供する。
    /// 本クラスは抽象クラスであり、直接使用することは出来ない。
    /// </remarks>
    public abstract class BaseConnect
    {
        #region プライベートメソッド
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
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
        /// アップデート処理用ログ記録
        /// </summary>
        /// <param name="LoggingClass">ログ区分</param>
        /// <param name="strMessage">記録メッセージ</param>
        //----------------------------------------------------------------------------------------------------
        private void AddLogInfoUpdate(NKKLoggingLib.NKKLogging.LOGGING_CLASS LoggingClass, String strMessage)
        {
            // ログ記録
            this.AddLogInfo(DateTime.Now, LoggingClass, strMessage);
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデート処理
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //private void CheckUpdate()
        //{
        //    // アップデートバージョンチェック
        //    if (this.m_Updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly()))
        //    {
        //        // 最新バージョンがある

        //        // 最新ファイルを取得
        //        if (this.m_Updater.GetLatestProgramFile())
        //        {
        //            // 最新ファイルを取得+解凍完了

        //            // GUIツール[NKKScaleBedTool.exe]を終了
        //            try
        //            {
        //                this.m_GUISocketServer.AllSend(NKKScaleBedInformation.Encoding.GetBytes("EXIT"));
        //                String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

        //                //
        //                System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("NKKScaleBedtool");
        //                foreach (System.Diagnostics.Process p in ps)
        //                {
        //                    // ログ記録：GUIツール終了
        //                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("GUIツールを強制終了, プロセス名:{0}, プロセスID:{1}", p.ProcessName, p.Id));

        //                    //
        //                    using (System.Diagnostics.Process killproc = new System.Diagnostics.Process())
        //                    {
        //                        killproc.StartInfo.Verb = "RunAs";
        //                        killproc.StartInfo.FileName = taskkill;
        //                        killproc.StartInfo.Arguments = String.Format("/PID {0} /T /F", p.Id);
        //                        killproc.StartInfo.CreateNoWindow = false;
        //                        killproc.StartInfo.UseShellExecute = false;
        //                        //
        //                        killproc.Start();
        //                        // プロセス終了待ち
        //                        killproc.WaitForExit(10000);
        //                    }
        //                }
        //            }
        //            catch (Exception ex)
        //            {
        //                this.Error = ex;
        //            }

        //            // アップデートを実施
        //            this.m_Updater.AppUpdate();
        //        }

        //    }
        //}
        #endregion

        

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="logInfo">ログ情報</param>
        public BaseConnect()
        {
           
        }

        /// <summary>
        /// エラーログ書き込み
        /// </summary>
        /// <param name="ex">例外情報</param>
        /// <param name="mes">メッセージ</param>
        /// <param name="paramList">パラメータリスト</param>
        protected void ErrorWrite(Exception ex, string mes, params object[] paramList)
        {
            if ((null == paramList) || (0 == paramList.Length))
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                    mes
                    + $" 例外:{ex.Message.Replace(",", "，").Replace("\r\n", "{CRLF}").Replace("\n", "{CRLF}")}"); // 改行コード→{CRLF}、半角カンマ→全角カンマ)
            }
            else
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                    string.Format(mes, paramList)
                    + $" 例外:{ex.Message.Replace(",", "，").Replace("\r\n", "{CRLF}").Replace("\n", "{CRLF}")}"); // 改行コード→{CRLF}、半角カンマ→全角カンマ))
            }
        }

        /// <summary>
        /// トレースログ書き込み
        /// </summary>
        /// <param name="mes">メッセージ</param>
        /// <param name="paramList">パラメータリスト</param>
        protected void TraceWrite(string mes, params object[] paramList)
        {
            if ((null == paramList) || (0 == paramList.Length))
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, mes);
            }
            else
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, string.Format(mes, paramList));
            }
        }

        [DllImport("iphlpapi.dll", ExactSpelling = true)]
        private static extern int SendARP(int DestIP, int SrcIP, byte[] pMacAddr, ref int PhyAddrLen);

        /// <summary>
        /// 例外イベント用デリゲート定義
        /// </summary>
        public delegate void dgtOnException(Exception e);

        private dgtOnException dgtException = null;


        /// <summary>
        /// 接続処理スレッド
        /// </summary>
        protected Thread m_thread = null;

        /// <summary>
        /// スレッド動作フラグ
        /// </summary>
        protected bool m_threadRun = true;

        /// <summary>
        /// m_devInfo, m_sockListメンバーへのアクセスの排他制御用オブジェクト
        /// </summary>
        protected object m_syncInfo = new object();

        /// <summary>
        /// 接続先装置情報リスト
        /// </summary>
        //protected static DeviceInformation[] m_devInfo = null;	//2008/6/17 DEL
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
        //protected DeviceInformation[] m_devInfo = null;		// 2008/6/17 UPD static 型を変更
        protected List<DeviceInformation> m_devInfo;
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）

        /// <summary>
        /// ソケットオブジェクト格納用リスト
        /// </summary>
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
        //protected object[] m_sockList = null;
        protected List<object> m_sockList;
        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）

        #region プロパティ
        /// <summary>
        /// 例外ハンドラを登録する。
        /// </summary>
        public dgtOnException ExceptionHandler
        {
            set
            {
                dgtException = new dgtOnException(value);
            }
        }
        #endregion

        /// <summary>
        /// ＩＰアドレスからＭＡＣアドレスを取得する。
        /// </summary>
        /// <param name="targetPoint">ＭＡＣアドレスを取得したい装置のＩＰアドレス</param>
        /// <returns>
        /// 正常に取得できた場合、ＭＡＣアドレスを返す。
        /// 取得できなかった場合、string.Emptyを返す。
        /// </returns>
        public static string GetMacAddress(IPAddress targetPoint)
        {
            string ret = string.Empty;

            byte[] b_mac = new byte[6];
            int len = b_mac.Length;
            int r = SendARP(BitConverter.ToInt32(targetPoint.GetAddressBytes(), 0), 0, b_mac, ref len);

            ret = BitConverter.ToString(b_mac, 0, 6);

            return ret;
        }

        /// <summary>
        /// 接続先装置情報リストの登録を行う。
        /// </summary>
        /// <remarks>
        /// 接続先装置情報リストの登録を行う。登録は一度行われると、ReleaseDeviceInformationメソッドを呼び出して
        /// 解放してからでないと再度登録は出来ない。
        /// </remarks>
        /// <param name="devInf">
        /// 接続先装置情報が格納されたDeviceInformation型の配列。
        /// </param>
        /// <returns>
        /// 正常に登録されるとtrueを返す。
        /// 接続先装置情報リストが登録済みの場合、falseを返す。
        /// </returns>
        public bool InitializeDeviceInformation(DeviceInformation[] devInf)
        {
            bool ret = false;

            if (m_devInfo == null)
            {
                lock (m_syncInfo)
                {
                    if (m_devInfo == null && m_sockList == null)
                    {
                        if (devInf != null && devInf.Length > 0)
                        {
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //m_devInfo = new DeviceInformation[devInf.Length];
                            m_devInfo = new List<DeviceInformation>();
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）

                            for (int i = 0; i < devInf.Length; i++)
                            {
                                // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                                //m_devInfo[i] = new DeviceInformation(devInf[i].IpAddress, devInf[i].PortNo, devInf[i].MacAddress, devInf[i].DeviceId);
                                DeviceInformation m_devInfoBuff = new DeviceInformation(devInf[i].IpAddress, devInf[i].PortNo, devInf[i].MacAddress, devInf[i].DeviceId);
                                m_devInfo.Add(m_devInfoBuff);
                                // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            }

                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //m_sockList = new object[m_devInfo.Length];
                            object[] l_sockBuff = new object[devInf.Length];
                            m_sockList = new List<object>(l_sockBuff);
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            ret = true;
                        }
                    }
                }
            }

            return ret;
        }

        /// <summary>
        /// 接続先装置情報リストの解放を行う。
        /// </summary>
        public virtual void ReleaseDeviceInformation()
        {
            if (m_devInfo != null || m_sockList != null)
            {
                lock (m_syncInfo)
                {
                    if (m_devInfo != null)
                    {
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        //for (int i = 0; i < m_devInfo.Length; i++)
                        //{
                        //	if (m_devInfo[i] != null)
                        //	{
                        //		m_devInfo[i] = null;
                        //	}
                        //}
                        m_devInfo.Clear();
                        m_devInfo = null;
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    }

                    if (m_sockList != null)
                    {
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        //for (int i = 0; i < m_sockList.Length; i++)
                        for (int i = 0; i < m_sockList.Count; i++)
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        {
                            if (m_sockList[i] != null)
                            {
                                BaseSocket bs = m_sockList[i] as BaseSocket;
                                if (bs != null)
                                {
                                    bs.Release();
                                }
                                else
                                {
                                    ;
                                }
                            }
                        }
                        // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        m_sockList.Clear();
                        // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        m_sockList = null;
                    }
                }
            }
        }

        /// <summary>
        /// ソケットオブジェクトを取得する。
        /// </summary>
        /// <remarks>
        /// 指定した接続先との通信を行う為のソケットオブジェクトを取得する。
        /// </remarks>
        /// <param name="devInf">
        /// 接続先を特定する為の情報。
        /// </param>
        /// <returns>
        /// BaseSocketオブジェクトを返す。
        /// </returns>
        /// <exception cref="System.Exception">
        /// 接続先装置情報リストが未登録の場合
        /// </exception>
        public BaseSocket GetObject(DeviceInformation devInf)
        {
            BaseSocket ret = null;

            if (m_devInfo != null)
            {
                lock (m_syncInfo)
                {
                    if (m_devInfo != null)
                    {
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        //for (int i = 0; i < m_devInfo.Length; i++)
                        for (int i = 0; i < m_devInfo.Count; i++)
                        // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                        {
                            if (m_devInfo[i].Equals(devInf))
                            {
                                ret = m_sockList[i] as BaseSocket;
                                break;
                            }
                        }
                    }
                }
            }
            else
            {
                throw new Exception("接続先装置情報リストが未登録");
            }

            return ret;
        }

        /// <summary>
        /// ソケットオブジェクトを解放する。
        /// </summary>
        /// <remarks>
        /// 指定したソケットオブジェクトをソケット管理リストから解放する。
        /// </remarks>
        /// <param name="sock">
        /// 解放するソケットオブジェクト。
        /// </param>
        /// <exception cref="System.Exception">
        /// 指定したソケットがソケット管理リストに未登録の場合
        /// </exception>
        public void ReleaseObject(BaseSocket sock)
        {
            if (sock != null)
            {
                int index = -1;
                if (m_sockList != null)
                {
                    lock (m_syncInfo)
                    {
                        if (m_sockList != null)
                        {
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //for (int i = 0; i < m_sockList.Length; i++)
                            for (int i = 0; i < m_sockList.Count; i++)
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            {
                                if (m_sockList[i] == sock)
                                {
                                    m_sockList[i] = null;
                                    index = i;
                                    break;
                                }
                            }
                        }
                    }
                }

                sock.Release();

                if (index == -1)
                {
                    throw new Exception("指定されたソケットは管理対象外");
                }
            }
        }

        /// <summary>
        /// 例外発生時の内部処理を行う。
        /// </summary>
        protected void ExceptionProc(BaseSocket sender, Exception e)
        {
            if (sender != null)
            {
                if (m_sockList != null)
                {
                    lock (m_syncInfo)
                    {
                        if (m_sockList != null)
                        {
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //for (int i = 0; i < m_sockList.Length; i++)
                            for (int i = 0; i < m_sockList.Count; i++)
                            // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            {
                                if (m_sockList[i] == sender)
                                {
                                    m_sockList[i] = null;
                                    break;
                                }
                            }
                        }
                    }
                }

                sender.Release();
            }
        }

        /// <summary>
        /// 指定した装置情報を持つ接続先リストのインデックスを返す。
        /// </summary>
        /// <param name="targetDi">検索対象の装置情報</param>
        /// <returns>
        /// 指定した装置情報と同じ情報が接続先リストに存在する場合、リストのインデックスを返す。
        /// 存在しない場合は、リストに追加して追加したIndex番号を返す。
        /// </returns>
        protected int SearchDevList(DeviceInformation targetDi)
        {
            int ret = -1;
            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            bool connect_flg = true;
            if (targetDi == null)
            {
                return ret;
            }
            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
            //if (m_devInfo != null && m_sockList != null)
            //{
            lock (m_syncInfo)
            {
                if (m_devInfo != null && m_sockList != null)
                {
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    //for (int i = 0; i < m_devInfo.Length; i++)
                    for (int i = 0; i < m_devInfo.Count; i++)
                    // CHG S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                    {
                        if (targetDi.Equals(m_devInfo[i]))
                        {
                            //接続の場合ソケットリストのIndex番号を返す
                            if (m_sockList[i] == null)
                            {
                                ret = i;
                            }
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            //接続情報と一致している場合新規追加しなくてよい
                            connect_flg = false;
                            // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                            break;
                        }
                    }
                }
                // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                if (connect_flg == true)
                {
                    //接続情報がない場合は、新規追加する
                    DeviceInformation l_devInfo = new DeviceInformation(
                                                targetDi.IpAddress,
                                                targetDi.PortNo,
                                                targetDi.MacAddress,
                                                targetDi.DeviceId);
                    if (m_devInfo == null)
                    {
                        m_devInfo = new List<DeviceInformation>();
                    }
                    if (m_sockList == null)
                    {
                        m_sockList = new List<object>();
                    }
                    m_devInfo.Add(l_devInfo);
                    object l_sockBuff = null;
                    m_sockList.Add(l_sockBuff);
                    ret = m_sockList.Count - 1;
                }
                // ADD S.Hosoi 2008/09/24 IPアドレスリストに登録されていないの許可対応（不具合番号：XXXXX）
                //}
            }
            //}

            return ret;
        }
    }
}
