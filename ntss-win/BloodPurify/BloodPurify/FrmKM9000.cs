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
    public partial class FrmKM9000 : FrmMonitoring
    {
        /// <summary>
        /// サーバー接続
        /// </summary>
        private BaseServerConnect Server = new BaseServerConnect();

        /// <summary>
        /// KM9000のモニタデータ処理機能
        /// </summary>
        private IKM MonDataFuncs;

        /// <summary>
        /// コンストラクタ(VSデザイナで必要)
        /// </summary>
        public FrmKM9000()
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
        //public FrmKM9000((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix, IKM argMonDataFuncs)
        public FrmKM9000((long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix, IKM argMonDataFuncs)
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
            : base(argParams, argPortNo, argDataFileNamePrefix)
        {
            InitializeComponent();

            DialysisCom = new DialysisComKM(OnCommandRecv);

            // 実装オブジェクトの参照をパラメータとして受け取る
            MonDataFuncs = argMonDataFuncs;

            //LogWriter.WriteLog(LogLevel.Debug, "0316000029", "KM-9000モニタリング画面 開始[装置index:]");

            FormTitle = "モニタリング(KM-9000)";

            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        private void FrmKM9000_Load(object sender, EventArgs e)
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

        private void FrmKM9000_FormClosed(object sender, FormClosedEventArgs e)
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
            AddOneRowToMyDataTable("装置名", "");
            AddOneRowToMyDataTable("測定値TMP圧", "mmHg");
            AddOneRowToMyDataTable("測定値入口圧", "mmHg");
            AddOneRowToMyDataTable("測定値返血圧", "mmHg");
            AddOneRowToMyDataTable("測定値ろ過圧", "mmHg");
            AddOneRowToMyDataTable("測定値浄化器圧", "mmHg");
            AddOneRowToMyDataTable("設定値TMP圧", "mmHg");
            AddOneRowToMyDataTable("設定値入口圧", "mmHg");
            AddOneRowToMyDataTable("設定値返血圧・上限", "mmHg");
            AddOneRowToMyDataTable("設定値返血圧・下限", "mmHg");
            AddOneRowToMyDataTable("設定値浄化器圧", "mmHg");
            AddOneRowToMyDataTable("設定値除水設定値", "L/時");
            AddOneRowToMyDataTable("流量情報血液ﾎﾟﾝﾌﾟ指令流量", "mL/分");
            AddOneRowToMyDataTable("流量情報透析液ﾎﾟﾝﾌﾟ指令流量", "mL/分");
            AddOneRowToMyDataTable("流量情報補充液ﾎﾟﾝﾌﾟ指令流量", "mL/分");
            AddOneRowToMyDataTable("流量情報ろ液ﾎﾟﾝﾌﾟ指令流量", "mL/分");
            AddOneRowToMyDataTable("流量情報血液ﾎﾟﾝﾌﾟ積算流量", "L");
            AddOneRowToMyDataTable("流量情報透析液ﾎﾟﾝﾌﾟ積算流量", "L");
            AddOneRowToMyDataTable("流量情報補充液ﾎﾟﾝﾌﾟ積算流量", "L");
            AddOneRowToMyDataTable("流量情報除水積算流量", "L");
            AddOneRowToMyDataTable("その他情報加温器温度", "℃");
            AddOneRowToMyDataTable("その他情報除水差分/重量値", "ｇ");
            AddOneRowToMyDataTable("その他情報初期診断情報", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報1", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報2", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報3", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報4", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報5", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報6", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報7", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報8", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報9", "");
            AddOneRowToMyDataTable("その他情報ｱﾗｰﾑ情報10", "");
            AddOneRowToMyDataTable("その他情報注意情報", "");
            AddOneRowToMyDataTable("経過時間", "日、時、分");
            AddOneRowToMyDataTable("その他情報用途", "");
            AddOneRowToMyDataTable("その他情報工程", "");
            AddOneRowToMyDataTable("その他情報動作日、時間", "年月日－時間");
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
        private void OnCommandRecv(BaseSocket sender, byte[] data, int size, string strlogfile)
        {
            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 受信");

                const int processColumnNo = 37;

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

                    // 臨床工程が[不定]から[治療中] (※ [4:臨床] を受け取った)
                    if (null == PrevStatus && "4" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療中～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, $"{DDColonHHColonMMToMinutes(monDatas[34])}");
                    }
                    // 臨床工程が[不定]から[治療外] (※ [4:臨床]以外 を受け取った)
                    else if (null == PrevStatus && "4" != currentProcStatus)
                    {
                        BptxtFileName = "";
                        PrevStatus = "0";
                    }
                    // 臨床工程が[治療外]から[治療中] (※ [4:臨床] を受け取った)
                    else if (null != PrevStatus && "0" == PrevStatus && "4" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                    }
                    // 臨床工程が[治療中]から[治療外] (※ [4:臨床]以外 を受け取った)
                    else if (null != PrevStatus && "1" == PrevStatus && "4" != currentProcStatus)
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
                            // [0:ID 装置名]は除いて回す
                            for (int i = 1; i < monDatas.Length; i++)
                            {
                                // その他情報初期診断情報/ｱﾗｰﾑ情報1～10/注意情報(Hex文字列系) または その他情報動作時間(YY/MM/DD-HH:MM)
                                if ((22 <= i && i <= 33) || 37 == i)
                                {
                                    sb.Append($"\"Z{i}4\":\"{monDatas[i]}\",");
                                }
                                else if (34 == i)
                                {
                                    sb.Append($"\"Z{i}4\":{DDColonHHColonMMToMinutes(monDatas[i])},");
                                }
                                else
                                {
                                    sb.Append($"\"Z{i}4\":{decimal.Parse(monDatas[i])},");
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

        /// <summary>
        /// [DD:HH:MM]の文字列から何分かを算出して文字列で返す
        /// </summary>
        /// <param name="argDDColonHHColonMM">[DD:HH:MM]の文字列</param>
        /// <returns>分の文字列</returns>
        private int DDColonHHColonMMToMinutes(string argDDColonHHColonMM)
        {
            int days = int.Parse(argDDColonHHColonMM.Substring(0, 2));
            int hours = int.Parse(argDDColonHHColonMM.Substring(3, 2));
            int mins = int.Parse(argDDColonHHColonMM.Substring(6, 2));
            int totalMins = (days * 24 * 60) + (hours * 60) + mins;

            return totalMins;
        }
    }
}
