using NKK.FN3.Common.Library.TcpSocket;
using System;
using System.Collections.Generic;
using System.Net.Sockets;
using System.Text;
using System.Timers;
using NKKLoggingLib;
using NKKCommon;
using TdcSocketLib;

namespace ComScaleBed
{
    public class ComScaleBedConnection
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// アップデーターオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Updater m_Updater = new Updater();
        //----------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 外部GUI用Socketサーバーソケットクラスオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly TdcBaseSocketServer m_GUISocketServer = new TdcBaseSocketServer();
        //----------------------------------------------------------------------------------------------------

        /// <summary>
        /// 接続イベントハンドラ
        /// </summary>
        /// <param name="param">接続先情報</param>
        public delegate void OnConnectedEventHandler(ComScaleBedConnectionParam param);

        /// <summary>
        /// 接続イベント
        /// </summary>
        public event OnConnectedEventHandler OnConnected;
        /// <summary>
        /// 例外発生イベントハンドラ
        /// </summary>
        /// <param name="param">接続先情報</param>
        /// <param name="ex">例外</param>
        public delegate void OnExceptionEventHandler(ComScaleBedConnectionParam param, Exception ex);
        /// <summary>
        /// 例外発生イベント
        /// </summary>
        public event OnExceptionEventHandler OnException;
        /// <summary>
        /// データ受信イベントハンドラ
        /// </summary>
        /// <param name="recvData">受信情報</param>
        public delegate void OnDataReceivedEventHandler(ComScaleBedReceivedData recvData);
        /// <summary>
        /// データ受信イベント
        /// </summary>
        public event OnDataReceivedEventHandler OnDataReceived;

        private BaseClientConnect _clientConnect = null;
        private DeviceInformation[] _devInfos = null;

        /// <summary>
        /// 接続確認送信間隔タイマー
        /// </summary>
        private Timer _timer;

        /// <summary>
        /// 受信バッファ(なぞ接続先用)
        /// </summary>
        private ReceiveDataBuffer _receiveBuffer = new ReceiveDataBuffer();


        /// <summary>
        /// 通信状況リスト
        /// </summary>
        private List<ComScaleBedConnectionParam> _comConnParamList;
        /// <summary>
        /// 受信状況リスト
        /// </summary>
        private List<ComScaleBedReceivedData> _comRecvDataList;

        private double _recvInterval;
        /// <summary>
        /// 受信後に再受信が有効になるまでの時間（ミリ秒）
        /// 初期値：3000ms
        /// </summary>
        public double ReceiveInterval
        {
            get { return _recvInterval; }
            set { _recvInterval = value; }
        }

        private bool _started;
        /// <summary>
        /// True: 接続開始処理済み　False:接続開始未処理
        /// </summary>
        public bool GetStartedFlag
        {
            get { return _started; }
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public ComScaleBedConnection()
        {
            _recvInterval = 3000;
            _started = false;
        }
        #region プライベートメソッド
        // #11987 2025.12.02 add シリアル通信→TCPソケット通信 TDC石井 start
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
        private void CheckUpdate()
        {
            // アップデートバージョンチェック
            if (this.m_Updater.IsPublishedNewVersion(System.Reflection.Assembly.GetExecutingAssembly()))
            {
                // 最新バージョンがある

                // 最新ファイルを取得
                if (this.m_Updater.GetLatestProgramFile())
                {
                    // 最新ファイルを取得+解凍完了

                    // GUIツール[NKKScaleBedTool.exe]を終了
                    try
                    {
                        //this.m_GUISocketServer.AllSend(NKKScaleBedInformation.Encoding.GetBytes("EXIT"));
                        String taskkill = System.IO.Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.System), "taskkill.exe");

                        //
                        System.Diagnostics.Process[] ps = System.Diagnostics.Process.GetProcessesByName("NKKScaleBedtool");
                        foreach (System.Diagnostics.Process p in ps)
                        {
                            // ログ記録：GUIツール終了
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, String.Format("GUIツールを強制終了, プロセス名:{0}, プロセスID:{1}", p.ProcessName, p.Id));

                            //
                            using (System.Diagnostics.Process killproc = new System.Diagnostics.Process())
                            {
                                killproc.StartInfo.Verb = "RunAs";
                                killproc.StartInfo.FileName = taskkill;
                                killproc.StartInfo.Arguments = String.Format("/PID {0} /T /F", p.Id);
                                killproc.StartInfo.CreateNoWindow = false;
                                killproc.StartInfo.UseShellExecute = false;
                                //
                                killproc.Start();
                                // プロセス終了待ち
                                killproc.WaitForExit(10000);
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        //this.Error = ex;
                    }

                    // アップデートを実施
                    this.m_Updater.AppUpdate();
                }

            }
        }
        // #11987 2025.12.02 add シリアル通信→TCPソケット通信 TDC石井 end
        // #11987 2026.01.21 add TRACEログの調整 TDC伊東 start
        private string GetEscapedExMsg(Exception aEx)
        { 
            // 改行コード→{CRLF}、半角カンマ→全角カンマ
            return aEx.Message.Replace(",", "，").Replace("\r\n", "{CRLF}").Replace("\n", "{CRLF}");
        }
        // #11987 2026.01.21 add TRACEログの調整 TDC伊東 end
        #endregion

        /// <summary>
        /// 接続開始
        /// </summary>
        /// <param name="aParamList">接続先情報のリスト</param>
        /// <returns>接続開始処理の成功(true)/失敗(false)</returns>
        public int Start(List<ComScaleBedConnectionParam> aParamList)
        {
            return Start(aParamList, DefineParameters.SEND_DATA_INTERVAL);
        }

        /// <summary>
        /// 接続開始
        /// </summary>
        /// <param name="aParamList">接続先情報のリスト</param>
        /// <param name="aCheckConnectionInterval">接続確認信号の送信間隔（ミリ秒）</param>
        /// <returns>接続開始処理の成功(0)/失敗(-1)/開始済み(-2)</returns>
        public int Start(List<ComScaleBedConnectionParam> aParamList, int aCheckConnectionInterval)
        {
            if (_started)
            {
                // 開始済みなら
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続開始処理はすでに実行済みです。");

                return -2;
            }

            this._comConnParamList = aParamList;
            ReceiveDatasInit(aParamList);

            this._clientConnect = new BaseClientConnect();
            _devInfos = new DeviceInformation[aParamList.Count];

            // 接続先に接続する
            for (int i = 0; i < aParamList.Count; i++)
            {
                _devInfos[i] = new DeviceInformation(aParamList[i].IPAddress, aParamList[i].PortNo, "", "");
            }

            // 接続先情報を初期化する
            _clientConnect.InitializeDeviceInformation(_devInfos);

            // 接続確立時コールバック関数を割り当てる
            _clientConnect.ConnectHandler = MyConnect;

            //// 接続処理を開始する
            if (_clientConnect.StartConnect() == false)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続開始処理に失敗しました。");
                return -1;
            }

            // 接続確認データの送信間隔設定
            _timer = new Timer(aCheckConnectionInterval);
            _timer.Elapsed += _timer_Elapsed;
            _timer.Start();

            _started = true;

            return 0;
        }

        /// <summary>
        /// 受信状況リストの初期化
        /// </summary>
        /// <param name="aParamList"></param>
        private void ReceiveDatasInit(List<ComScaleBedConnectionParam> aParamList)
        {
            this._comRecvDataList = new List<ComScaleBedReceivedData>();
            aParamList.ForEach(delegate(ComScaleBedConnectionParam para)
            {
                ComScaleBedReceivedData recvData = new ComScaleBedReceivedData(para.IPAddress, para.PortNo, para.DispOrder, para.BedName, para.BedCd);
                this._comRecvDataList.Add(recvData);
            });
        }

        /// <summary>
        /// 接続終了処理
        /// （切断時に例外が発生する場合がある）
        /// </summary>
        public void End()
        {
            if (_started)
            {
                _timer.Stop();
                _timer.Close();

                //// 接続処理を終了する
                _clientConnect.EndConnect();
                _clientConnect.ReleaseDeviceInformation();
                _clientConnect = null;

                _started = false;

                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続終了処理を実行しました。");

            }
        }

        // #11987 2026.01.21 add スケールベッド接続状態確認用データ定期送信間隔を外から設定可能に TDC石井 start
        /// <summary>
        /// クラス外から「接続確認の送信間隔(ミリ秒)」をセット
        /// </summary>
        /// <param name="aVal">セットするミリ秒</param>
        public void SetSendDataInterval(int aVal)
        {
            DefineParameters.SEND_DATA_INTERVAL = aVal;
        }
        // #11987 2026.01.21 add スケールベッド接続状態確認用データ定期送信間隔を外から設定可能に TDC石井 end

        /// <summary>
        /// クライアント接続確立コールバック関数
        /// </summary>
        /// <param name="sock"></param>
        /// <param name="eHander"></param>
        /// <param name="devInf"></param>
        private BaseSocket MyConnect(TcpClient sock, dgtOnException_Mng eHander, DeviceInformation devInf)
        {
            // 接続際情報を一覧から取得する
            //var paras = _paramList.Where(x => x.IPAdress == devInf.IpAddress && x.PortNo == devInf.PortNo);   //LINQ

            ComScaleBedConnectionParam para = _comConnParamList.Find(
                delegate(ComScaleBedConnectionParam param)
                {
                    return (param.IPAddress == devInf.IpAddress && param.PortNo == devInf.PortNo);
                }
            );

            // Socketインスタンスを取得する
            BaseSocket bSock = new BaseSocket(sock, eHander, devInf);

            // 例外時コールバック関数を割り当てる
            bSock.ExceptionHandler = MyException;

            // 受信時コールバック関数を割り当てる
            bSock.ReceiveHandler = OnRecv;

            //bSock.SendTimeOut = 5000;

            string ipAddress = bSock.DevInfo.IpAddress;
            string portNo = bSock.DevInfo.PortNo.ToString();
            string bedName = "";

            if (para == null)
            {
                // 不明な接続先
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "不明な接続先に接続しました。IP : " + ipAddress + " Port : " + portNo);
                //this.OnConnected(new ComScaleBedConnectionParam(ipAddress, bSock.DevInfo.PortNo, ""));
                this.OnConnected(new ComScaleBedConnectionParam(ipAddress, bSock.DevInfo.PortNo, 0, "", 0));
                bedName = "不明";
            }
            else
            {
                para.Socket = bSock;
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続しました。IP : " + ipAddress + " Port : " + portNo + " ベッドコード : " + para.BedCd+ " ベッド名称 : " + para.BedName);
                this.OnConnected(para);
                bedName = para.BedName;
            }

            // 接続確認
            bSock.SendData(DefineParameters.SEND_DATA, DefineParameters.SEND_DATA_LENGTH);
            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続確認信号を送信しました。 IP : " + ipAddress + " Port : " + portNo + " ベッドコード : " + para.BedCd + " ベッド名称 : " + bedName);


            return bSock;
        }

        /// <summary>
        /// 例外ハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void MyException(BaseSocket sender, Exception e)
        {
            BaseSocket bs = (BaseSocket)sender;

            ComScaleBedConnectionParam para = _comConnParamList.Find(
               delegate(ComScaleBedConnectionParam param)
               {
                   return (param.Socket == bs);
               }
            );

            if (para == null)
            {
                // 不明な接続先
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"不明な接続で例外が発生しました。IP:{bs.DevInfo.IpAddress} Port:{bs.DevInfo.PortNo} 例外:{GetEscapedExMsg(e)}");

                this.OnException(new ComScaleBedConnectionParam(bs.DevInfo.IpAddress, bs.DevInfo.PortNo, 0, "",0), e);
            }
            else
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR, $"接続で例外が発生しました。IP:{para.IPAddress} Port:{para.PortNo} ベッドコード:{para.BedCd} ベッド名称:{para.BedName} 例外:{GetEscapedExMsg(e)}");

                para.Socket = null;
                this.OnException(para, e);
            }

        }

        private readonly object _thisLock = new object();

        /// <summary>
        /// ソケット受信コールバック関数
        /// </summary>
        /// <param name="sender">BaseSocketのインスタンス</param>
        private void OnRecv(BaseSocket sender)
        {

            // ソケット受信時の処理を実装する

            // ソケットデータ受信時
            if (null == sender)
            {
                throw new ArgumentNullException("sender");
            }

            BaseSocket bs = (BaseSocket)sender;
            try
            {
                // 今回受信したデータを受信バッファに結合する
                ReceiveStream rs;

                // 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
                // 受信データがなくなるまで繰り返す
                do
                {
                    // 受信データを取り出す
                    rs = sender.GetReceiveData();
                    if (rs != null)
                    {
                        byte[] dataBuffers = new byte[rs.rcvSize];
                        for (int i = 0; i < rs.rcvSize; i++)
                        {
                            dataBuffers[i] = rs.rcvData[i];
                        }
                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "受信データ : " + ToHexString(dataBuffers) + " 受信元 IP : " + bs.DevInfo.IpAddress + " PortNo : " + bs.DevInfo.PortNo);
                        
                        // 排他処理
                        lock (_thisLock)
                        {
                            // ソケット受信データを処理する
                            this.CallOnCommandReceived(sender, rs.rcvSize, rs.rcvData);
                        }
                    }

                } while (rs != null);

            }
            catch (Exception ex)
            {
                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, $"受信データ解析時に例外が発生しました。IP:{bs.DevInfo.IpAddress} Port:{bs.DevInfo.PortNo} 例外:{ex.Message}");
            }
        }

        /// <summary>
        /// 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
        /// </summary>
        /// <param name="sender">BaseSocketインスタンス</param>
        /// <param name="rcvSize">受信データ長</param>
        /// <param name="rcvData">受信データByte</param>
        protected void CallOnCommandReceived(BaseSocket sender, int rcvSize, byte[] rcvData)
        {

            const int stx1 = 0x53;   // 'S'
            const int stx2 = 0x54;   // 'T'
            const int etx1 = 0x0d;   // CR
            const int etx2 = 0x0a;   // LF
            BaseSocket bs = (BaseSocket)sender;
            int bufferSize;
            byte[] rcvBytes;
            ComScaleBedReceivedData recv = _comRecvDataList.Find(
               delegate(ComScaleBedReceivedData param)
               {
                   return (param.IPAddress == bs.DevInfo.IpAddress && param.PortNo == bs.DevInfo.PortNo);
               }
            );

            if (recv == null)
            {
                // なぞの受信元

                // 受信データを取得する
                if (this._receiveBuffer.Add(rcvSize, rcvData) == false)
                {
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                        "バッファ追加処理で例外が発生したため、バッファをクリアします 受信元IP:" + bs.DevInfo.IpAddress + " PortNo:" +
                        bs.DevInfo.PortNo + " 例外:" + GetEscapedExMsg(this._receiveBuffer.Exception));
                }
                rcvBytes = this._receiveBuffer.GetBuffer();
                bufferSize = this._receiveBuffer.Size;
            }
            else
            {
                //登録済みの受信元

                // 受信データを取得する
                if (recv.ReceiveBuffer.Add(rcvSize, rcvData) == false)
                {
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                        "バッファ追加処理で例外が発生したため、バッファをクリアします 受信元IP:" + bs.DevInfo.IpAddress + " PortNo:" +
                        bs.DevInfo.PortNo + " 例外:" + GetEscapedExMsg(this._receiveBuffer.Exception));
                }
                rcvBytes = recv.ReceiveBuffer.GetBuffer();
                bufferSize = recv.ReceiveBuffer.Size;
            }


            // 受信データを解析する
            int i;
            int intSTX = -1;
            int intETX = -1;
            int intSTXPos = -1;
            int intETXPos;
            int searchStartPos = 0;
            DateTime recvTime = DateTime.Now;

            for (i = 0; i < bufferSize; i++)
            {
                byte rcvByte = rcvBytes[i];

                if (rcvByte == stx1)
                {
                    intSTX = i;
                }
                else if ((rcvByte == stx2) && (intSTX >= 0))
                {
                    intSTXPos = i;
                }
                else if (rcvByte == etx1)
                {
                    intETX = i;
                }
                else if ((rcvByte == etx2) && (intETX >= 0))
                {
                    intETXPos = i;

                    // 受信バッファから取り出したバイト数分を削除する
                    if (recv == null)
                    {
                        // なぞの受信元
                        if (this._receiveBuffer.RemoveHead(intETXPos - searchStartPos + 1) == false)
                        {
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                                "バッファ削除処理で例外が発生したため、バッファをクリアします 受信元IP:" + bs.DevInfo.IpAddress + " PortNo:" +
                                bs.DevInfo.PortNo + " 例外:" + GetEscapedExMsg(this._receiveBuffer.Exception));
                        }
                    }
                    else
                    {
                        //登録済みの受信元
                        if (recv.ReceiveBuffer.RemoveHead(intETXPos - searchStartPos + 1) == false)
                        {
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.ERROR,
                                "バッファ削除処理で例外が発生したため、バッファをクリアします 受信元IP:" + bs.DevInfo.IpAddress + " PortNo:" +
                                bs.DevInfo.PortNo + " 例外:" + GetEscapedExMsg(recv.ReceiveBuffer.Exception));
                        }
                    }
                    searchStartPos = i + 1;

                    if (0 <= intSTXPos)
                    {
                        // intSTXPos = ヘッダ("ST")
                        // (intSTXPos + 3) = ±
                        // (intSTXPos + 4 ～ 10) = 体重値("99999.9")
                        // i = ETX(LF)

                        // BeforeBytes配列にコピーする（計量値を取得）
                        byte[] beforeBytes = new byte[8];
                        Buffer.BlockCopy(rcvBytes, intSTXPos + 2, beforeBytes, 0, 8);
                        Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");
                        string strData = sjisEnc.GetString(beforeBytes);

                        this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "解釈データ : " + ToHexString(rcvBytes) + " 受信元 IP : " + bs.DevInfo.IpAddress + " PortNo : " + bs.DevInfo.PortNo);

                        // MDCodeを取得（資料では2桁だけど実際は1桁？ 1桁直後の \r を含めても数値変換は可能）
                        byte[] mdBytes = new byte[2];
                        Buffer.BlockCopy(rcvBytes, i - 2, mdBytes, 0, 2);
                        string strMD = sjisEnc.GetString(mdBytes);

                        int numMD;
                        // MDコードは2桁
                        if (int.TryParse(strMD, out numMD))
                        {
                            strMD = numMD.ToString("00");
                        }
                        else if (int.TryParse(strMD.Substring(0, 1), out numMD))
                        {
                            strMD = numMD.ToString("00");
                        }

                        double dblData;
                        if (double.TryParse(strData, out dblData) == false)
                        {
                            dblData = 0.0;
                        }

                        if (recv == null)
                        {
                            // 謎の受信元
                            this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "計量値受信 : " + strData + " MD : " + strMD + " 受信元 IP : " + bs.DevInfo.IpAddress + " PortNo : " + bs.DevInfo.PortNo);
                            this.OnDataReceived(new ComScaleBedReceivedData(bs.DevInfo.IpAddress, bs.DevInfo.PortNo, 0,"",0, dblData, strMD, recvTime));
                        }
                        else
                        {
                            if (recv.RecvTime == null || DateTime.Now.AddMilliseconds(-ReceiveInterval) > recv.RecvTime)
                            {
                                // 初受信　または　前回からReceiveInterval秒以上経過
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "計量値受信 : " + strData + " MD : " + strMD + " 受信元 IP : " + recv.IPAddress + " PortNo : " + recv.PortNo);
                                recv.RecvTime = recvTime;
                                recv.Data = double.Parse(strData);
                                recv.MDCode = strMD;
                                this.OnDataReceived(recv);
                            }
                            else
                            {
                                // 前回から時間がたっていないからスルーする
                                this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "計量値受信(前回受信より3秒以内のため無効) : " + strData + " MD : " + strMD + " 受信元 IP : " + recv.IPAddress + " PortNo : " + recv.PortNo);
                            }
                        }

                    }

                    intSTX = -1;
                    intSTXPos = -1;

                }
            }
        }

        /// <summary>
        /// 受信データからコマンドを抽出し、コマンドがあればOnCommandReceivedを呼び出す
        /// </summary>
        /// <param name="sender">BaseSocketインスタンス</param>
        /// <param name="rs">受信データ</param>
        protected void CallOnCommandReceived(BaseSocket sender, ReceiveStream rs)
        {
            // ソケット受信データを処理する
            this.CallOnCommandReceived(sender, rs.rcvSize, rs.rcvData);
        }

        private void _timer_Elapsed(object sender, ElapsedEventArgs e)
        {
            SendChkConnectionData();
        }

        /// <summary>
        /// 接続確認用にデータを送信する
        /// </summary>
        private void SendChkConnectionData()
        {
            this._comConnParamList.ForEach(delegate(ComScaleBedConnectionParam para)
            {
                if (para.Socket != null)
                {
                    // 接続確認
                    para.Socket.SendData(DefineParameters.SEND_DATA, DefineParameters.SEND_DATA_LENGTH);
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "接続確認信号を送信しました。 IP : " + para.IPAddress + " Port : " + para.PortNo + " ベッドコード : " + para.BedCd+ " ベッド名称 : " + para.BedName);
                }
                else
                {
                    // 接続してないベッド
                    this.AddLogInfo(DateTime.Now, NKKLogging.LOGGING_CLASS.INFO, "未接続のため接続確認信号を送信しません。 IP : " + para.IPAddress + " Port : " + para.PortNo + " ベッドコード : " + para.BedCd + " ベッド名称 : " + para.BedName);
                }
            });

        }

        /// <summary>
        /// 特定接続先の最終受信データを取得
        /// </summary>
        /// <param name="aIPAddr">IPアドレス</param>
        /// <param name="aPortNo">ポートNo</param>
        /// <returns>受信データ　対応するIP/ポートの検索結果がない場合はnull</returns>
        public ComScaleBedReceivedData GetLastReceivedData(string aIPAddr, int aPortNo)
        {
            return _comRecvDataList.Find(
               delegate(ComScaleBedReceivedData param)
               {
                   return (param.IPAddress == aIPAddr && param.PortNo == aPortNo);
               }
            );
        }

        /// <summary>
        /// 特定接続先の最終受信データを取得
        /// </summary>
        /// <param name="aBedCd">ベッドコード</param>
        /// <returns>受信データ（複数一致する場合は最初に登録した一件）　対応するベッドコードの検索結果がない場合はnull</returns>
        public ComScaleBedReceivedData GetLastReceivedData(int aBedCd)
        {
            return _comRecvDataList.Find(
               delegate(ComScaleBedReceivedData param)
               {
                   return (param.BedCd == aBedCd);

               }
            );
        }

        /// <summary>
        /// バイト配列から16進数の文字列を生成します。
        /// </summary>
        /// <param name="bytes">バイト配列</param>
        /// <returns>16進数文字列</returns>
        public static string ToHexString(byte[] bytes)
        {
            StringBuilder sb = new StringBuilder(bytes.Length * 2);
            foreach (byte b in bytes)
            {
                if (b < 16) sb.Append('0'); // 二桁になるよう0を追加
                sb.Append(Convert.ToString(b, 16));
            }
            return sb.ToString();
        }
    }
}
