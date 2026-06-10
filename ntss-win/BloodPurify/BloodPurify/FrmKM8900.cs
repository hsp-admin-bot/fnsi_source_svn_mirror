using System;
using System.Collections.Generic;
using System.Drawing;
using System.IO;
using System.Text;
using System.Windows.Forms;
using System.Net.Sockets;
using NKK.FN3.Common.Library.TcpSocket;
using NKK.FN3.ComServer.Library;
using System.Data;
using System.Reflection;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    public partial class FrmKM8900 : FrmMonitoring
    {
        /// <summary>
        /// サーバー接続
        /// </summary>
        private BaseServerConnect Server = new BaseServerConnect();

        /// <summary>
        /// KM8900のモニタデータ処理機能
        /// </summary>
        private IKM MonDataFuncs;

        /// <summary>
        /// コンストラクタ(VSデザイナで必要)
        /// </summary>
        public FrmKM8900()
        {
            InitializeComponent();
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="argParams">呼び出し元が渡すパラメータ(※予定選択で得られるタプルの形)</param>
        /// <param name="argPortNo">待ち受け通信ポート番号</param>
        /// <param name="argDataFileNamePrefix">bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)</param>
        /// <param name="argMonDataFuncs">KM8900、KM9000 モニタデータ処理機能オブジェクト</param>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public FrmKM8900((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix, IKM argMonDataFuncs)
        public FrmKM8900((long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix, IKM argMonDataFuncs)
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
            : base(argParams, argPortNo, argDataFileNamePrefix)
        {
            InitializeComponent();

            DialysisCom = new DialysisComKM(OnCommandRecv);

            // 実装オブジェクトの参照をパラメータとして受け取る
            MonDataFuncs = argMonDataFuncs;

            //LogWriter.WriteLog(LogLevel.Debug, "0316000029", "KM-8900モニタリング画面 開始[装置index:]");

            FormTitle = "モニタリング(KM-8900)";

            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        private void FrmKM8900_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
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
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void FrmKM8900_FormClosed(object sender, FormClosedEventArgs e)
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
            AddOneRowToMyDataTable("識別文字列", "");
            AddOneRowToMyDataTable("測定値TMP", "mmHg");
            AddOneRowToMyDataTable("測定値入口圧", "mmHg");
            AddOneRowToMyDataTable("測定値返血圧", "mmHg");
            AddOneRowToMyDataTable("測定値2次膜圧(吸着圧)", "mmHg");
            AddOneRowToMyDataTable("圧力上限警報設定値TMP", "mmHg");
            AddOneRowToMyDataTable("圧力上限警報設定値入口圧", "mmHg");
            AddOneRowToMyDataTable("圧力上限警報設定値返血圧", "mmHg");
            AddOneRowToMyDataTable("圧力上限警報設定値2次膜圧(吸着圧)", "mmHg");
            AddOneRowToMyDataTable("流量情報BP瞬時流量", "mL/分");
            AddOneRowToMyDataTable("流量情報PP瞬時流量", "mL/分");
            AddOneRowToMyDataTable("流量情報DP瞬時流量", "mL/分");
            AddOneRowToMyDataTable("流量情報BP積算流量", "L");
            AddOneRowToMyDataTable("流量情報PP積算流量", "L");
            AddOneRowToMyDataTable("流量情報DP積算流量", "L");
            AddOneRowToMyDataTable("流量情報除水積算流量", "L");
            AddOneRowToMyDataTable("流量情報血漿処理目標値", "L");
            AddOneRowToMyDataTable("その他情報加温器温度", "℃");
            AddOneRowToMyDataTable("その他情報バランス", "");
            AddOneRowToMyDataTable("経過時間", "分");
            AddOneRowToMyDataTable("その他情報アラーム番号", "");
            AddOneRowToMyDataTable("その他情報自己診断番号", "");
            AddOneRowToMyDataTable("その他情報モード(用途)", "");
            AddOneRowToMyDataTable("その他情報工程情報", "");
        }

        private BaseSocket MyAccept(TcpClient sock, dgtOnException_Mng eHandler, DeviceInformation devInf)
        {
            ComSocket ret = null;

            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 接続");

                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[Accept:{devInf.DevInfoStr}]");

                ret = new ComSocket(sock, eHandler, devInf);
                ret.ReceiveCycle = 100;
                ret.ReceiveHandler = OnRecv;
                ret.ExceptionHandler = MySocketException;

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

        /// <summary>
        /// [一電文]の受信時の処理
        /// </summary>
        /// <param name="data">受信データ内の[STX:0x02]と[ETX:0x03]に挟まれた[一電文](※STX,ETX抜き)</param>
        /// <param name="size">dataの有効バイト数</param>
        private void OnCommandRecv(BaseSocket sender, byte[] data, int size, string strLogfile)
        {
            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 受信");

                const int processColumnNo = 24;

                byte[] bytes = new byte[size - 2];
                Buffer.BlockCopy(data, 0, bytes, 0, size - 2);
                string receivedData = Encoding.GetEncoding("Shift_JIS").GetString(bytes);

                // 電文記録ファイル
                DateTime now = DateTime.Now;
                CommDataWriter(receivedData, now);

                if (false == receivedData.Equals(ReceivedDataOld))
                {
                    ReceivedDataOld = receivedData;

                    bool isWrite = false;
                    bool isTreatStart = false;
                    bool isTreatEnd = false;

                    string[] monDatas = receivedData.Split(',');

                    // <> 臨床工程変更 と 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名変更
                    string currentProcStatus = monDatas[processColumnNo - 1];

                    // 臨床工程が[不定]から[治療中] (※ [2:臨床工程] を受け取った)
                    if (null == PrevStatus && "2" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療中～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, monDatas[19]);
                    }
                    // 臨床工程が[不定]から[治療外] (※ [2:臨床工程]以外 を受け取った)
                    else if (null == PrevStatus && "2" != currentProcStatus)
                    {
                        BptxtFileName = "";
                        PrevStatus = "0";
                    }
                    // 臨床工程が[治療外]から[治療中] (※ [2:臨床工程] を受け取った)
                    else if (null != PrevStatus && "0" == PrevStatus && "2" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                    }
                    // 臨床工程が[治療中]から[治療外] (※ [2:臨床工程]以外 を受け取った)
                    else if (null != PrevStatus && "1" == PrevStatus && "2" != currentProcStatus)
                    {
                        // 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名を＜ファイル名末尾に「YYYYMMDD-HHMMSS治療終了」がついた名前＞にリネーム
                        string srcPath = $"{MyConfig.DataDir}\\{BptxtFileName}";
                        BptxtFileName = $"{Path.GetFileNameWithoutExtension(BptxtFileName)}{now:yyyyMMdd-HHmmss}治療終了.bptxt";
                        AppCmn.MoveWithMutex(srcPath, $"{MyConfig.DataDir}\\{BptxtFileName}");

                        PrevStatus = "0";
                        isWrite = true;

                        isTreatEnd = true;
                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=END\toccurdate={now:yyyyMMddHHmmss}");
                    }
                    // </>

                    // <> 治療データファイル(アップロードデータのみを収集するファイル)書き出し処理
                    if (false == string.IsNullOrWhiteSpace(BptxtFileName))
                    {
                        if (false == isWrite)
                        {
                            // 現在日時 が 書き込み予定日時 以上の場合は書く
                            if (0 <= now.CompareTo(NextDataPickup))
                            {
                                isWrite = true;
                            }
                        }

                        if (isWrite)
                        {
                            // 次にモニタデータをbptxtに書き込む予定の日時 を更新
                            if (DateTime.MinValue == NextDataPickup)
                            {
                                NextDataPickup = now;
                            }
                            while (true)
                            {
                                NextDataPickup = NextDataPickup.AddMinutes(MyConfig.DataPickupIntervalMinutes);

                                // 書き込み予定日時 が 現在日時 を超えたら抜ける
                                if (0 < NextDataPickup.CompareTo(now))
                                {
                                    break;
                                }
                            }

                            StringBuilder sb = new StringBuilder();
                            sb.Append("kind=MON\t");
                            sb.Append($"occurdate={now:yyyyMMddHHmmss}\t");
                            sb.Append("class=1\t");
                            sb.Append("items={");
                            // [0:KM8900用識別文字列]は除いて回す
                            for (int i = 1; i < monDatas.Length; i++)
                            {
                                switch (i)
                                {
                                    case 21: sb.Append($"\"Z{i}2\":\"{monDatas[i]}\","); break; // その他情報自己診断番号 は Hex文字列
                                    default: sb.Append($"\"Z{i}2\":{decimal.Parse(monDatas[i])},"); break;
                                }
                            }

                            AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString().TrimEnd(',') + "}");

                            if (isTreatStart)
                            {
                                UploadTreatingFileByRest(false);
                            }

                            if (isTreatEnd)
                            {
                                UploadTreatingFileByRest(true);

                                BptxtFileName = "";
                                NextDataPickup = DateTime.MinValue;
                            }
                        }
                    }
                    // </>

                    // <> DGVの更新
                    for (int i = 0; i < MyDataTable.Rows.Count; i++)
                    {
                        UpdateMyDataTable(i, ""); // 一旦空にする
                        UpdateMyDataTable(i, MonDataFuncs.ExchangeDispString(i, monDatas[i]));
                    }
                    // </>

                    IsLastDispWrongCmd = false;
                }
                else
                {
                    // 前回と同一の電文で誤電文だった場合には[受信]→[誤電文]に書き換える
                    if (IsLastDispWrongCmd)
                    {
                        SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 誤電文");
                    }
                }
            }
            catch (Exception ex)
            {
                SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 誤電文");
                IsLastDispWrongCmd = true;

                MyLog.AddLogInfo(this, "", ex);
            }
        }
    }
}

