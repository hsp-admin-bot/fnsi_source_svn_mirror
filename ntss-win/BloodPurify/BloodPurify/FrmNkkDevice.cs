using NKK.FN3.Common.Library.TcpSocket;
using NKK.FN3.ComServer.Library;
using NKKWebAccessLib;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.IO;
using System.Linq.Expressions;
using System.Net.Sockets;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Windows.Forms;

namespace NKK.BloodPurify
{
    public partial class FrmNkkDevice : FrmMonitoring
    {
        /// <summary>BV計 オプションデータ:1 bit:8</summary>
        private readonly (int, int) DevOptBv = (1, 8);
        /// <summary>透析量モニタ(DDM) オプションデータ:1 bit:9</summary>
        private readonly (int, int) DevOptDdm = (1, 9);
        /// <summary>BVplus オプションデータ:1 bit:10</summary>
        private readonly (int, int) DevOptBvplus = (1, 10);
        /// <summary>オンライン補充液(透析液) オプションデータ:2 bit:11</summary>
        //private readonly (int, int) DevOptOnlineDialysate = (2, 11); // 現時点未使用なのでコメントアウト
        /// <summary>透析量PG オプションデータ:2 bit:12</summary>
        private readonly (int, int) DevOptDialPg = (2, 12);
        /// <summary>装置オプション D-FAS オプションデータ:2 bit:13</summary>
        //private readonly (int, int) DevOptDfas = (2, 13); // 現時点未使用なのでコメントアウト

        /// <summary>モニタデータ 空 0x8000</summary>
        private readonly short EmptyMonData = -32768;

        /// <summary>透析前血圧</summary>
        private readonly int VitalBefore = 5;
        /// <summary>透析後血圧</summary>
        private readonly short VitalAfter = 6;
        /// <summary>透析中血圧</summary>
        private readonly short VitalTreating = 2;

        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
        /// <summary>再循環率測定</summary>
        private readonly short RecrclRt = 1;
        /// <summary>IHDF引き残し量</summary>
        private readonly short IhdfPll = 2;
        /// <summary>静的静脈圧</summary>
        private readonly int SttcVnsPrssr = 3;
        /// <summary>IAPRate</summary>
        private readonly short IapRt = 4;
        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

        /// <summary>
        /// サーバー接続
        /// </summary>
        private BaseServerConnect Server = new BaseServerConnect();

        /// <summary>
        /// モニタ項目における[アドレス/名称/小数点桁数/単位/書式整形定義文字列]の定義
        /// </summary>
        private NkkMonDefine NkkMonDefine = new NkkMonDefine();

        /// <summary>
        /// DGVにおけるログデータの表示内容の開始位置
        /// </summary>
        private int LogStartRowIdx;

        /// <summary>
        /// DGVにおけるモニタデータの表示内容の開始位置
        /// </summary>
        private int MonStartRowIdx;

        /// <summary>
        /// 「モニタデータの経過時間(分)から治療開始日時を算出し治療データファイルに記録」を実施するかどうかのフラグ
        /// </summary>
        private bool IsCalcAndWriteStartDateTimeCallingNeed = false;

        /// <summary>
        /// 最後に受信したモニタデータ
        /// </summary>
        private short[] LastMon = new short[150];

        /// <summary>
        /// 最後に受信したモニタデータの受信日時
        /// </summary>
        private DateTime LastMonRecvDt = DateTime.MinValue;

        /// <summary>
        /// 排液判定を実施するスレッド
        /// </summary>
        private Thread ThreOfJudgeDialEnd;

        /// <summary>
        /// [排液判定を実施するスレッド]の使用順制御のためのMutex
        /// </summary>
        private Mutex ThreOfJudgeDialEndMutex = new Mutex();

        /// <summary>
        /// ソケットの接続確立直後かどうか
        /// </summary>
        private bool IsRightAfterAccepted = false;

        /// <summary>
        /// 装置オプション
        /// </summary>

        private short[] DeviceOption = new short[7];

        /// <summary>
        /// 前回臨床工程 {"null":"不定(通信開始時)", "0":"治療外", "1":"治療中", "2":"排液判定中"}
        /// </summary>
        protected override string PrevStatus
        {
            get
            {
                return _PrevStatus;
            }

            set
            {
                _PrevStatus = value;

                if ("1" == _PrevStatus || "2" == _PrevStatus)
                {
                    SetTreatStatus(Color.FromArgb(0, 176, 80));

                }
                else // null or "0"
                {
                    SetTreatStatus(Color.Olive);
                }
            }
        }

        /// <summary>
        /// コンストラクタ(VSデザイナで必要)
        /// </summary>
        public FrmNkkDevice()
        {
            InitializeComponent();
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="argParams">呼び出し元が渡すパラメータ(※予定選択で得られるタプルの形)</param>
        /// <param name="argPortNo">待ち受け通信ポート番号</param>
        /// <param name="argDataFileNamePrefix">bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)</param>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public FrmNkkDevice((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix)
        public FrmNkkDevice((long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix)
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
            : base(argParams, argPortNo, argDataFileNamePrefix)
        {
            InitializeComponent();

            DialysisCom = new DialysisComNkk(OnCommandRecv, null);

            //LogWriter.WriteLog(LogLevel.Debug, "0316000029", "KM-9000モニタリング画面 開始[装置index:]");

            FormTitle = "モニタリング(日機装透析装置)";

            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        private void FrmNkkDevice_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                if (false == NkkMonDefine.IsLoadingSuccess)
                {
                    MessageBox.Show("モニタ項目設定ファイルの読出に失敗したため\n装置との通信データが正しく処理できません。\nアプリを終了します。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error);
                    IsCloseForced = true;
                    Close();
                    return;
                }

                Server.InitializeDeviceInformation(PortNo, null);
                Server.OnAcceptException += new BaseServerConnect.AcceptException(MyAcceptException);
                Server.AcceptHandler = MyAccept;

                if (Server.StartListener())
                {
                    SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), "接続待機中");
                }
                else
                {
                    InvokeShowErrorDialogAndExitApp();
                }

                // 新規治療データ収集の場合は治療データファイルの名前を生成(※日機装透析装置は工程変化などによる[1治療1データファイル]化は行わない)
                if (string.IsNullOrWhiteSpace(BptxtFileName))
                {
                    BptxtFileName = $"{DataFilenamePrefix}{DateTime.Now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                    PrevStatus = null;
                    SetTreatStatus(Color.Olive, "治療外");
                }
                else
                {
                    // 継続収集であれば[排液判定により透析終了になる前]なので、ファイル中に[kind=START]があるかどうかで PrevStatus を復元
                    if (AccessorBptxtFile.Read($"{MyConfig.DataDir}\\{BptxtFileName}").Contains("kind=START"))
                    {
                        PrevStatus = "1";
                        SetTreatStatus(Color.FromArgb(0, 176, 80), "治療中");
                    }
                    else
                    {
                        PrevStatus = null;
                        SetTreatStatus(Color.Olive, "治療外");
                    }
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void FrmNkkDevice_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            if (null != MySock)
            {
                lock (MySock)
                {
                    MySock.Release();
                    MySock = null;
                }
            }

            Server.EndListener();
        }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableの全行登録
        /// </summary>
        protected override void AddRowsToMyDataTable()
        {
            AddOneRowToMyDataTable("製造番号", "");
            AddOneRowToMyDataTable("シーケンシャルNo", "");
            AddOneRowToMyDataTable("コマンドコード", "");
            AddOneRowToMyDataTable("ステータス", "");

            LogStartRowIdx = 4;
            AddOneRowToMyDataTable("ログ：ログNo", "");
            AddOneRowToMyDataTable("ログ：種別", "");
            AddOneRowToMyDataTable("ログ：コード", "");
            AddOneRowToMyDataTable("ログ：発生日付", "");
            AddOneRowToMyDataTable("ログ：発生時刻", "");
            AddOneRowToMyDataTable("ログ：発生透析時間", "分");
            AddOneRowToMyDataTable("ログ：関連データ1", "");
            AddOneRowToMyDataTable("ログ：関連データ2", "");
            AddOneRowToMyDataTable("ログ：関連データ3", "");
            AddOneRowToMyDataTable("ログ：関連データ4", "");

            MonStartRowIdx = 14;
            for (int i = 0; i < NkkMonDefine.Items.Count; i++)
            {
                AddOneRowToMyDataTable($"モニタ：{NkkMonDefine.Items[i].addr}：{NkkMonDefine.Items[i].name}", NkkMonDefine.Items[i].unit);
            }
        }

        private BaseSocket MyAccept(TcpClient sock, dgtOnException_Mng eHandler, DeviceInformation devInf)
        {
            ComSocket ret = null;

            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 接続");

                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[Accept:{devInf.DevInfoStr}]");

                for (int i = 0; i < LastMon.Length; i++)
                {
                    LastMon[i] = EmptyMonData;
                }
                LastMonRecvDt = DateTime.MinValue;

                ret = new ComSocket(sock, eHandler, devInf);
                ret.ReceiveCycle = 100;
                ret.ReceiveHandler = OnRecv;
                ret.ExceptionHandler = MySocketException;

                IsRightAfterAccepted = true;

                MySock = ret;
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, string.Format("{0} Accept処理時例外", devInf.DevInfoStr), ex);
            }

            return ret;
        }

        private void MyAcceptException()
        {
            InvokeShowErrorDialogAndExitApp();
        }

        private void MySocketException(BaseSocket sender, Exception e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[DisConnected:{sender.DevInfo.DevInfoStr}]");

            lock (sender)
            {
                sender.Release();
                if (sender == MySock)
                {
                    MySock = null;
                }
            }

            SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 切断");
        }

        /// <summary>
        /// [治療外／治療中]のラベルの変更(※通信スレッドからの呼出を考慮してInvoke)
        /// </summary>
        /// <param name="argColor">色</param>
        private void SetTreatStatus(Color argColor)
        {
            try
            {
                BeginInvoke((MethodInvoker)(() => LblTreatStatus.BackColor = argColor));
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// [治療外／治療中]のラベルの変更(※通信スレッドからの呼出を考慮してInvoke)
        /// </summary>
        /// <param name="argText">テキスト</param>
        private void SetTreatStatus(string argText)
        {
            try
            {
                BeginInvoke((MethodInvoker)(() => LblTreatStatus.Text = argText));
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// UIスレッド側からメッセージダイアログを出してアプリ終了(※UIスレッドから操作しないとうまくいかないので)
        /// </summary>
        private void InvokeShowErrorDialogAndExitApp()
        {
            Invoke((MethodInvoker)(() => MessageBox.Show("通信接続の待ち受けに失敗したため装置との通信ができません。\nアプリを終了します。", Text, MessageBoxButtons.OK, MessageBoxIcon.Error)));
            IsCloseForced = true;
            Invoke((MethodInvoker)(() => Close())); // モニタリング画面が閉じるとアプリが終了する作り
        }

        /// <summary>
        /// 受信イベントの処理
        /// </summary>
        /// <param name="sender"></param>
        protected override void ProcReceivedData(BaseSocket sender)
        {
            DialysisCom.OnRecv(sender, "");
        }

        private void OnCommandRecv(BaseSocket sender, byte[] data, int size, string strlogfile)
        {
            // [STX,ETX,チェックサム]除去済み、[1012→02,1013→03,1010→10]戻し済みのデータ
            OnCommandRecv(sender, data, size);
        }

        /// <summary>
        /// [一電文]の受信時の処理
        /// </summary>
        /// <param name="data">受信データ内の[STX:0x02]と[ETX:0x03]に挟まれた[一電文](※STX,ETX,チェックサム抜き、[1012→02,1013→03,1010→10]戻し済み)</param>
        /// <param name="size">dataの有効バイト数</param>
        private void OnCommandRecv(BaseSocket sender, byte[] data, int size)
        {
            // ┌───┬─┬─┬─┬─┬─┬─┬─┬─┬───┬──┬──┬─┬─┬─┬─┬─┬───┬───┐
            // │(STX) │DNO [例.P1234567]             │SEQNO │CMD │BIT+CODE│DATA          │(CRC) │(ETX) │
            // └───┴─┴─┴─┴─┴─┴─┴─┴─┴───┴──┴──┴─┴─┴─┴─┴─┴───┴───┘
            //            0   1   2   3   4   5   6   7       8     9    10  11  12 …
            try
            {
                if (size < 10)
                {
                    throw new Exception("受信データ長が10バイト未満"); // 10バイト以下ならば誤電文
                }

                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 受信");

                byte[] sendCommand = new byte[2048];
                byte[] sendData = new byte[2048];
                int length;
                int sendDataSize;

                // 電文記録ファイル
                DateTime now = DateTime.Now;
                CommDataWriter(GetRawHexString(data, size), now);

                int command = data[9];
                switch (command)
                {
                    case 0x67: // LCDデータ要求

                        // リクエストコード49 = メニュー
                        if (BytesToShort(data, 12 + 0) == 49)
                        {
                            ///// DNO～コマンド(67[H])までコピー
                            Buffer.BlockCopy(data, 0, sendCommand, 0, 10);
                            ///// リクエストコードをコピー
                            Buffer.BlockCopy(data, 12, sendCommand, 10, 2);

                            // 空の仮想端末メニューを返信
                            byte[] lcd_buffer = new byte[1024];
                            int len = SetLcdEmptyMenuData(lcd_buffer);
                            if (len > 0)
                            {
                                Buffer.BlockCopy(lcd_buffer, 0, sendCommand, 12, len);
                            }
                            length = FormatAdd(sendCommand, len + 12, sendData);
                            sendDataSize = sender.SendData(sendData, length);
                        }

                        RefreshCommandCmnRows(data, size);

                        break;

                    case 0x68: // LCDデータ転送

                        ///// DNO～コマンドまでコピー
                        Buffer.BlockCopy(data, 0, sendCommand, 0, 10);
                        ///// リクエストコードをコピー
                        Buffer.BlockCopy(data, 12, sendCommand, 10, 2);

                        // 同じリクエストコードで空レスポンスを返信
                        length = FormatAdd(sendCommand, 12, sendData);
                        sendDataSize = sender.SendData(sendData, length);

                        RefreshCommandCmnRows(data, size);

                        break;

                    case 0x61: // ステータス転送

                        SendResponse(sender, data);
                        RefreshCommandCmnRows(data, size);

                        ProcOfChangingProcess(data, size);
                        ProcOfChangingDialBit(data, size, now);

                        break;

                    case 0x63: // 警報監視状態転送
                    case 0x64: // メンテナンスデータ転送

                        SendResponse(sender, data);
                        RefreshCommandCmnRows(data, size);

                        break;

                    case 0x62: // モニタデータ転送

                        SendResponse(sender, data);
                        RefreshCommandCmnRows(data, size);

                        ProcOfChangingProcess(data, size);
                        ProcOfChangingDialBit(data, size, now);

                        MemorizeLastMon(data, size, now);
                        int recvCount = (size - 12) / 2;
                        RefreshMonitorRows(LastMon, recvCount, 0, 31);

                        if (IsCalcAndWriteStartDateTimeCallingNeed)
                        {
                            CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, $"{BytesToShort(data, 12 + 2 * 1)}");
                            IsCalcAndWriteStartDateTimeCallingNeed = false;
                        }

                        if ("1" == PrevStatus)
                        {
                            // 現在日時 が 書き込み予定日時 以上の場合は書く([透析開始後に受信したモニタデータを透析開始時トレンドデータとして記録]を含む)
                            if (0 <= now.CompareTo(NextDataPickup))
                            {
                                WriteTrend(now, LastMon);
                                UpdateNextDataPickup(now);
                            }
                        }

                        break;

                    case 0x66: // ログデータ転送

                        SendResponse(sender, data);
                        RefreshCommandCmnRows(data, size);

                        ProcOfChangingDialBit(data, size, now);

                        RefreshLogRows(data, size);

                        WriteDeviceLog(data, now);

                        if ("1" == PrevStatus)
                        {
                            // ケア時のトレンドが[ON]、かつ、ログ種別／コードが[0x0103:ケア]
                            if (true == MyConfig.DataPickupAtCare && 0x01 == data[12 + 1] && 0x03 == data[12 + 2])
                            {
                                if (DateTime.MinValue != LastMonRecvDt)
                                {
                                    WriteTrend(now, LastMon);
                                }
                            }
                        }

                        // ログ種別／コードが[0x0101:測定(透析中血圧)]
                        if (0x01 == data[12 + 1] && 0x01 == data[12 + 2])
                        {
                            WriteVital(data, now, VitalTreating);
                        }
                        // ログ種別／コードが[0x0102:体温]
                        else if (0x01 == data[12 + 1] && 0x02 == data[12 + 2])
                        {
                            WriteBodyTemperature(data, now);
                        }
                        // ログ種別／コードが[0x0104:透析前血圧)]
                        else if (0x01 == data[12 + 1] && 0x04 == data[12 + 2])
                        {
                            WriteVital(data, now, VitalBefore);
                        }
                        // ログ種別／コードが[0x0105:透析後血圧]
                        else if (0x01 == data[12 + 1] && 0x05 == data[12 + 2])
                        {
                            WriteVital(data, now, VitalAfter);
                        }
                        // ログ種別／コードが[0x0106:再循環率]
                        else if (0x01 == data[12 + 1] && 0x06 == data[12 + 2])
                        {
                            WriteReLoopRate(data, now);
                            // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
                            WriteLogMonData(data, now, RecrclRt);
                            // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end
                        }
                        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
                        // ログ種別／コードが[0x0109:引き残し量]
                        else if (0x01 == data[12 + 1] && 0x09 == data[12 + 2])
                        {
                            WriteLogMonData(data, now, IhdfPll);
                        }
                        // ログ種別／コードが[0x0113:静的静脈圧記録終了]
                        else if (0x01 == data[12 + 1] && 0x13 == data[12 + 2])
                        {
                            WriteLogMonData(data, now, SttcVnsPrssr);
                        }
                        // ログ種別／コードが[0x0114:アクセス内圧力比率算出実施]
                        else if (0x01 == data[12 + 1] && 0x14 == data[12 + 2])
                        {
                            WriteLogMonData(data, now, IapRt);
                        }
                        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end
                        break;

                    case 0x65: // 装置オプション転送(※透析装置側での変更などで送信されてくる)

                        SendResponse(sender, data);
                        RefreshCommandCmnRows(data, size);

                        MemorizeDeviceOptions(data, size);

                        break;

                    case 0xe5: // 装置オプション読み出し             

                        RefreshCommandCmnRows(data, size);

                        // 終了コードが {"0":"正常終了"} なら内部メモリに保存
                        if (0 == data[11])
                        {
                            MemorizeDeviceOptions(data, size);
                        }
                        else
                        {
                            // 装置オプション読み出しコマンドを再送
                            SendCommandReadDeviceOptions(sender, data);
                        }

                        break;

                    default:

                        RefreshCommandCmnRows(data, size);
                        SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 未対応");

                        break;
                }

                // ソケットの接続確立直後に実施する処理(※接続確立が発生する≒コマンド受信なのでコマンド受信後に実施)
                if (IsRightAfterAccepted)
                {
                    SendCommandReadDeviceOptions(sender, data);

                    IsRightAfterAccepted = false;
                }
            }
            catch (Exception ex)
            {
                SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 誤電文");

                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void SendResponse(BaseSocket sender, byte[] data)
        {
            byte[] sendCommand;
            byte[] sendData;
            int size;
            int sendDataSize;

            // 製造番号以降10バイトコピーして送信する
            sendCommand = new byte[10];
            Buffer.BlockCopy(data, 0, sendCommand, 0, 10);

            // 送信コマンドを作成する
            sendData = new byte[32];
            size = FormatAdd(sendCommand, 10, sendData);
            sendDataSize = sender.SendData(sendData, size);
        }

        /// <summary>
        /// STX・ETX変換、STX・CRC・ETX付加。
        /// </summary>
        /// <param name="BeforeBuf">変換元バッファ</param>
        /// <param name="BeforeLen">変換元バッファ長</param>
        /// <param name="AfterBuf">変換先バッファ</param>
        private int FormatAdd(byte[] BeforeBuf, int BeforeLen, byte[] AfterBuf)
        {
            short i, len, crc;
            byte[] work = new byte[10240];

            // BeforeLenチェック
            if (BeforeLen <= 0 || BeforeLen >= work.Length)
            {
                return (0);
            }

            // CRCの算出
            for (i = 0, crc = 0; i < BeforeLen; i++) crc += BeforeBuf[i];

            Array.Clear(work, 0, work.Length);
            work[0] = 0x02; // STXをセット
            len = 1;

            for (i = 0; i < BeforeLen; i++)
            {
                if (BeforeBuf[i] == 0x02)
                {
                    work[len] = 0x10;
                    len++;
                    work[len] = 0x12;
                }
                else if (BeforeBuf[i] == 0x03)
                {
                    work[len] = 0x10;
                    len++;
                    work[len] = 0x13;
                }
                else if (BeforeBuf[i] == 0x10)
                {
                    work[len] = 0x10;
                    len++;
                    work[len] = 0x10;
                }
                else
                {
                    work[len] = BeforeBuf[i];
                }
                len++;
                if (len >= work.Length - 2) // サイズオーバー(-2:CRC,ETX)
                {
                    len = 0;
                    break;
                }
            }
            if (len > 1)
            {
                if ((byte)crc == 0x02 || (byte)crc == 0x03 || (byte)crc == 0x10)
                {
                    work[len++] = 0x10;
                    if ((byte)crc < 0x10)
                    {
                        work[len++] = (byte)(0x10 + (byte)crc);
                    }
                    else
                    {
                        work[len++] = (byte)crc;
                    }
                }
                else
                {
                    work[len++] = (byte)crc;
                }
                work[len++] = 0x03; // ETX

                Buffer.BlockCopy(work, 0, AfterBuf, 0, len);
            }
            else
            {
                len = 0;
            }

            return (len);
        }

        /// <summary>
        /// Short型を上位・下位反転してByte型に変換
        /// </summary>
        /// <param name="AfterBuf">変換先バッファ</param>
        /// <param name="off">変換先バッファオフセット</param>
        /// <param name="data">変換元データ</param>
        private void ShortToBytes(byte[] AfterBuf, int off, short data)
        {
            AfterBuf[off] = (byte)(data >> 8);
            AfterBuf[off + 1] = (byte)(data);
        }

        /// <summary>
        /// 空メニューのLCD表示データをセットする
        /// </summary>
        /// <param name="lcd_buffer">LCD表示データ</param>
        /// <returns>コマンド長</returns>
        private int SetLcdEmptyMenuData(byte[] lcd_buffer)
        {
            int i;
            int j;
            int len = 0;

            // メニュー名称(6バイト×4件)をスペースで埋める
            for (i = 0; i < 6 * 4; i++)
            {
                lcd_buffer[len + i] = 0x20;
            }
            len += (6 * 4);

            // メニュー項目に0(=無し(非表示))をセットする
            for (i = 0; i < 4; i++)
            {
                for (j = 0; j < 8; j++)
                {
                    ShortToBytes(lcd_buffer, len, 0);
                    len += 2;
                    len += 12;
                }
            }
            return len;
        }

        /// <summary>
        /// 工程の変化時の処理
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private void ProcOfChangingProcess(byte[] data, int size)
        {
            int currentProcess = BytesToShort(data, 12 + 2 * 0);
            switch (currentProcess)
            {
                case 1: SetTreatStatus("治療外(プリセット)"); break;
                case 2: SetTreatStatus("治療外(洗浄)"); break;
                case 3: SetTreatStatus("治療外(酸洗)"); break;
                case 4: SetTreatStatus("治療外(消毒)"); break;
                case 5: SetTreatStatus("治療外(滞留)"); break;
                case 6: SetTreatStatus("治療外(液置換)"); break;
                case 7: SetTreatStatus("治療外(準備回収)"); break;
                case 8: SetTreatStatus("治療外(ガスパージ)"); break;
                case 9: SetTreatStatus("治療外(排液)"); break;
                case 10: SetTreatStatus("治療中(停止)"); break;
                case 11: SetTreatStatus("治療中(運転)"); break;
                default: SetTreatStatus($"治療外({currentProcess})"); break;
            }
        }

        /// <summary>
        /// 透析中bitの変化時の処理
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        /// <param name="argNow">受信処理内で原則一律で使われる現在時刻</param>
        private void ProcOfChangingDialBit(byte[] data, int size, DateTime argNow)
        {
            int dialBit = data[10] & 0x01;

            // 臨床工程が[不定]から[治療中] (※[透析中bitがON]を受け取った)
            if (null == PrevStatus && 1 == dialBit)
            {
                PrevStatus = "1";
                IsCalcAndWriteStartDateTimeCallingNeed = true;
                NextDataPickup = DateTime.MinValue; // 次に受信したモニタデータを透析開始時トレンドデータとして記録させるため最古の日時をセット
            }
            // 臨床工程が[不定]から[治療外] (※[透析中bitがOFF]を受け取った)
            else if (null == PrevStatus && 0 == dialBit)
            {
                PrevStatus = "0";
            }
            // 臨床工程が[治療外]から[治療中] (※[透析中bitがON]を受け取った)
            else if (null != PrevStatus && "0" == PrevStatus && 1 == dialBit)
            {
                PrevStatus = "1";
                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={argNow:yyyyMMddHHmmss}");
                NextDataPickup = DateTime.MinValue; // 次に受信したモニタデータを透析開始時トレンドデータとして記録させるため最古の日時をセット
            }
            // 臨床工程が[治療中]から[排液判定中] (※[透析中bitがOFF]を受け取った)
            else if (null != PrevStatus && "1" == PrevStatus && 0 == dialBit)
            {
                PrevStatus = "2";
                JudgeDialEndThreadStart();
            }
            // 臨床工程が[排液判定中]から[治療中] (※[透析中bitがON]を受け取った)
            else if (null != PrevStatus && "2" == PrevStatus && 1 == dialBit)
            {
                PrevStatus = "1";
                JudgeDialEndThreadAbort();
            }
        }

        /// <summary>
        /// 排液判定の処理
        /// </summary>
        /// <param name="argDateTimeNow">現在日時</param>
        private void JudgeDialEnd(object argDateTimeNow)
        {
            try
            {
                Thread.Sleep(MyConfig.JudgeDialEndSeconds * 1000);

                try
                {
                    ThreOfJudgeDialEndMutex.WaitOne();

                    lock (LastMon)
                    {
                        PrevStatus = "0";
                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=END\toccurdate={(DateTime)argDateTimeNow:yyyyMMddHHmmss}");

                        // 透析終了時のトレンド記録＋透析終了時の積算値系データ等の記録
                        WriteTrend((DateTime)argDateTimeNow, LastMon);
                        WriteLastMonForDialysisEnd(LastMon);

                        // 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名を＜ファイル名末尾に「YYYYMMDD-HHMMSS治療終了」がついた名前＞にリネーム
                        string srcPath = $"{MyConfig.DataDir}\\{BptxtFileName}";
                        BptxtFileName = $"{Path.GetFileNameWithoutExtension(BptxtFileName)}{(DateTime)argDateTimeNow:yyyyMMdd-HHmmss}治療終了.bptxt";
                        AppCmn.MoveWithMutex(srcPath, $"{MyConfig.DataDir}\\{BptxtFileName}");

                        ThreOfJudgeDialEnd = null;
                    }
                }
                finally
                {
                    ThreOfJudgeDialEndMutex.ReleaseMutex();
                }
            }
            catch (ThreadAbortException ex)
            {
                Console.Write(ex.Message); // 正常動作で予期される例外なのでコンソールにだけ投げる
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// 排液判定をスレッドで開始
        /// </summary>
        private void JudgeDialEndThreadStart()
        {
            try
            {
                ThreOfJudgeDialEndMutex.WaitOne();

                // 排液判定が始まっていなければ排液判定を開始
                if (null == ThreOfJudgeDialEnd)
                {
                    ThreOfJudgeDialEnd = new Thread(new ParameterizedThreadStart(JudgeDialEnd));
                    ThreOfJudgeDialEnd.Start(DateTime.Now);
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
            finally
            {
                ThreOfJudgeDialEndMutex.ReleaseMutex();
            }
        }

        /// <summary>
        /// 排液判定のスレッドを中止
        /// </summary>
        private void JudgeDialEndThreadAbort()
        {
            try
            {
                ThreOfJudgeDialEndMutex.WaitOne();

                // 排液判定が始まっていれば排液判定を中止
                if (null != ThreOfJudgeDialEnd)
                {
                    ThreOfJudgeDialEnd.Abort();
                    ThreOfJudgeDialEnd.Join(3000); // 3秒も待てば十分と思われる
                    ThreOfJudgeDialEnd = null;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
            finally
            {
                ThreOfJudgeDialEndMutex.ReleaseMutex();
            }
        }

        /// <summary>
        /// バイト配列に格納されているある範囲のバイトを文字列にデコードします。
        /// </summary>
        /// <param name="argBytes">デコード対象のバイト シーケンスが格納されたバイト配列。</param>
        /// <param name="argCount">デコードするバイト数。</param>
        /// <returns>文字列</returns>
        private string GetString(byte[] argBytes, int argCount)
        {
            byte[] bytes = new byte[argCount];
            Buffer.BlockCopy(argBytes, 0, bytes, 0, argCount);
            Encoding sjisEnc = Encoding.GetEncoding("Shift_JIS");

            return sjisEnc.GetString(bytes);
        }

        /// <summary>
        /// Byte配列を16進数表記文字列に変換する
        /// </summary>
        /// <param name="argBytes">Byte配列</param>
        /// <param name="argCount">変換するバイト数</param>
        /// <returns>16進文字列</returns>
        private string GetRawHexString(byte[] argBytes, int argCount)
        {
            string ret = "";
            for (int i = 0; i < argCount; i++)
            {
                ret += argBytes[i].ToString("X2");
            }

            return ret;
        }

        /// <summary>
        /// byte配列中の2bytesをビッグエンディアン解釈でshortに変換
        /// </summary>
        /// <param name="argBytes">byte配列</param>
        /// <param name="argStartPos">2bytesを取り出す開始位置</param>
        /// <returns>変換したshort値</returns>
        private short BytesToShort(byte[] argBytes, int argStartPos)
        {
            return (short)(argBytes[argStartPos] * 256 + argBytes[argStartPos + 1]);
        }

        /// <summary>
        /// byte配列よりshortのモニタデータ配列を取得
        /// </summary>
        /// <param name="argBytes">byte配列</param>
        /// <param name="argStartPos">モニタデータの開始位置</param>
        /// <param name="argMonDatasCount">モニタデータ項目数</param>
        /// <returns>shortのモニタデータ配列</returns>
        private short[] GetShortMonitorData(byte[] argBytes, int argStartPos, int argMonDatasCount)
        {
            short[] monDatas = new short[argMonDatasCount];
            for (int i = 0; i < monDatas.Length - 1; i++)
            {
                monDatas[i] = EmptyMonData;
            }

            if (null != argBytes)
            {
                short val;
                int count = 0;
                byte[] shortBytes = new byte[2];

                if (BitConverter.IsLittleEndian)
                {
                    // アーキテクチャがリトル エンディアン

                    for (int i = argStartPos; (i < argBytes.Length) && (count < argMonDatasCount); i += 2, count++)
                    {
                        // 装置から受信するコマンドは[ビッグエンディアン]なので、ひっくり返してリトルエンディアンで格納
                        shortBytes[0] = argBytes[i + 1];
                        shortBytes[1] = argBytes[i];

                        try
                        {
                            val = BitConverter.ToInt16(shortBytes, 0);
                        }
                        catch (Exception ex)
                        {
                            val = EmptyMonData;

                            MyLog.AddLogInfo(this, "", ex);
                        }

                        monDatas[count] = val;
                    }
                }
                else
                {
                    //アーキテクチャがビッグ エンディアン

                    for (int i = argStartPos; (i < argBytes.Length) && (count < argMonDatasCount); i += 2, count++)
                    {
                        // 装置から受信するコマンドは[ビッグエンディアン]なので、そのままビッグエンディアンで格納
                        shortBytes[0] = argBytes[i];
                        shortBytes[1] = argBytes[i + 1];

                        try
                        {
                            val = BitConverter.ToInt16(shortBytes, 0);
                        }
                        catch (Exception ex)
                        {
                            val = EmptyMonData;

                            MyLog.AddLogInfo(this, "", ex);
                        }

                        monDatas[count] = val;
                    }
                }
            }

            return monDatas;
        }

        /// <summary>
        /// コマンド共通データ[製造番号/シーケンシャルNo/コマンドコード/ステータス]を表示する
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private void RefreshCommandCmnRows(byte[] data, int size)
        {
            // [先頭～ログデータ項目のひとつ前]を一旦全部空にする
            for (int rowPos = 0; rowPos < LogStartRowIdx; rowPos++)
            {
                UpdateMyDataTable(rowPos, "");
            }

            string recvRawHex = GetRawHexString(data, size);

            // 製造番号
            UpdateMyDataTable(0, GetString(data, 8));
            // シーケンシャルNo
            UpdateMyDataTable(1, recvRawHex.Substring(16, 2));
            // コマンドコード
            UpdateMyDataTable(2, recvRawHex.Substring(18, 2));
            // ステータス
            UpdateMyDataTable(3, recvRawHex.Substring(20, 4));
        }

        /// <summary>
        /// モニタデータを表示する
        /// </summary>
        /// <param name="monDatas">モニタデータ配列</param>
        /// <param name="recvItemsCount">装置から受信したモニタデータの項目数</param>
        /// <param name="processAddress">工程のアドレス番号</param>
        /// <param name="treatModeAddress">治療モードのアドレス番号</param>
        protected void RefreshMonitorRows(short[] monDatas, int recvItemsCount, int processAddress, int treatModeAddress)
        {
            // [モニタデータ項目の先頭～末尾]
            for (int rowPos = MonStartRowIdx; rowPos < MyDataTable.Rows.Count; rowPos++)
            {
                UpdateMyDataTable(rowPos, ""); // 一旦空に

                int addr = NkkMonDefine.Items[rowPos - MonStartRowIdx].addr;

                // 受信データに該当アドレスのデータが存在する場合(※「I、J」には「P、Q」の項目は無いなどを想定)
                if (addr <= recvItemsCount - 1)
                {
                    short rawValue = monDatas[addr];
                    string dispStr;

                    if (rawValue.Equals(EmptyMonData))
                    {
                        dispStr = "(空)";
                    }
                    else if (addr == processAddress)
                    {
                        dispStr = GetProcessName(rawValue);
                    }
                    else if (addr == treatModeAddress)
                    {
                        dispStr = GetTreatModeName(rawValue);
                    }
                    else
                    {
                        dispStr = GetFormattedValue(rawValue, NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    }

                    UpdateMyDataTable(rowPos, dispStr);
                }
            }
        }

        /// <summary>
        /// ログデータを表示する
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        protected void RefreshLogRows(byte[] data, int size)
        {
            // [ログデータ項目の先頭～モニタデータ項目の先頭ひとつ前]を一旦全部空にする
            for (int loopRowPos = LogStartRowIdx; loopRowPos < MonStartRowIdx; loopRowPos++)
            {
                UpdateMyDataTable(loopRowPos, "");
            }

            int rowPos = LogStartRowIdx;
            string recvRawHex = GetRawHexString(data, size);

            // ログNo
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(24, 2), 16)}");
            // 種別(Hex)
            UpdateMyDataTable(rowPos++, recvRawHex.Substring(26, 2));
            // コード(Hex)
            UpdateMyDataTable(rowPos++, recvRawHex.Substring(28, 2));
            // 発生日付(BCD)
            UpdateMyDataTable(rowPos++, recvRawHex.Substring(30, 8));
            // 発生時刻(BCD)
            UpdateMyDataTable(rowPos++, recvRawHex.Substring(38, 6));
            // 発生透析時間
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(44, 4), 16)}");
            // 関連データ1
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(48, 4), 16)}");
            // 関連データ2
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(52, 4), 16)}");
            // 関連データ3
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(56, 4), 16)}");
            // 関連データ4
            UpdateMyDataTable(rowPos++, $"{ Convert.ToInt32(recvRawHex.Substring(60, 4), 16)}");
        }

        /// <summary>
        /// 工程番号より工程名称を取得
        /// </summary>
        private string GetProcessName(int argNo)
        {
            switch (argNo)
            {
                case 1: return "プリセット";
                case 2: return "洗浄";
                case 3: return "酸洗";
                case 4: return "消毒";
                case 5: return "滞留";
                case 6: return "液置換";
                case 7: return "準備回収";
                case 8: return "ガスパージ";
                case 9: return "排液";
                case 10: return "停止";
                case 11: return "運転";
            }

            return $"不明({argNo})";
        }

        /// <summary>
        /// 治療モード番号より治療モード名称を取得
        /// </summary>
        private string GetTreatModeName(int argNo)
        {
            switch (argNo)
            {
                case 0: return "ＨＤ";
                case 1: return "ECUM";
                case 2: return "HDF";
                case 3: return "ＨＦ";
                case 4: return "HD＋補液";
                case 5: return "予約(5)";
                case 6: return "AFBF";
                case 7: return "OHDF";
                case 8: return "OHF";
                case 9: return "予約(9)";
                case 10: return "I-HDF";
            }

            return $"不明({argNo})";
        }

        /// <summary>
        /// 生モニタデータより小数点桁を書式整形した文字列を取得
        /// </summary>
        private string GetFormattedValue(short argRawValue, int argDecimalFigure, string argFormattingString)
        {
            // 小数点桁数が[0]や[マイナス値(※通常ありえない)]の場合は、そのまま文字列化する
            if (0 >= argDecimalFigure)
            {
                return $"{argRawValue}";
            }
            else
            {
                // 割り算による丸め対策としてdecimalで計算
                decimal tmpDec = argRawValue;
                tmpDec = tmpDec / ((decimal)Math.Pow(10, argDecimalFigure));
                return tmpDec.ToString(argFormattingString);
            }
        }

        /// <summary>
        /// 装置オプション読み出しコマンドを送信する
        /// </summary>
        /// <param name="sender">SocketBaseインスタンス</param>
        /// <param name="recvData">装置からの受信データ</param>
        private void SendCommandReadDeviceOptions(BaseSocket sender, byte[] recvData)
        {
            // Byte配列に送信コマンドを付加する

            // 製造番号をコピー
            byte[] sendCommand = new byte[2048];
            Buffer.BlockCopy(recvData, 0, sendCommand, 0, 8);

            // シーケンシャルNo
            if ((0x10 <= recvData[8]) && (recvData[8] < 0xff))
            {
                // 受信シーケンシャルNoが10[Hex]以上FF[Hex]未満の場合には1加算する
                sendCommand[8] = (byte)(recvData[8] + 1);
            }
            else
            {
                // 「受信シーケンシャルNoが10[Hex]より小さい」 または 「FF[Hex]」の場合は11[Hex]にする
                sendCommand[8] = 0x11;
            }

            // コマンド
            sendCommand[9] = 0xe5;

            // 装置オプション読み出しコマンドを送信する
            int length;
            byte[] sendData = new byte[2048];
            length = FormatAdd(sendCommand, 10, sendData);
            sender.SendData(sendData, length);
        }

        /// <summary>
        /// [装置オプション]を内部メモリに保存
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private void MemorizeDeviceOptions(byte[] data, int size)
        {
            int count = (size - 12) / 2;

            // 一旦全てをリセット
            for (int i = 0; i < DeviceOption.Length; i++)
            {
                DeviceOption[i] = 0;
            }

            // 受信したサイズ分を保存
            for (int i = 0; i < count; i++)
            {
                DeviceOption[i] = BytesToShort(data, 12 + 2 * i);
            }

            // 装置オプション[BV計]と[BVplus]の状態を見て最後に受信したモニタデータ内容を強制変更(※装置オプション受信前にモニタデータ受信していた場合の対策)
            if (1 == GetDeviceOptionBit(DevOptBvplus))
            {
                LastMon[17] = EmptyMonData; // アドレス17:ΔBV を 空 に
            }
            else if (1 == GetDeviceOptionBit(DevOptBv))
            {
                LastMon[100] = EmptyMonData; // アドレス100:ΔBV(BVplus) を 空 に
            }
            else
            {
                LastMon[17] = EmptyMonData; // アドレス17:ΔBV を 空 に
                LastMon[100] = EmptyMonData; // アドレス100:ΔBV(BVplus) を 空 に
            }
        }

        /// <summary>
        /// 保存された装置オプションからビットのON/OFFを読み出し
        /// </summary>
        /// <param name="argDevOptCode">特定の装置オプションビットを指すタプル(※自クラスに定義あり)</param>
        /// <returns>{"0":"該当bitがOFF","1":"該当bitがON"}</returns>
        private int GetDeviceOptionBit((int, int) argDevOptCode)
        {
            int addr;
            int devOptNo = argDevOptCode.Item1;
            switch (devOptNo)
            {
                case 1: addr = 0; break;
                case 2: addr = 1; break;
                case 3: addr = 2; break;

                case 4: addr = 5; break;
                case 5: addr = 6; break;

                default: addr = 0; break;
            }

            int bitPos = argDevOptCode.Item2;

            return 0 == (DeviceOption[addr] & (1 << bitPos)) ? 0 : 1;
        }

        /// <summary>
        /// [最後に受信したモニタデータ]を内部メモリに保存(※積算値系データやマイナス値無効データを考慮した採用／不採用の判定含む)
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        /// <param name="argNow">受信処理内で原則一律で使われる現在時刻</param>
        private void MemorizeLastMon(byte[] data, int size, DateTime argNow)
        {
            short[] recvMonDatas = GetShortMonitorData(data, 12, (size - 12) / 2);

            // 装置オプション[BV計]と[BVplus]の状態を見てモニタデータ内容を強制変更
            if (1 == GetDeviceOptionBit(DevOptBvplus))
            {
                recvMonDatas[17] = EmptyMonData; // アドレス17:ΔBV を 空 に
            }
            else if (1 == GetDeviceOptionBit(DevOptBv))
            {
                if (100 <= recvMonDatas.Length - 1)
                {
                    recvMonDatas[100] = EmptyMonData; // アドレス100:ΔBV(BVplus) を 空 に
                }
            }
            else
            {
                recvMonDatas[17] = EmptyMonData; // アドレス17:ΔBV を 空 に

                if (100 <= recvMonDatas.Length - 1)
                {
                    recvMonDatas[100] = EmptyMonData; // アドレス100:ΔBV(BVplus) を 空 に
                }
            }

            if ("0" == PrevStatus)
            {
                for (int addr = 0; addr < LastMon.Length; addr++)
                {
                    if (addr <= recvMonDatas.Length - 1)
                    {
                        LastMon[addr] = recvMonDatas[addr];
                    }
                    else
                    {
                        LastMon[addr] = EmptyMonData;
                    }
                }

                LastMonRecvDt = argNow;
            }
            else if ("1" == PrevStatus)
            {
                for (int addr = 0; addr < LastMon.Length; addr++)
                {
                    if (addr <= recvMonDatas.Length - 1)
                    {
                        bool isMemorize = false;

                        int monDataType = 0;
                        switch (addr)
                        {
                            case 1:
                            case 2:
                            case 5:
                            case 7:
                            case 9:
                            case 30:
                            case 69:
                            case 72:
                                monDataType = 1; break;
                            case 38:
                            case 79:
                            case 88:
                                monDataType = 2; break;
                        }

                        if (0 == monDataType)
                        {
                            isMemorize = true;
                        }
                        else if (1 == monDataType)
                        {
                            // 積算値系データ([0x8000→0]が有効 で ＜[0x8000]と[0] 以外＞が有効)
                            if (EmptyMonData == LastMon[addr] && 0 == recvMonDatas[addr])
                            {
                                isMemorize = true;
                            }
                            else if (false == (EmptyMonData == recvMonDatas[addr] || 0 == recvMonDatas[addr]))
                            {
                                isMemorize = true;
                            }
                        }
                        else if (2 == monDataType)
                        {
                            // マイナス値無効データ(＜[0x8000]と[マイナス値] 以外＞が有効)
                            if (false == (EmptyMonData == recvMonDatas[addr] || -1 >= recvMonDatas[addr]))
                            {
                                isMemorize = true;
                            }
                        }

                        if (isMemorize)
                        {
                            LastMon[addr] = recvMonDatas[addr];
                        }
                    }
                    else
                    {
                        LastMon[addr] = EmptyMonData;
                    }
                }

                LastMonRecvDt = argNow;
            }
            else if ("2" == PrevStatus)
            {
                ; // 排液判定中は更新しない
            }
        }

        /// <summary>
        /// トレンドデータをファイルに書き込む
        /// </summary>
        /// <param name="argOccurDate">occurdateに書かれる時刻</param>
        /// <param name="argMonDatas">トレンドデータとして書き出すモニタデータ</param>
        private void WriteTrend(DateTime argOccurDate, short[] argMonDatas)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=MON\t");
                sb.Append($"occurdate={argOccurDate:yyyyMMddHHmmss}\t");
                sb.Append("class=1\t");
                sb.Append("items={");

                for (int i = 0; i < NkkMonDefine.Items.Count; i++)
                {
                    int addr = NkkMonDefine.Items[i].addr;

                    // 受信データに該当アドレスのデータが存在する場合(※「I、J」には「P、Q」の項目は無いなどを想定)
                    if (addr <= argMonDatas.Length - 1)
                    {
                        switch (addr)
                        {
                            case 89: // 再循環率測定結果(BVMS連携用) mni_monitor.data_type[3:再循環率]
                            case 90: // 最高血圧 mni_monitor.data_type[2:透析中血圧]／[5:透析前血圧]／[6:透析後血圧]
                            case 91: // 最低血圧 mni_monitor.data_type[2:透析中血圧]／[5:透析前血圧]／[6:透析後血圧]
                            case 92: // 平均血圧 mni_monitor.data_type[2:透析中血圧]／[5:透析前血圧]／[6:透析後血圧]
                            case 93: // 脈拍 mni_monitor.data_type[2:透析中血圧]／[5:透析前血圧]／[6:透析後血圧]
                            case 94: // 体温 mni_monitor.data_type[4:体温測定]
                                continue; // 書かずに次のモニタデータへ
                        }

                        short rawValue = argMonDatas[addr];

                        switch (addr)
                        {
                            case 38: // Kt/V(測定値) マイナス値無効データだが「 透析前[-1]→透析中[-1] 」が起こりえる
                            case 79: // URR マイナス値無効データだが「 透析前[-1]→透析中[-1] 」が起こりえる
                            case 88: // PRR マイナス値無効データだが「 透析前[-1]→透析中[-1] 」が起こりえる
                                if (-1 >= rawValue)
                                {
                                    continue; // 書かずに次のモニタデータへ
                                }
                                break;
                        }

                        if (rawValue.Equals(EmptyMonData))
                        {
                            continue; // 書かずに次のモニタデータへ
                        }
                        else
                        {
                            string writeValue = GetFormattedValue(rawValue, NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                            sb.Append($"\"{addr}\":{writeValue},");
                        }
                    }
                }

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString().TrimEnd(',') + "}");
            }
        }

        /// <summary>
        /// 次にモニタデータをbptxtに書き込む予定の日時を次のものに更新する
        /// </summary>
        /// <param name="argNow">受信処理内で原則一律で使われる現在時刻</param>
        private void UpdateNextDataPickup(DateTime argNow)
        {
            if (DateTime.MinValue == NextDataPickup)
            {
                NextDataPickup = argNow;
            }

            while (true)
            {
                NextDataPickup = NextDataPickup.AddMinutes(MyConfig.DataPickupIntervalMinutes);

                // 書き込み予定日時 が 現在日時 を超えたら更新終了で抜ける
                if (0 < NextDataPickup.CompareTo(argNow))
                {
                    break;
                }
            }
        }

        /// <summary>
        /// 血圧データ(バイタルデータ)をファイルに書き込む
        /// </summary>
        /// <param name="data"></param>
        /// <param name="argOccurDate">occurdateに書かれる時刻</param>
        /// <param name="argType">前／後／中を示す値(mni_monitor.data_type)</param>
        private void WriteVital(byte[] data, DateTime argOccurDate, int argType)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=MON\t");
                sb.Append($"occurdate={argOccurDate:yyyyMMddHHmmss}\t");
                sb.Append($"class={argType}\t");
                sb.Append("items={");

                // 最高血圧
                sb.Append($"\"90\":{BytesToShort(data, 12 + 12)},");
                // 最低血圧
                sb.Append($"\"91\":{BytesToShort(data, 12 + 14)},");
                // 平均血圧
                sb.Append($"\"92\":{BytesToShort(data, 12 + 16)},");
                // 脈拍
                sb.Append($"\"93\":{BytesToShort(data, 12 + 18)}" + "}");

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString());
            }
        }

        /// <summary>
        /// 体温データをファイルに書き込む
        /// </summary>
        /// <param name="data"></param>
        /// <param name="argOccurDate">occurdateに書かれる時刻</param>
        private void WriteBodyTemperature(byte[] data, DateTime argOccurDate)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=MON\t");
                sb.Append($"occurdate={argOccurDate:yyyyMMddHHmmss}\t");
                sb.Append("class=4\t");
                sb.Append("items={");

                // 体温
                sb.Append($"\"94\":{GetFormattedValue(BytesToShort(data, 12 + 12), 1, "0.0")}" + "}");

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString());
            }
        }

        /// <summary>
        /// 再循環率をファイルに書き込む
        /// </summary>
        /// <param name="data"></param>
        /// <param name="argOccurDate">occurdateに書かれる時刻</param>
        private void WriteReLoopRate(byte[] data, DateTime argOccurDate)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=MON\t");
                sb.Append($"occurdate={argOccurDate:yyyyMMddHHmmss}\t");
                sb.Append("class=3\t");
                sb.Append("items={");

                // 再循環率
                sb.Append($"\"89\":{BytesToShort(data, 12 + 12)}" + "}");

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString());
            }
        }

        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 start
        private void WriteLogMonData(byte[] data, DateTime argOccurDate, int argType)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=LOGMON\t");
                sb.Append($"occurdate={argOccurDate:yyyy/MM/dd HH:mm:ss}\t");
                sb.Append($"class={argType}\t");
                sb.Append("items={");

                sb.Append($"\"data\":{BytesToShort(data, 12 + 12)}" + "}");

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString());
            }
        }
        // add FNSI-改修No.324,No,325 再循環率、IHDF引き残し、静的静脈圧、IAPRatioの有効値更新 夏 end

        /// <summary>
        /// ログデータ転送で受信した装置記録をファイルに書き込む
        /// </summary>
        /// <param name="data"></param>
        /// <param name="argOccurDate">occurdateに書かれる時刻</param>
        private void WriteDeviceLog(byte[] data, DateTime argOccurDate)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=LOG\t");
                sb.Append($"occurdate={argOccurDate:yyyyMMddHHmmss}\t");
                sb.Append($"code={data[12 + 1]:X2}{data[12 + 2]:X2}\t");

                int kind = data[12 + 1];
                if (0x80 <= kind && kind <= 0xbf)
                {
                    sb.Append("class=1\t"); // 警報
                }
                else if (0x40 <= kind && kind <= 0x7f)
                {
                    sb.Append("class=2\t"); // 報知
                }
                else if (0xf4 <= kind && kind <= 0xf5)
                {
                    sb.Append("class=3\t"); // 操作
                }
                else
                {
                    sb.Append("class=4\t"); // その他
                }

                sb.Append("version=00\t");

                sb.Append($"data1={BytesToShort(data, 12 + 12)}\t");
                sb.Append($"data2={BytesToShort(data, 12 + 14)}\t");
                sb.Append($"data3={BytesToShort(data, 12 + 16)}\t");
                sb.Append($"data4={BytesToShort(data, 12 + 18)}");

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString());
            }
        }

        /// <summary>
        /// [最後に受信したモニタデータ]を透析終了時の積算値系データ等としてファイルに記録
        /// </summary>
        /// <param name="argMonDatas">最後に受信したモニタデータ</param>
        private void WriteLastMonForDialysisEnd(short[] argMonDatas)
        {
            if (false == string.IsNullOrWhiteSpace(BptxtFileName))
            {
                StringBuilder sb = new StringBuilder();
                sb.Append("kind=LAST_MON\t");
                sb.Append("items={");

                int addr;
                string writeStr;

                if (1 == GetDeviceOptionBit(DevOptDialPg))
                {
                    // モニタ:69:運転中の血流量積算値
                    // → ord_main.rst_blood_circulate_total「実績：血液循環積算値」
                    // ※※※
                    // 2020/07/01 記述
                    // モニタ:7:血液循環量 という同一名称のモニタデータが存在するが
                    // FNW 初期～ - [モニタ:7:血液循環量]
                    // FNW Step2 透析量PG対応～ - [モニタ:69:運転中の血流量積算値]
                    // となっており BLOOD_CIRCULATE_TOTAL × 1000 ÷ RUNNING_TIME でWebCLの血流量平均値算出処理・KT/V算出処理に使用。
                    // なお、2014/01/20時点ではFNW紹介状で本項目を血液循環量として表示しておりWebCL側でなんらかの対応をする話になった様子。
                    // ※※※
                    addr = 69;
                    writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                    {
                        sb.Append($"\"1\":{writeStr},");
                    }

                    // モニタ:30:透析運転時間
                    // → ord_main.rst_kt_v「実績：透析運転時間」
                    addr = 30;
                    writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                    {
                        sb.Append($"\"2\":{writeStr},");
                    }

                    // モニタ:68:Kt/V
                    // → ord_main.rst_kt_v「実績：Kt/V」
                    addr = 68;
                    writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                    {
                        sb.Append($"\"3\":{writeStr},");
                    }
                }

                // ※※※
                // 2020/07/01 記述
                // [実績除水量]
                // モニタに該当名称無し、かつ、REST側で未使用。
                // 同じ意味を示すと思われる[モニタ:5:除水積算値]は別で渡しており
                // そちら側のRESTにて ord_main.rst_weight_info の jsonキー[water_removal_rst]「実績除水量」 にセットされている
                // ※※※
                //content += $"\"4\":{argMonDatas[4]},";

                // モニタ:5:除水積算値
                // → ord_main.rst_weight_info の jsonキー[add_total]「除水積算値」 、および、ord_main.rst_weight_info の jsonキー[water_removal_rst]「実績除水量」
                addr = 5;
                writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                {
                    sb.Append($"\"5\":{writeStr},");
                }

                // モニタ:72:補液量現在値
                // → ord_main.rst_weight_info の jsonキー[add_water_total]「補液積算値」
                addr = 72;
                writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                {
                    sb.Append($"\"6\":{writeStr},");
                }

                if (1 == GetDeviceOptionBit(DevOptDdm))
                {
                    // モニタ:38:Kt/V(測定値)
                    // → ord_main.rst_weight_info の jsonキー[kt_v_measure]「Kt/V測定値」
                    addr = 38;
                    writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                    {
                        sb.Append($"\"7\":{writeStr},");
                    }

                    // モニタ:79:URR
                    // → ord_main.rst_weight_info の jsonキー[urr]「URR」
                    addr = 79;
                    writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                    if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                    {
                        sb.Append($"\"8\":{writeStr},");
                    }
                }

                // モニタ:32:除水目標値
                // → ord_main.rst_weight_info の jsonキー[water_removal_target]「目標除水量」
                addr = 32;
                writeStr = GetFormattedValue(argMonDatas[addr], NkkMonDefine.GetByAddr(addr).decimalFigure, NkkMonDefine.GetByAddr(addr).formattingString);
                if (EmptyMonData != argMonDatas[addr] && false == string.IsNullOrWhiteSpace(writeStr))
                {
                    sb.Append($"\"9\":{writeStr},");
                }

                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString().TrimEnd(',') + "}");
            }
        }
    }
}
