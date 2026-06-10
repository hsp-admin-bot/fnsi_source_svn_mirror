using System;
using System.Collections.Generic;
using System.Text;
using System.Windows.Forms;
using System.Net.Sockets;
using System.Threading;
using System.Diagnostics;
using System.IO;
using NKK.FN3.Common.Library.TcpSocket;
using NKK.FN3.ComServer.Library;
using System.Linq;
using System.Data;
using System.Drawing;
using System.Reflection;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    public partial class FrmSigma : FrmMonitoring
    {
        /// <summary>
        /// クライアントソケット
        /// </summary>
        private BaseClientConnect MyClientConnect = new BaseClientConnect();

        /// <summary>
        /// 通信スレッド
        /// </summary>
        private Thread ThreComm;

        /// <summary>
        /// 通信スレッドループの継続フラグ
        /// </summary>
        private bool KeepThreComm;

        /// <summary>
        /// 送信許可フラグ
        /// </summary>
        private bool IsAllowSend;

        /// <summary>
        /// データ要求信号送信日時
        /// </summary>
        DateTime RequestDt = DateTime.MinValue;

        /// <summary>
        /// ID文字列([t～z]はVer2.0時点では未定義だが今後に備えて拡張しておく)
        /// </summary>
        private const string TARGET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz";

        /// <summary>
        /// コンストラクタ(VSデザイナで必要)
        /// </summary>
        public FrmSigma()
        {
            InitializeComponent();
        }

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="argParams">呼び出し元が渡すパラメータ(※予定選択で得られるタプルの形)</param>
        /// <param name="argPortNo">接続先通信ポート番号</param>
        /// <param name="argDataFileNamePrefix">bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)</param>
        /// <param name="argRemoteIpAddr">接続先装置のIPアドレス</param>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public FrmSigma((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix, string argRemoteIpAddr)
        public FrmSigma((long ordNo, string kurName, string bedName, string patName,string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix, string argRemoteIpAddr)
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
           : base(argParams, argPortNo, argDataFileNamePrefix)
        {
            InitializeComponent();

            DeviceInformation[] devInfos;
            devInfos = new DeviceInformation[1];
            devInfos[0] = new DeviceInformation(argRemoteIpAddr, PortNo, "", "");
            MyClientConnect.InitializeDeviceInformation(devInfos);

            DialysisCom = new DialysisComNkk(OnCommandRecv, null);

            MyLog.AddLogInfo(this, "ACH-Σモニタリング画面 開始");

            FormTitle = "モニタリング(ACH-Σ)";

            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        private void FrmSigma_Load(object sender, EventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                MyClientConnect.ConnectHandler = MyConnect;
                MyClientConnect.StartConnect();

                // コマンド送信ループを実施するスレッドを生成
                KeepThreComm = true;
                ThreComm = new Thread(new ThreadStart(ThreadFunc));
                ThreComm.IsBackground = true;
                ThreComm.Start();

                SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), "接続試行中");
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        private void FrmSigma_FormClosed(object sender, FormClosedEventArgs e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name);

            try
            {
                KeepThreComm = false;
                Thread.Sleep(250); // チョイ待ちで通信スレッドループ終了を待つ

                bool doOnce = true;
                while (ThreComm.IsAlive)
                {
                    if (true == doOnce)
                    {
                        ThreComm.Abort();
                        doOnce = false;
                    }

                    Thread.Yield();
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
            finally
            {
                MyClientConnect.EndConnect();
                MyClientConnect.ReleaseDeviceInformation();
                MyClientConnect = null;
            }
        }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableの全行登録
        /// </summary>
        protected override void AddRowsToMyDataTable()
        {
            AddOneRowToMyDataTable("治療モード", "");
            AddOneRowToMyDataTable("工程状態", "");
            AddOneRowToMyDataTable("除水速度", "mL/h");
            AddOneRowToMyDataTable("血液流量", "mL/min");
            AddOneRowToMyDataTable("シリンジ流量", "mL/h");
            AddOneRowToMyDataTable("ろ過流量", "mL/h");
            AddOneRowToMyDataTable("透析液/ドレン流量", "mL/h");
            AddOneRowToMyDataTable("補液流量", "mL/h");
            AddOneRowToMyDataTable("透析液加温器温度", "℃");
            AddOneRowToMyDataTable("補液加温器温度", "℃");
            AddOneRowToMyDataTable("現在除水量", "L");
            AddOneRowToMyDataTable("現在血液循環量", "L");
            AddOneRowToMyDataTable("現在ろ過量", "L");
            AddOneRowToMyDataTable("現在透析液/ドレン量", "L");
            AddOneRowToMyDataTable("現在補液量", "L");
            AddOneRowToMyDataTable("治療時間", "min");
            AddOneRowToMyDataTable("シリンジ積算量", "mL");
            AddOneRowToMyDataTable("目標除水量", "L");
            AddOneRowToMyDataTable("目標血液循環量", "L");
            AddOneRowToMyDataTable("目標ろ過量", "L");
            AddOneRowToMyDataTable("目標透析液/ドレン量", "L");
            AddOneRowToMyDataTable("目標補液量", "L");
            AddOneRowToMyDataTable("目標治療時間", "min");
            AddOneRowToMyDataTable("脱血圧", "mmHg");
            AddOneRowToMyDataTable("入口圧", "mmHg");
            AddOneRowToMyDataTable("静脈圧", "mmHg");
            AddOneRowToMyDataTable("ろ過圧", "mmHg");
            AddOneRowToMyDataTable("排気圧/2次膜圧", "mmHg");
            AddOneRowToMyDataTable("TMP/TMP1", "mmHg");
            AddOneRowToMyDataTable("TMP2", "mmHg");
            AddOneRowToMyDataTable("差圧", "mmHg");
            AddOneRowToMyDataTable("気泡検知警報", "");
            AddOneRowToMyDataTable("漏血警報", "");
            AddOneRowToMyDataTable("加温器警報", "");
            AddOneRowToMyDataTable("脱血圧警報", "");
            AddOneRowToMyDataTable("入口圧警報", "");
            AddOneRowToMyDataTable("静脈圧警報", "");
            AddOneRowToMyDataTable("ろ過圧警報", "");
            AddOneRowToMyDataTable("排気圧/2次膜圧警報", "");
            AddOneRowToMyDataTable("TMP警報", "");
            AddOneRowToMyDataTable("TMP2警報", "");
            AddOneRowToMyDataTable("差圧警報", "");
            AddOneRowToMyDataTable("その他警報", "");
            AddOneRowToMyDataTable("クエン酸流量", "mL/min");
            AddOneRowToMyDataTable("現在クエン酸量", "mL");
        }

        /// <summary>
        /// クライアント接続確立コールバック関数
        /// </summary>
        /// <param name="sock"></param>
        /// <param name="eHandler"></param>
        /// <param name="devInf"></param>
        /// <returns></returns>
        protected ComSocket MyConnect(TcpClient sock, dgtOnException_Mng eHandler, DeviceInformation devInf)
        {
            try
            {
                MySock = new ComSocket(sock, eHandler, devInf);
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[Connected:{devInf.DevInfoStr}]");

                MySock.ReceiveCycle = 100;
                MySock.ReceiveHandler = OnRecv;
                MySock.ExceptionHandler = MySocketException;
                IsAllowSend = true;

                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 接続");
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }

            return MySock;
        }

        /// <summary>
        /// BaseSocket例外発生時イベントハンドラ
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void MySocketException(BaseSocket sender, Exception e)
        {
            MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + $"[DisConnected:{sender.DevInfo.DevInfoStr}]");

            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(255, 102, 204), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 切断");

                sender.Release();
                sender = null;
                MySock = null;
                IsAllowSend = false;
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// コマンド送信ループ
        /// </summary>
        private void ThreadFunc()
        {
            try
            {
                RequestDt = DateTime.MinValue;
                const double REQUEST_CYCLE = 2;
                byte[] sendCommand = new byte[3] { 0x4B, 0x0D, 0x0A };

                while (KeepThreComm)
                {
                    Thread.Yield();

                    // ソケットが構築 & 送信許可フラグがON & 前回受信から定間隔が経過
                    if ((null != MySock) && IsAllowSend && ((DateTime.Now - RequestDt) > TimeSpan.FromSeconds(REQUEST_CYCLE)))
                    {
                        RequestDt = DateTime.Now;
                        MySock.SendData(sendCommand, 3);
                    }
                }
            }
            catch (ThreadAbortException)
            {
                ; // 何もしない(終了時に発生するかもしれない例外)
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
            finally
            {

                if (null != MySock)
                {
                    MySock.Release();
                }
            }
        }

        /// <summary>
        /// [一電文]の受信時の処理
        /// </summary>
        /// <param name="data">受信データ内の[STX:"K2"]と[ETX:CRLF]に挟まれた[一電文](※STX,ETX抜き)</param>
        /// <param name="size">dataの有効バイト数</param>
        private void OnCommandRecv(byte[] data, int size)
        {
            try
            {
                SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 受信");

                byte[] bytes = new byte[3];
                Buffer.BlockCopy(data, 2, bytes, 0, 3);
                int len = int.Parse(Encoding.GetEncoding("Shift_JIS").GetString(bytes));

                int count = len + 5;
                bytes = new byte[count];
                Buffer.BlockCopy(data, 0, bytes, 0, count);
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

                    // モニタデータを分割してコレクションに格納する
                    Dictionary<string, string> monData = CreateDataDictionary(receivedData.Substring(5));

                    // <> 臨床工程変更 と 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名変更
                    string currentProcStatus = monData["B"];

                    // 臨床工程が[不定]から[治療中] (※ [1:治療] を受け取った)
                    if (null == PrevStatus && "1" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療中～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, monData["P"]);
                    }
                    // 臨床工程が[不定]から[治療外] (※ [1:治療]以外 を受け取った)
                    else if (null == PrevStatus && "1" != currentProcStatus)
                    {
                        BptxtFileName = "";

                        PrevStatus = "0";
                    }
                    // 臨床工程が[治療外]から[治療中] (※ [1:治療] を受け取った)
                    else if (null != PrevStatus && "0" == PrevStatus && "1" == currentProcStatus)
                    {
                        BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                        PrevStatus = "1";
                        isWrite = true;

                        isTreatStart = true;
                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                    }
                    // 臨床工程が[治療中]から[治療外] (※ [1:治療]と[2:治療停止]以外 を受け取った)
                    else if (null != PrevStatus && "1" == PrevStatus && !("1" == currentProcStatus || "2" == currentProcStatus))
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
                            foreach (string id in monData.Keys.ToList())
                            {
                                char idChar = id.ToCharArray()[0];
                                int pos = 0;

                                if ('A' <= idChar && idChar <= 'Z')
                                {
                                    pos = idChar - 65 + 1; // A は 10進で65、[1～26]まで割り振り
                                }
                                else if ('a' <= idChar && idChar <= 'z')
                                {
                                    pos = idChar - 97 + 27; // a は 10進で97、[A～Z：1～26]の続きで[27～52]まで割り振り
                                }
                                else
                                {
                                    pos = -1;
                                }

                                if (-1 != pos)
                                {
                                    sb.Append($"\"Z{pos}1\":{decimal.Parse(monData[id])},");
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

                        string key = TARGET.Substring(i, 1); // RoxIndex[0]～ を A～ へ紐づけ
                        if (true == monData.ContainsKey(key))
                        {
                            string value = monData[key];
                            switch (key)
                            {
                                case "A": // 治療モード
                                    switch (value)
                                    {
                                        case "00": value = "SCUF"; break;
                                        case "01": value = "CHF 前希釈"; break;
                                        case "02": value = "CHF 後希釈"; break;
                                        case "03": value = "CHD"; break;
                                        case "04": value = "CHDF 前希釈"; break;
                                        case "05": value = "CHDF 後希釈"; break;
                                        case "06": value = "PE"; break;
                                        case "07": value = "PA プラソーバ"; break;
                                        case "08": value = "PA イムソーバ"; break;
                                        case "09": value = "DFPP 補液無し"; break;
                                        case "10": value = "DFPP 補液有り"; break;
                                        case "11": value = "HA"; break;
                                        case "12": value = "LCAP"; break;
                                        case "13": value = "(腹水)"; break;
                                    }
                                    break;
                                case "B": // 工程状態
                                    switch (value)
                                    {
                                        case "1": value = "治療"; break;
                                        case "2": value = "治療停止"; break;
                                        case "3": value = "回収"; break;
                                        case "4": value = "回収 破棄"; break;
                                        case "5": value = "準備"; break;
                                        case "6": value = "点検"; break;
                                        case "9": value = "その他"; break;
                                    }
                                    break;
                            }

                            UpdateMyDataTable(i, value);
                        }
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
        /// 受信イベントの処理
        /// </summary>
        /// <param name="sender">データを受信したBaseSocketインスタンス</param>
        protected override void ProcReceivedData(BaseSocket sender)
        {
            DialysisCom.OnRecvJmed(sender);
        }

        /// <summary>
        /// データ受信時コールバック関数
        /// </summary>
        /// <param name="sender">データを受信したBaseSocketインスタンス</param>
        protected override void OnRecv(BaseSocket sender)
        {
            try
            {
                // データ要求信号送信日時に現在時刻を入れる
                // 最後に受信してから一定時間経過後にデータ要求信号を出したいため
                RequestDt = DateTime.Now;

                base.OnRecv(sender);
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "", ex);
            }
        }

        /// <summary>
        /// ID+DATAのコレクションを返します
        /// </summary>
        /// <param name="monData">ACH-Σのモニタデータ</param>
        /// <returns>ID+DATAのコレクション</returns>
        private Dictionary<string, string> CreateDataDictionary(string monData)
        {
            char[] anyOf = TARGET.ToCharArray();

            // 受信データを分解したID+DATAのコレクション
            Dictionary<string, string> dataDictionary = new Dictionary<string, string>();

            // A～Z, a～zを検索
            int at = monData.IndexOfAny(anyOf, 0);

            if (0 <= at)
            {
                int startIndex = 0;
                int startIndexPrev = 0;

                // IDが検索できた
                int i = 0;
                string[] datas = new string[monData.Length];
                do
                {
                    // ID開始位置
                    startIndexPrev = at;

                    // 次のID検索開始位置
                    startIndex = at + 1;

                    // A～Z, a～zを検索
                    at = monData.IndexOfAny(anyOf, startIndex);
                    if (0 <= at)
                    {
                        datas[i] = monData.Substring(startIndexPrev, at - startIndexPrev);
                        dataDictionary.Add(datas[i].Substring(0, 1), datas[i].Substring(1));

                        i++;
                    }
                } while (0 <= at);

                // 最後の項目を追加
                datas[i] = monData.Substring(startIndexPrev);
                dataDictionary.Add(datas[i].Substring(0, 1), datas[i].Substring(1));
            }

            return dataDictionary;
        }
    }
}

