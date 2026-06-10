using System;
using System.Drawing;
using System.Text;
using System.Windows.Forms;
using System.Net.Sockets;
using System.Threading;
using System.Diagnostics;
using NKK.FN3.Common.Library.TcpSocket;
using NKK.FN3.ComServer.Library;
using System.IO;
using System.Reflection;
using NKKWebAccessLib;

namespace NKK.BloodPurify
{
    public partial class FrmIQ21 : FrmMonitoring
    {
        /// <summary>
        /// サーバー接続
        /// </summary>
        private BaseServerConnect Server = new BaseServerConnect();

        /// <summary>
        /// プラソートiQ21用 受信データ処理機能クラス の インスタンス
        /// </summary>
        private IQ21Data IQ21Data = new IQ21Data();

        /// <summary>
        /// プラソートiQ21はFrmMonitoringにいる「受信データ処理オブジェクト」は使わないで自分専用のやつで処理
        /// </summary>
        private DialysisComIQ21 DialysisComIQ21;

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// <param name="argParams">呼び出し元が渡すパラメータ(※予定選択で得られるタプルの形)</param>
        /// <param name="argPortNo">待ち受け通信ポート番号</param>
        /// <param name="argDataFileNamePrefix">bptxt や 電文記録ファイル のプレフィックス(例.「S_2F個室201_」)</param>
        // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
        //public FrmIQ21((long ordNo, string kurName, string bedName, string patName) argParams, int argPortNo, string argDataFileNamePrefix)
         public FrmIQ21((long ordNo, string kurName, string bedName, string patName, string hospPatID, string rstTreatmentName) argParams, int argPortNo, string argDataFileNamePrefix)
          // mod 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
           : base(argParams, argPortNo, argDataFileNamePrefix)
        {
            InitializeComponent();

            DialysisComIQ21 = new DialysisComIQ21(OnCommandRecv);

            SetDgvVisible(false);

            //LogWriter.WriteLog(LogLevel.Debug, "0316000030", "iQ21モニタリング画面 開始[装置index:]");

            FormTitle = "モニタリング(プラソートiQ21)";

            NKKWebAccess.GetInstance().SendMessageToGUIHandler += new ToGUILib.ToGUI.dgtSendMessageToGUI(HandleAccessMessage);
        }

        private void FrmIQ21_Load(object sender, EventArgs e)
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

        private void FrmIQ21_FormClosed(object sender, FormClosedEventArgs e)
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

        private void LstBox_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Escape)
            {
                MyLog.AddLogInfo(this, MethodBase.GetCurrentMethod().Name + "[Esc]");
                Close();
            }
        }

        /// <summary>
        /// DGVに表示する内容を保持しているDataTableの全行登録
        /// </summary>
        protected override void AddRowsToMyDataTable()
        {
            ; // プラソートiQ21ではDGVを使用しないため何もしない
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
            DialysisComIQ21.OnRecv(sender);
        }

        /// <summary>
        /// データ受信時コールバック関数
        /// </summary>
        /// <param name="sender">データを受信したBaseSocketインスタンス</param>
        protected override void OnRecv(BaseSocket sender)
        {
            try
            {
                if (OnRecv_Process == true)
                {
                    return;
                }

                OnRecv_Process = true;
                try
                {
                    lock (DialysisComIQ21)
                    {
                        ProcReceivedData(sender);
                    }
                }
                catch (Exception ex)
                {
                    MyLog.AddLogInfo(this, "受信時処理例外 ProcReceivedData", ex);
                }
                finally
                {
                    OnRecv_Process = false;
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "受信時処理例外 OnRecv", ex);
            }
        }

        /// <summary>
        /// [一電文]の受信時の処理
        /// </summary>
        /// <param name="data">受信データ</param>
        /// <param name="size">dataの有効バイト数</param>
        private void OnCommandRecv(byte[] data, int size)
        {
            // メモ：[装置→APPで<ENQ(0x05)>]⇒[装置←APPで<0x20>]⇒[装置→APPで<初期データ>]⇒[装置→APPで<各種データ>]
            // のハンドシェイクが有るが、より上位側に実装してある

            // ENQ(0x05)？？？
            if (size == 1)
            {
                return;
            }
            // 初期データ(※電文記録ファイルへの出力対象ではない)
            else if (data[0] == 0x18 && data[1] == 0x20 && data[2] == 0x1B)
            {
                DispFirstData(data, size);
            }
            // データ(定時詳細1/定時詳細2/定時詳細3/操作詳細/警報詳細)
            else
            {
                try
                {
                    SetDevLampColorAndStatusText(Color.FromArgb(0, 176, 80), $"{DateTime.Now:yyyy/MM/dd HH:mm:ss} 受信");

                    int escPos = Array.IndexOf<byte>(data, 0x1B);
                    if (escPos > 0)
                    {
                        DateTime now = DateTime.Now;
                        bool isMoniData = false;
                        bool isTreatStart = false;
                        bool isTreatEnd = false;
                        string[] monAndOtherDatas;

                        // はじめのESCの前が0x0Aならば モニタデータ(定時詳細1/定時詳細2/定時詳細3)
                        if (data[escPos - 1] == 0x0A)
                        {
                            string monitorData = DispAndGetMonitorData(data, size);
                            monAndOtherDatas = MakeStringMonitorData(monitorData);

                            isMoniData = true;

                            // <> 臨床工程変更 と 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名変更
                            // 臨床工程が[不定]から[治療中] (※定時詳細は治療中になった後でしか飛んでこないので[治療途中])
                            if (null == PrevStatus)
                            {
                                BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療中～.bptxt";

                                PrevStatus = "1";

                                isTreatStart = true;
                                CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, monAndOtherDatas[IQ21Cmn.ELAPSED_TIME]);
                            }
                            // 臨床工程が[治療外]から[治療中] (※定時詳細は治療中になった後でしか飛んでこないので[治療途中])
                            else if (null != PrevStatus && "0" == PrevStatus)
                            {
                                BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療中～.bptxt";

                                PrevStatus = "1";

                                isTreatStart = true;
                                CalcAndWriteStartDateTimeFromRecvElapseMinutes(now, monAndOtherDatas[IQ21Cmn.ELAPSED_TIME]);
                            }
                            // </>
                        }
                        // はじめのESCの前がそれ以外（具体的には"分"）だったら 操作詳細/警報詳細
                        else
                        {
                            string[] controlDatas = DispAndGetOtherData(data, size);
                            monAndOtherDatas = MakeStringControlData(controlDatas);

                            string controlDetail = "";
                            if (true == monAndOtherDatas[IQ21Cmn.TITLE].StartsWith("［操作］"))
                            {
                                controlDetail = monAndOtherDatas[IQ21Cmn.CONTROL1];
                            }

                            // <> 臨床工程変更 と 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名変更
                            // 臨床工程が[不定]から[治療中]へ (※ [操作]治療 の受信は[治療開始]を示す)
                            if (null == PrevStatus && "治療" == controlDetail)
                            {
                                BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                                PrevStatus = "1";

                                isTreatStart = true;
                                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                            }
                            // 臨床工程が[治療外]から[治療中] (※ [操作]治療 の受信は[治療開始]を示す)
                            else if (null != PrevStatus && "0" == PrevStatus && "治療" == controlDetail)
                            {
                                BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";

                                PrevStatus = "1";

                                isTreatStart = true;
                                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                            }
                            // 臨床工程が[治療中]から[治療中] (※ [操作]治療 の受信は[治療開始]を示し、[治療中]の受信は新しい治療に切り替わったことを示す)
                            else if (null != PrevStatus && "1" == PrevStatus && "治療" == controlDetail)
                            {
                                // 元ファイルは治療終了として上げて消す
                                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=END\toccurdate={now:yyyyMMddHHmmss}");
                                UploadTreatingFileByRest(true);

                                // 改めて新規に治療開始
                                BptxtFileName = $"{DataFilenamePrefix}{now:yyyyMMdd-HHmmss}治療開始～.bptxt";
                                PrevStatus = "1";

                                isTreatStart = true;
                                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=START\toccurdate={now:yyyyMMddHHmmss}");
                            }
                            // 臨床工程が[治療中]から[治療外] (※ [操作]回収 の受信は[治療終了]を示す)
                            else if (null != PrevStatus && "1" == PrevStatus && "回収" == controlDetail)
                            {
                                // 「治療データファイル(アップロードデータのみを収集するファイル)」のファイル名を＜ファイル名末尾に「YYYYMMDD-HHMMSS治療終了」がついた名前＞にリネーム
                                string srcPath = $"{MyConfig.DataDir}\\{BptxtFileName}";
                                BptxtFileName = $"{Path.GetFileNameWithoutExtension(BptxtFileName)}{now:yyyyMMdd-HHmmss}治療終了.bptxt";
                                AppCmn.MoveWithMutex(srcPath, $"{MyConfig.DataDir}\\{BptxtFileName}");

                                PrevStatus = "0";

                                isTreatEnd = true;
                                AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", $"kind=END\toccurdate={now:yyyyMMddHHmmss}");
                            }
                            // </>
                        }

                        // <> 各種ファイル書き出し処理
                        string receivedData = string.Join(",", monAndOtherDatas);

                        // 電文記録ファイル
                        CommDataWriter(receivedData, now);

                        if (isMoniData)
                        {
                            if (false == receivedData.Equals(ReceivedDataOld))
                            {
                                ReceivedDataOld = receivedData;

                                // 治療データファイル(アップロードデータのみを収集するファイル)
                                if (false == string.IsNullOrWhiteSpace(BptxtFileName))
                                {
                                    // [現在日時 が 書き込み予定日時 以上]の場合は書く
                                    if (0 <= now.CompareTo(NextDataPickup))
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
                                        // 治療経過時間
                                        sb.Append($"\"Z13\":{monAndOtherDatas[IQ21Cmn.ELAPSED_TIME]},");
                                        // 治療経過時間以外のモニタデータの固まり部分
                                        int numOfMonData = IQ21Cmn.MONI_END - IQ21Cmn.MONI_START;
                                        for (int i = 0; i <= numOfMonData; i++)
                                        {
                                            string oneMonData = monAndOtherDatas[IQ21Cmn.MONI_START + i];
                                            if (false == string.IsNullOrWhiteSpace(oneMonData))
                                            {
                                                sb.Append($"\"Z{i + 2}3\":{oneMonData},");
                                            }
                                        }

                                        AccessorBptxtFile.Write($"{MyConfig.DataDir}\\{BptxtFileName}", sb.ToString().TrimEnd(',') + "}");
                                    }
                                }

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
                        else
                        {
                            ReceivedDataOld = receivedData;
                            IsLastDispWrongCmd = false;
                        }

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
                        // </>
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

        /// <summary>
        /// 初期データを画面に表示
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private void DispFirstData(byte[] data, int size)
        {
            int startIndex = 3;
            int pos = Array.IndexOf<byte>(data, 0x1B, startIndex);
            int count = pos - startIndex;
            string str = "";

            // 0x0Aの直前までコピー
            if (count >= 0)
            {
                byte[] bytes = new byte[count];
                Buffer.BlockCopy(data, startIndex, bytes, 0, count);
                str = IQ21Data.EncodingByteJIS(bytes, false);
            }

            BeginInvokeAddLstBox("初期データ受信：" + str);
        }

        /// <summary>
        /// モニタデータ(定時詳細1/定時詳細2/定時詳細3)を画面に表示＋モニタデータを解析して文字列化したものを取得
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private string DispAndGetMonitorData(byte[] data, int size)
        {
            ////
            // (0x0A)
            // 月/日 時:分 (時間:分)(0x0A)
            // (0x1B)(0x4B)タイトル(0x1B)(0x48)タイトル(0x0A)
            // (0x1B)(0x4B)タイトル(0x1B)(0x48)値(0x0A)
            // (0x1B)(0x4B)タイトル(0x1B)(0x48)値(0x0A)
            // (0x1B)(0x4B)タイトル(0x1B)(0x48)(0x0A)
            // (0x1B)(0x4B)タイトル(0x1B)(0x48)値(0x1B)(0x4A)(0x0A)
            ////

            int pos = 0;
            int startIndex = 0;
            byte[] bytes;
            int count = 0;
            StringBuilder sb = new StringBuilder();

            pos = Array.IndexOf<byte>(data, 0x0A, startIndex);
            if (pos == 0)
            {
                // 1文字目に0Aが来ていたら１文字スキップする
                startIndex = 1;
            }

            pos = 0;
            while (startIndex < size)
            {
                pos = Array.IndexOf<byte>(data, 0x0A, startIndex);

                // 0x0Aの直前までコピー
                count = pos - startIndex;
                if (count >= 0)
                {
                    bytes = new byte[count];
                    Buffer.BlockCopy(data, startIndex, bytes, 0, count);

                    if (startIndex == 1)
                    {
                        // 最初の行＝時間
                        sb.Append(IQ21Data.EncodingByteJIS(bytes, false) + "\n");
                    }
                    else
                    {
                        // それ以外の行＝タイトル＋データ
                        sb.Append(ParseMonitorData(bytes, count) + "\n");
                    }
                }

                startIndex = pos + 1;
            }

            BeginInvokeChangeLblMonitorText(sb.ToString());

            return sb.ToString();
        }

        /// <summary>
        /// モニタデータを解析して文字列化する
        /// (0x1B)(0x4B)タイトル(0x1B)(0x48)値 or タイトル or 空欄
        /// または
        /// (0x1B)(0x4B)タイトル(0x1B)(0x48)値(0x1B)(0x4A)
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private string ParseMonitorData(byte[] data, int size)
        {
            int pos = 0;
            byte[] bytes;
            int count = 0;
            // (0x1B)(0x4B)除去
            int startIndex = 2;
            string ret;

            try
            {
                if (size - startIndex < 0)
                {
                    MyLog.AddLogInfo(this, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                        MethodBase.GetCurrentMethod().Name + "[受信データ解析エラー(size - startIndex < 0):" + IQ21Data.BytesToString(data) + "]");
                    return "データ解析エラー";
                }
                pos = Array.IndexOf<byte>(data, 0x1B, startIndex);

                if (pos - startIndex >= 0)
                {
                    // 0x1Bの直前までコピー
                    count = pos - startIndex;
                    bytes = new byte[count];
                    Buffer.BlockCopy(data, startIndex, bytes, 0, count);

                    ret = IQ21Data.EncodingByteJIS(bytes, true); // タイトル

                    startIndex = pos + 2;   // (0x1B)(0x48)除去

                    if (size - startIndex >= 0)
                    {
                        // ２つめの0x1B
                        pos = Array.IndexOf<byte>(data, 0x1B, startIndex);
                        if (pos < 0)
                        {
                            // ２つめの0x1Bがあるのは最終行のみなので、ほかでは = size 
                            pos = size;
                        }

                        count = pos - startIndex;
                    }
                    else
                    {
                        MyLog.AddLogInfo(this, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                            MethodBase.GetCurrentMethod().Name + "[受信データ解析エラー(size - startIndex >= 0でない):" + IQ21Data.BytesToString(data) + "]");
                        return " データ解析エラー";
                    }

                    // 直前までコピー
                    bytes = new byte[count];
                    Buffer.BlockCopy(data, startIndex, bytes, 0, count);

                    ret += IQ21Data.EncodingByteJIS(bytes, false); // 半角タイトル or 値
                }
                else
                {
                    MyLog.AddLogInfo(this, NKKLoggingLib.NKKLogging.LOGGING_CLASS.ERROR,
                        MethodBase.GetCurrentMethod().Name +"[受信データ解析エラー(pos - startIndex >= 0でない):" + IQ21Data.BytesToString(data) + "]");
                    return " データ解析エラー";
                }
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "受信データ解析エラー:" + IQ21Data.BytesToString(data), ex);
                return "データ解析エラー";
            }

            return ret;
        }

        /// <summary>
        /// 操作・警報データ(操作詳細/警報詳細)を画面に表示＋操作・警報データを解析して文字列分解したものを取得
        /// </summary>
        /// <param name="data"></param>
        /// <param name="size"></param>
        private string[] DispAndGetOtherData(byte[] data, int size)
        {
            ////
            // 月/日 時:分(0x1B)(0x4B)[タイトル２文字]内容(0x1B)(0x48)設定内容(0x1B)(0x4A)(0x0A)
            ////

            int startIndex = 0;

            int pos = 0;
            byte[] bytes;
            string receivedData = "";
            string settingParam1 = "";
            string settingParam2 = "";
            string settingParam3 = "";
            string settingParam4 = "";
            string title = "";
            string time = "";
            int count = 0;
            int i = 0;
            string str = "";
            string[] settingDatas;

            pos = Array.IndexOf<byte>(data, 0x0A, startIndex);
            if (pos == 0)
            {
                // 1文字目に0Aが来ていたら１文字スキップする
                startIndex = 1;
            }

            pos = 0;
            try
            {
                while ((startIndex < size) && (0 <= pos))
                {
                    pos = Array.IndexOf<byte>(data, 0x1B, startIndex);

                    // 1電文の長さ ← 終端文字位置 
                    count = pos - startIndex;
                    if (count >= 0)
                    {
                        // ESCの直前までコピー
                        bytes = new byte[count];
                        Buffer.BlockCopy(data, startIndex, bytes, 0, count);

                        // ESC + エスケープシーケンス　の次
                        startIndex = pos + 2;

                        switch (i)
                        {
                            case 0:
                                // ESCまでが発生日付データ
                                // 時間表示更新

                                receivedData = IQ21Data.EncodingByteJIS(bytes, false);

                                Debug.Write(receivedData);
                                time = receivedData;
                                break;
                            case 1:
                                //タイトルと操作結果

                                receivedData = IQ21Data.EncodingByteJIS(bytes, true);

                                Debug.Write(receivedData);
                                if (receivedData.Length >= 4)
                                {
                                    title = receivedData.Substring(0, 4);
                                    settingParam1 = receivedData.Substring(4);
                                }
                                else
                                {
                                    title = receivedData;
                                    settingParam1 = "";
                                }
                                break;
                            case 2:
                                // 設定流量
                                if (title.IndexOf("設定") >= 0)
                                {
                                    receivedData = IQ21Data.EncodingByteJIS(bytes, false);

                                    Debug.Write(receivedData);
                                    int posision = receivedData.IndexOf('(');
                                    if (posision >= 0)
                                    {
                                        settingParam3 = receivedData.Substring(0, posision);
                                        settingParam4 = receivedData.Substring(posision);

                                    }
                                }
                                else if (title.IndexOf("操作") >= 0)
                                {
                                    if (settingParam1.IndexOf("治療　　") >= 0)
                                    {
                                        settingParam2 = settingParam1.Substring(4);
                                        settingParam1 = "治療";
                                    }
                                }
                                break;
                        }

                        i += 1;
                    }
                }

                // 設定内容など
                str = time + title + settingParam1 + settingParam2 + settingParam3 + settingParam4;

                BeginInvokeAddLstBox(str);
                settingDatas = new string[] { time, title, settingParam1, settingParam2, settingParam3, settingParam4 };
            }
            catch (Exception ex)
            {
                MyLog.AddLogInfo(this, "受信データ解析エラー:" + IQ21Data.BytesToString(data), ex);
                BeginInvokeAddLstBox("データ解析エラー");
                settingDatas = new string[] { };
            }

            return settingDatas;
        }

        /// <summary>
        /// モニタデータを","分割
        /// </summary>
        /// <param name="MonitorData"></param>
        /// <returns></returns>
        private string[] MakeStringMonitorData(string MonitorData)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];

            if (MonitorData.IndexOf("除水") >= 0)
            {
                // モード１
                datas = MakeStringMonitorDataMode1(MonitorData.Split('\n'));
            }
            else if (MonitorData.IndexOf("分離") >= 0)
            {
                // モード２
                datas = MakeStringMonitorDataMode2(MonitorData.Split('\n'));
            }
            else if (MonitorData.IndexOf("ろ過") >= 0)
            {
                // モード３ (モード１にもろ過はあるが、先に除水でキャッチされる)
                datas = MakeStringMonitorDataMode3(MonitorData.Split('\n'));
            }
            // その他の場合は解析エラーデータ

            for (int i = 0; i < datas.Length; i++)
            {
                if (datas[i] == null)
                {
                    datas[i] = string.Empty;
                }
            }

            return datas;
        }

        /// <summary>
        /// モード１
        /// </summary>
        /// <param name="MonitorData"></param>
        /// <returns></returns>
        private string[] MakeStringMonitorDataMode1(string[] MonitorData)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];

            if (MonitorData.Length > 5)
            {
                // 1行目：時間 2行目：タイトル
                datas = MakeStringsMonitorDataTitles(MonitorData[0], MonitorData[1]);
                // 3行目：流量　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[2], new int[]{
                IQ21Cmn.TITLE_LINE1,
                IQ21Cmn.RATE_WATER,
                IQ21Cmn.RATE_FILTRATION,
                IQ21Cmn.RATE_REHYDRATION,
                IQ21Cmn.RATE_DIALYSIS,
                IQ21Cmn.RATE_BLOOD,
                IQ21Cmn.RATE_SYRINGE});
                // 4行目：積算　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[3], new int[]{
                IQ21Cmn.TITLE_LINE2,
                IQ21Cmn.TOTAL_WATER,
                IQ21Cmn.TOTAL_FILTRATION,
                IQ21Cmn.TOTAL_REHYDRATION,
                IQ21Cmn.TOTAL_DIALYSIS,
                IQ21Cmn.TOTAL_BLOOD,
                IQ21Cmn.TOTAL_SYRINGE});
                // 5行目：タイトル
                datas[IQ21Cmn.TITLE_SUB] = MonitorData[4];
                // 6行目：圧力　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[5], new int[]{
                IQ21Cmn.TITLE_LINE3,
                IQ21Cmn.PRESS_BLOOD,
                IQ21Cmn.PRESS_ARTERY,
                IQ21Cmn.PRESS_VEIN,
                IQ21Cmn.PRESS_FILTRATION,
                IQ21Cmn.TMP});
            }

            return datas;
        }

        /// <summary>
        /// モード２
        /// </summary>
        /// <param name="MonitorData"></param>
        /// <returns></returns>
        private string[] MakeStringMonitorDataMode2(string[] MonitorData)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];

            if (MonitorData.Length > 5)
            {
                // 1行目：時間 2行目：タイトル
                datas = MakeStringsMonitorDataTitles(MonitorData[0], MonitorData[1]);
                // 3行目：流量　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[2], new int[]{
                IQ21Cmn.TITLE_LINE1,
                IQ21Cmn.RATE_SEPARATION,
                IQ21Cmn.RATE_PLASMA,
                IQ21Cmn.RATE_DORAIN,
                IQ21Cmn.RATE_BLOOD,
                IQ21Cmn.RATE_SYRINGE});
                // 4行目：積算　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[3], new int[]{
                IQ21Cmn.TITLE_LINE2,
                IQ21Cmn.TOTAL_SEPARATION,
                IQ21Cmn.TOTAL_PLASMA,
                IQ21Cmn.TOTAL_DORAIN,
                IQ21Cmn.TOTAL_BLOOD,
                IQ21Cmn.TOTAL_SYRINGE});
                // 5行目：タイトル
                datas[IQ21Cmn.TITLE_SUB] = MonitorData[4];
                // 6行目：圧力　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[5], new int[]{
                IQ21Cmn.TITLE_LINE3,
                IQ21Cmn.PRESS_BLOOD,
                IQ21Cmn.PRESS_ARTERY,
                IQ21Cmn.PRESS_VEIN,
                IQ21Cmn.PRESS_PLASMA,
                IQ21Cmn.TMP,
                IQ21Cmn.PRESS_PLASMA_IN});
            }

            return datas;
        }

        /// <summary>
        /// モード３
        /// </summary>
        /// <param name="MonitorData"></param>
        /// <returns></returns>
        private string[] MakeStringMonitorDataMode3(string[] MonitorData)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];

            if (MonitorData.Length > 5)
            {
                // 1行目：時間 2行目：タイトル
                datas = MakeStringsMonitorDataTitles(MonitorData[0], MonitorData[1]);
                // 3行目：流量　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[2], new int[]{
                IQ21Cmn.TITLE_LINE1,
                IQ21Cmn.RATE_FILTRATION,
                IQ21Cmn.RATE_REHYDRATION,
                IQ21Cmn.RATE_DIALYSIS,
                IQ21Cmn.RATE_BLOOD,
                IQ21Cmn.RATE_SYRINGE});
                // 4行目：積算　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[3], new int[]{
                IQ21Cmn.TITLE_LINE2,
                IQ21Cmn.TOTAL_FILTRATION,
                IQ21Cmn.TOTAL_REHYDRATION,
                IQ21Cmn.TOTAL_DIALYSIS,
                IQ21Cmn.TOTAL_BLOOD,
                IQ21Cmn.TOTAL_SYRINGE});
                // 5行目：タイトル
                datas[IQ21Cmn.TITLE_SUB] = MonitorData[4];
                // 6行目：圧力　値
                datas = MakeStringsMonitorDataLine(datas, MonitorData[5], new int[]{
                IQ21Cmn.TITLE_LINE3,
                IQ21Cmn.PRESS_BLOOD,
                IQ21Cmn.PRESS_ARTERY,
                IQ21Cmn.PRESS_VEIN,
                IQ21Cmn.PRESS_FILTRATION,
                IQ21Cmn.TMP,
                IQ21Cmn.PRESS_PLASMA_IN});
            }

            return datas;
        }

        /// <summary>
        /// モード１，２，３で１行目と２行目の処理は同じ
        /// </summary>
        /// <param name="MonitorData"></param>
        /// <returns></returns>
        private string[] MakeStringsMonitorDataTitles(string monitorTime, string monitorTitle1)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];
            int splitIndex;

            // 1行目：時間
            splitIndex = monitorTime.IndexOf('(');
            if (splitIndex >= 0)
            {
                datas[IQ21Cmn.POP_TIME] = monitorTime.Substring(0, splitIndex).Trim();
                datas[IQ21Cmn.ELAPSED_TIME] = GetTreatTime(monitorTime.Substring(splitIndex).Trim());
            }
            // 2行目：タイトル
            splitIndex = monitorTitle1.IndexOf("ｼﾘﾝｼﾞ");
            if (splitIndex >= 0)
            {
                datas[IQ21Cmn.TITLE] = monitorTitle1.Substring(0, splitIndex);
                datas[IQ21Cmn.TITLE_HALF] = monitorTitle1.Substring(splitIndex).Trim();
            }

            return datas;
        }

        /// <summary>
        /// 経過時間を返します
        /// </summary>
        /// <param name="elapsedtime">(0:00)</param>
        /// <returns></returns>
        protected string GetTreatTime(string elapsedtime)
        {
            int colonIndex = elapsedtime.IndexOf(':');
            if (colonIndex >= 1)
            {
                int elapsed_hour;
                int elapsed_min;
                if (int.TryParse(elapsedtime.Substring(1, colonIndex - 1), out elapsed_hour) == false   //([0]:00)
                || int.TryParse(elapsedtime.Substring(colonIndex + 1, 2), out elapsed_min) == false)   //(0:[00])
                {
                    return "0";   //エラー時
                }

                return (elapsed_hour * 60 + elapsed_min).ToString();
            }
            else
            {
                return "0";
            }
        }

        /// <summary>
        /// 値のある行を解析
        /// </summary>
        /// <param name="datas"></param>
        /// <param name="source"></param>
        /// <param name="index"></param>
        /// <returns></returns>
        private string[] MakeStringsMonitorDataLine(string[] datas, string source, int[] index)
        {
            int splitIndex;
            string tempMonitorData = source;
            int i = 0;

            splitIndex = tempMonitorData.IndexOf(' ');
            while (splitIndex >= 0 && index.Length > i)
            {
                datas[index[i]] = tempMonitorData.Substring(0, splitIndex);
                tempMonitorData = tempMonitorData.Substring(splitIndex).Trim();
                splitIndex = tempMonitorData.IndexOf(' ');
                i += 1;
            }
            if (index.Length > i)
            {
                // 最後の項目は" "で区切ることができない
                datas[index[i]] = tempMonitorData;
            }

            return datas;
        }

        /// <summary>
        /// 操作ログを","分割
        /// </summary>
        /// <param name="ControlDatas"></param>
        /// <returns></returns>
        private string[] MakeStringControlData(string[] ControlDatas)
        {
            string[] datas = new string[IQ21Cmn.DATA_SIZE];

            // {0,1,2,3,4,5}が存在しないデータは解析エラーデータ
            if (ControlDatas.Length > 5)
            {
                // 時間
                datas[IQ21Cmn.POP_TIME] = ControlDatas[0];
                // タイトル
                datas[IQ21Cmn.TITLE] = ControlDatas[1];
                if (ControlDatas[1].IndexOf("設定") >= 0)
                {
                    // 設定
                    datas[IQ21Cmn.CONTROL1] = ControlDatas[2];
                    datas[IQ21Cmn.SETTING] = ControlDatas[4];
                    datas[IQ21Cmn.UNIT] = ControlDatas[5];
                }
                else if (ControlDatas[1].IndexOf("操作") >= 0)
                {
                    // 操作
                    datas[IQ21Cmn.CONTROL1] = ControlDatas[2];
                    datas[IQ21Cmn.CONTROL2] = ControlDatas[3];
                }
                else
                {
                    // 警報　報知
                    datas[IQ21Cmn.CONTROL1] = ControlDatas[2];
                }
            }

            for (int i = 0; i < datas.Length; i++)
            {
                if (datas[i] == null)
                {
                    datas[i] = string.Empty;
                }
            }

            return datas;
        }

        /// <summary>
        /// UIスレッド側から[モニタデータ]受信内容表示ラベルに追加を依頼(※UIスレッドから操作しないとうまくいかないので)
        /// </summary>
        /// <param name="argMsg">追加する文字列</param>
        private void BeginInvokeChangeLblMonitorText(string argMsg)
        {
            BeginInvoke((MethodInvoker)(() => LblMonitor.Text = argMsg));
        }

        /// <summary>
        /// [その他データ]受信履歴リストボックスに追加
        /// </summary>
        /// <param name="argMsg">追加する文字列</param>
        private void AddLstBox(string argMsg)
        {
            if (LstBox.Items.Contains("[その他データ]"))
            {
                LstBox.Items.Remove("[その他データ]");
            }

            LstBox.Items.Insert(0, argMsg);

            if (LstBox.Items.Count > 100)
            {
                LstBox.Items.RemoveAt(100);
            }
        }

        /// <summary>
        /// UIスレッド側から[その他データ]受信履歴リストボックスに追加を依頼(※UIスレッドから操作しないとうまくいかないので)
        /// </summary>
        /// <param name="argMsg">追加する文字列</param>
        private void BeginInvokeAddLstBox(string argMsg)
        {
            BeginInvoke((MethodInvoker)(() => AddLstBox(argMsg)));
        }
    }
}

