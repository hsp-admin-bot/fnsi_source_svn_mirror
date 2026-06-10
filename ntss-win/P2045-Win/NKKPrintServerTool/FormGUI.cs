//----------------------------------------------------------------------------------------------------
//　GUI画面用クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;
using System.Windows.Forms;
using System.Diagnostics;
using TdcSocketLib;
using NKKLoggingLib;
using TdcVersionInfoLib;
using System.Linq;
using NKKPrintServerTool.Models;

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightTool
//----------------------------------------------------------------------------------------------------
namespace NKKPrintServerTool
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// GUIツール画面クラス
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormGUI : Form
    {
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービス名称
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly string SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao start
        private readonly string LOG_FILE_EXT = "PrintTool";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao end
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログ保持日数[既定：20日] 
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int m_nLogFileKeepNumberDays = 20;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 表示用ログ情報保持リスト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private Dictionary<string, string> m_lstViewLogInfo = new Dictionary<string, string>();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面タイトル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private string m_strAppTitle = string.Empty;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 初回表示フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bFirstShow = true;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了フラグ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool m_bExit = false;
        //----------------------------------------------------------------------------------------------------
        // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 start
        /// <summary>
        /// フラグ
        /// </summary>
        private bool flg = false;
        // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI待受への接続用クライアントソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly TdcBaseSocketClient m_soc = new TdcBaseSocketClient(1024);
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回画面更新日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_BeforeRefreshDateTime = DateTime.MinValue;
        //----------------------------------------------------------------------------------------------------

        /// <summary>Windows サービス名（ProjectInstaller.serviceInstaller1.ServiceName と一致）</summary>
        private const string PrintServiceInternalName = "NKKPrintServer";
        private const string TrayStatusRunning = "印刷サーバーアプリ処理中";
        private const string TrayStatusStopped = "印刷サーバーアプリ停止中";

        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
        private List<PatientEx> patientList = new List<PatientEx>();
        private List<String> printerCdList = new List<string>();
        private List<String> clientKeyList = new List<string>();
        private List<String> printerNameList = new List<string>();
        private List<String> dispPrinterNameList = new List<string>();
        private List<String> isDelList = new List<string>();
        private String strClientKey = String.Empty;
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
        // del 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
        //private Message msg;
        // del 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
        //操作方式 (0:初期化　1:登録　2:更新　3:削除)
        public static int useType = 0;
        // add FNSI-4749 不要プリンターの削除機能対応 夏 end

        #region コンストラクタ

        /// <summary>
        ///  コンストラクタ
        /// </summary>
        public FormGUI()
        {
            InitializeComponent();

            // 画面タイトル取得
            Text = Application.ProductName;
            m_strAppTitle = this.Text;

            // 起動時は最小状態でタスクバーに表示されないように設定
            WindowState = FormWindowState.Minimized;
            ShowInTaskbar = false;

            // 
            // mod #12210 印刷サーバアプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKPrintServer;
            //notifyIcon.Icon = Icon;
            notifyIcon.Icon = Properties.Resources.NKKPrintServer;
            // mod #12210 印刷サーバアプリ&ツール　アイコン差し替え 高 end

            // NKKAccessCardTool と同様：起動直後は未接続想定でトレイ文言を設定し、通知領域の表示を明示的に更新する
            UpdateTrayStatusText(false);
            notifyIcon.Visible = false;
            notifyIcon.Visible = true;

            //ダブルバッファリングを有効化(ちらつき防止)
            DoubleBuffered = true;
            // Reflectionにて設定
            Type myType = typeof(ListView);
            System.Reflection.PropertyInfo myPropertyInfo = myType.GetProperty("DoubleBuffered", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            myPropertyInfo.SetValue(listView, true, null);


            // 項目初期化
            DateTime dtnow = DateTime.Now;
            foreach (ListViewItem item in listView.Items)
            {
                // 状態
                item.SubItems[1].Text = "不明";
                // 更新日
                item.SubItems[2].Text = dtnow.ToString("yyyy/MM/dd HH:mm:ss:ffff");
                // 内容
                item.SubItems[3].Text = "サービスと未接続";
            }

            // ログ設定
            NKKLogging log = NKKLogging.GetInstance();

            //mod  20210908 #5967 値を変更する  鄭  start
            //  識別子
            //  log.LogExt = LOG_FILE_EXT;
            log.LogExt = $"{LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
            //mod  20210908 #5967 値を変更する  鄭  start

            //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
            log.FirstWriteEvent = VersionInfos.GetVersionInfo;

            // 設定ファイル名作成
            //string strfile = AppDomain.CurrentDomain.BaseDirectory;
            //if (strfile.EndsWith("\\") == false)
            //{
            //    strfile += "\\";
            //}
            //strfile += CONFIG_FILE_NAME;

            // システム共通設定クラス初期化
            //SystemSettingInfo sys = SystemSettingInfo.GetInstance();
            //if (sys.Load(strfile) == false)
            //{
            //    // 設定読み込み失敗

            //    throw (new Exception(string.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
            //}

            // ログ格納先フォルダ
            //log.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "Folder", string.Empty).Trim();
            log.LogFolder = Properties.Settings.Default.Folder;

            // ログ保持日数[既定：20日]
            //if (int.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "KeepNumberOfDays", string.Empty).Trim(), out int nwork) && 0 <= nwork)
            //{
            //    // ログ保持日数
            //    m_nLogFileKeepNumberDays = nwork;
            //}
            int nwork = Properties.Settings.Default.KeepNumberOfDays;
            if (0 <= nwork)
            {
                // ログ保持日数
                m_nLogFileKeepNumberDays = nwork;
            }

            // ログ記録：処理開始
            log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "処理開始");

            // GUI用接続先IPアドレス
            //string ip = sys.GetSingleLineValue(CONFIG_GUI_SECTION, "IPAddress", "127.0.0.1").Trim();
            string ip = Properties.Settings.Default.IPAddress;
            // GUI用待受ポート番号
            int nport = 5010;
            //if (int.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", string.Empty).Trim(), out nwork) && 0 < nwork)
            //{
            //    nport = nwork;
            //}
            nwork = Properties.Settings.Default.PortNo;
            if (0 < nwork)
            {
                nport = nwork;
            }

            // クライアントソケット設定
            //m_soc.SetParams(ip, nwork, 30 * 1000);
            m_soc.SetParams(ip, nport, 30 * 1000);

            // 接続/切断時
            m_soc.ConnectedHandler = Connected;

            // 受信時
            m_soc.ReceivedHandler = ReceivedMessage;

            // クライアントソケット接続
            m_soc.StartConnect();

            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            useType = 0;
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
        }

        #endregion

        /// <summary>
        /// 通知アイコン文言更新（NKKAccessCardTool.FormGUI.UpdateTrayStatusText と同様）
        /// </summary>
        /// <param name="isRunning">ソケット接続済み想定の場合 true（サービス状態で上書き）</param>
        private void UpdateTrayStatusText(bool isRunning)
        {
            bool serviceRunning = isRunning;
            try
            {
                using (ServiceController service = new ServiceController(PrintServiceInternalName))
                {
                    service.Refresh();
                    serviceRunning = service.Status == ServiceControllerStatus.Running
                                     || service.Status == ServiceControllerStatus.StartPending
                                     || service.Status == ServiceControllerStatus.ContinuePending;
                }
            }
            catch
            {
                // サービス参照失敗時はソケット状態にフォールバック
            }

            string trayStatusText = serviceRunning ? TrayStatusRunning : TrayStatusStopped;
            notifyIcon.Text = trayStatusText;
            notifyIcon.BalloonTipText = trayStatusText;
        }

        private void SetTrayStatusFromSocketThread(bool running)
        {
            if (InvokeRequired)
            {
                BeginInvoke((MethodInvoker)(() => UpdateTrayStatusText(running)));
            }
            else
            {
                UpdateTrayStatusText(running);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォーム破棄時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void Form1_FormClosing(object sender, FormClosingEventArgs e)
        {
            // ログ設定
            NKKLogging log = NKKLogging.GetInstance();

            // 終了フラグがセットされていない場合
            if (m_bExit == false)
            {
                // 終了処理のキャンセル
                e.Cancel = true;

                // フォームの非表示
                Visible = false;
            }
            else
            {
                // ログ削除
                _ = log.DeleteLogFiles(SERVICE_NAME, m_nLogFileKeepNumberDays, true);

                // ログ記録：処理終了
                log.AddLogInfo(DateTime.Now, SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "処理終了");

                // ログ記録クラス破棄
                NKKLogging.DeleteInstance();
            }

            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            useType = 0;
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスとのクライアントソケット接続/切断時
        /// </summary>
        /// <param name="sender">ベースオブジェクト</param>
        /// <param name="status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        private void Connected(object sender, TdcBaseSocket.ConnectionStatus status)
        {

            // 実際の処理はこちらで
            void addListViewItem(string[] message)
            {
                //_ = BeginInvoke((Action<string[]>)delegate (string[] s) { listView.Items.Add("サービス").SubItems.AddRange(s); }, message);
                if (InvokeRequired)
                {
                    //Trace.WriteLine("_ = BeginInvoke((Action<string[]>)delegate (string[] s) { listView.Items.Add(\"サービス\").SubItems.AddRange(s); }, message)");
                    //_ = BeginInvoke((Action<string[]>)delegate (string[] s) { listView.Items.Add("サービス").SubItems.AddRange(s); }, message);

                }
                else
                {
                    //Trace.WriteLine("listView.Items.Add(\"サービス\").SubItems.AddRange(message)");
                    //listView.Items.Add("サービス").SubItems.AddRange(message);
                }
                Trace.WriteLine("Status: " + status.ToString());

            }

            try
            {

                // プリンタ登録メニューの使用可否を設定するローカル関数
                void setPostPrinterMenuEnabled(bool value)
                {
                    if (InvokeRequired)
                    {
                        _ = BeginInvoke((Action)delegate () { MnuPostPrinter.Enabled = value; });
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
                        _ = BeginInvoke((Action)delegate () { MnuUpdatePrinter.Enabled = value; });
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
                    }
                    else
                    {
                        MnuPostPrinter.Enabled = value;
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
                        MnuUpdatePrinter.Enabled = value;
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
                    }
                }

                // 接続状態判定
                if (status == TdcBaseSocket.ConnectionStatus.CLOSE || status == TdcBaseSocket.ConnectionStatus.ERROR)
                {
                    // 切断時
                    SetTrayStatusFromSocketThread(false);

                    // ［プリンター登録］メニュー
                    //MnuPostPrinter.Enabled = false;
                    setPostPrinterMenuEnabled(false);

                    DateTime dtnow = DateTime.Now;
                    StringBuilder sbwork = new StringBuilder();

                    // 保持要素すべてが対象

                    // m_lstViewLogInfoコレクション(Dictionary<string, string>)から要素となるKeyValuePair<string, string>と取り出し
                    // KeyValuePair<string, string>要素のValueをTabで分割しstritems配列に格納する
                    foreach (string[] stritems in
                    from KeyValuePair<string, string> item in m_lstViewLogInfo
                    let stritems = item.Value.Split('\t')
                    select stritems)
                    {

                        // 状態
                        stritems[1] = "不明";
                        // 内容
                        stritems[3] = "サービスから切断";

                        // 記録内容：種別{TAB}状態{TAB}更新日時{TAB}発生内容{CRLF}
                        _ = sbwork.AppendLine($"{stritems[0]}\t{stritems[1]}\t{dtnow:yyyy/MM/dd HH:mm:ss:ffff}\t{stritems[3]}");

                    }

                    // 記録内容をバイナリ化
                    byte[] buff = Encoding.UTF8.GetBytes(sbwork.ToString());

                    // 通知
                    ReceivedMessage(sender, buff, buff.Length);

                }
                else if (status == TdcBaseSocket.ConnectionStatus.CONNECT)
                {
                    // ［プリンター登録］メニュー
                    setPostPrinterMenuEnabled(true);
                    SetTrayStatusFromSocketThread(true);

                }
                else if (status == TdcBaseSocket.ConnectionStatus.DISCONECTING || status == TdcBaseSocket.ConnectionStatus.DISCONNECT || status == TdcBaseSocket.ConnectionStatus.DISCONECT_START || status == TdcBaseSocket.ConnectionStatus.RECONNECT_START)
                {
                    // 切断
                    SetTrayStatusFromSocketThread(false);
                    // ［プリンター登録］メニュー
                    setPostPrinterMenuEnabled(false);

                }

            }
            catch (Exception ex)
            {
                //listView.Items.Add("サービス").SubItems.AddRange(new string[] { "接続", ex.Message, "" });
                addListViewItem(new string[] { "接続", ex.Message, "" });
            }

        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスからのメッセージ受信
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="cRecvData">受信バッファ</param>
        /// <param name="nRecvSize">受信サイズ</param>
        //----------------------------------------------------------------------------------------------------
        private void ReceivedMessage(object sender, byte[] cRecvData, int nRecvSize)
        {
            // 受信データの文字列化
            string strdata = Encoding.UTF8.GetString(cRecvData, 0, nRecvSize);

            // 電文の分割
            string[] stritems = strdata.Split(new string[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (string strline in stritems)
            {
                // 項目の分割
                string[] stritem = strline.Split('\t');

                // 処理履歴の保持
                if (m_lstViewLogInfo.ContainsKey(stritem[0]) == true)
                {
                    // 該当情報あり

                    //　更新
                    m_lstViewLogInfo[stritem[0]] = strline;
                }
                else
                {
                    // 該当情報なし

                    //　新規追加
                    m_lstViewLogInfo.Add(stritem[0], strline);
                }

                // 画面が表示されている場合
                if (Visible == true)
                {
                    // 画面更新(非同期:匿名メソッドによるデリゲート処理)
                    BeginInvoke((MethodInvoker)delegate ()
                    {
                        // 
                        ShowListView(strline);
                    });
                }
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面表示
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_View_Click(object sender, EventArgs e)
        {
            // 初回表示の場合
            if (this.m_bFirstShow == true)
            {
                // タスクバーへ表示するように再設定
                this.ShowInTaskbar = true;

                // 初回表示フラグをクリア
                this.m_bFirstShow = false;
            }

            // 表示状態を最小状態とする
            this.WindowState = FormWindowState.Minimized;

            // フォームの表示
            this.Visible = true;

            // 最小状態から元に戻す
            this.WindowState = FormWindowState.Normal;

            // フォームをアクティブにする
            this.Activate();
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 終了
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_Exit_Click(object sender, EventArgs e)
        {
            // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 start
            if (flg)
            {
                return;
            }
            flg = true;
            // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 end

            // 終了確認
            if (MessageBox.Show(this, "終了してもよろしいですか？", Application.ProductName, MessageBoxButtons.OKCancel, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.OK)
            {
                // アイコンをトレイから取り除く
                this.notifyIcon.Visible = false;

                // アプリケーション終了のため、終了フラグをセット
                this.m_bExit = true;

                // アプリケーションの終了
                this.Close();
            }

            // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 start
            flg = false;
            // add #8800 終了ボタンを押下すると、連続で終了画面が表示される 董昊 end
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 選択項目コピー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_Copy_Click(object sender, EventArgs e)
        {
            // 選択項目チェック
            if (0 < listView.SelectedItems.Count)
            {
                // 選択項目分処理
                StringBuilder sbitem = new StringBuilder();
                foreach (ListViewItem item in listView.SelectedItems)
                {
                    // 記録内容：種別{TAB}状態{TAB}更新日時{TAB}発生内容{CRLF}
                    sbitem.AppendLine(String.Format("{0}\t{1}\t{2}\t{3}", item.Text, item.SubItems[1].Text, item.SubItems[2].Text, item.SubItems[3].Text));
                }

                // クリップボードへコピー
                Clipboard.SetText(sbitem.ToString(), TextDataFormat.UnicodeText);
            }
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面初回表示時
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void FormViewLog_Shown(object sender, EventArgs e)
        {
            // 処理履歴の表示
            foreach (KeyValuePair<String, String> item in this.m_lstViewLogInfo)
            {
                ShowListView(item.Value);
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ListView項目更新
        /// </summary>
        /// <param name="strData"></param>
        //----------------------------------------------------------------------------------------------------
        private void ShowListView(string strData)
        {
            try
            {
                // データの分割
                string[] stritem = strData.Split('\t');

                // データ表示
                int nidx = -1;
                switch (stritem[0].ToUpper())
                {
                    case "INFO":
                        Text = $"{m_strAppTitle}：{stritem[3]}";
                        break;

                    case "SERVER":
                        nidx = 0;
                        break;

                    case "WEBSOCKET":
                        nidx = 1;
                        break;

                    case "FELICA":
                        nidx = 2;
                        break;

                    case "WEIGHTSCALE":
                        nidx = 3;
                        break;

                    case "PRINTER":
                        nidx = 4;
                        break;

                    // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
                    case "PRINTERS":
                        patientList.Clear();

                        // ローカルプリンターを取得する
                        String[] strPrinterData = stritem[1].Split(';');
                        String[] strPrinterName = { "" };
                        String clientKey = strPrinterData[0];
                        if (strPrinterData.Length > 1)
                        {
                            strPrinterName = strPrinterData[1].Split(',');
                        }
                        printerCdList.Clear();
                        clientKeyList.Clear();
                        printerNameList.Clear();
                        dispPrinterNameList.Clear();
                        isDelList.Clear();

                        // DBのプリンターを取得する
                        String[] dbPrinter = stritem[3].Replace("},{", "};{").Split(';');

                        // ローカルプリンターLoop
                        PatientEx obj = new PatientEx();
                        if (dbPrinter.Length == 1 && dbPrinter[0] == "[]")
                        {
                            nidx = ErrorMessage();
                        }
                        else
                        {
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            if (useType == 2)
                            {
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                                for (int i = 0; i < strPrinterName.Length; i++)
                                {
                                    obj = new PatientEx();

                                    obj.Selected = false;

                                    for (int j = 0; j < dbPrinter.Length; j++)
                                    {
                                        Dictionary<String, String> json = TdcLib.JSONLib.JSONtoData(dbPrinter[j]);
                                        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                                        //if (strPrinterName[i].Equals(json["printerName"]))
                                        if (strPrinterName[i].Equals(json["printerName"]) && !string.IsNullOrEmpty(json["clientKey"]))
                                        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                                        {
                                            if (json["clientKey"].IndexOf(clientKey) >= 0 && json["isDel"] == "0")
                                            {
                                                obj.Selected = true;
                                            }
                                            obj.Patient = json["printerName"];
                                            obj.PatientName = json["dispPrinterName"];

                                            printerCdList.Add(json["printerCd"]);
                                            // mod FNSI-4749 不要プリンターの削除機能対応 夏 start
                                            //if (!"null".Equals(json["clientKey"]))
                                            //{
                                            clientKeyList.Add(json["clientKey"]);
                                            //}
                                            //else
                                            //{
                                            //    clientKeyList.Add("");
                                            //}
                                            // mod FNSI-4749 不要プリンターの削除機能対応 夏 end
                                            printerNameList.Add(json["printerName"]);
                                            dispPrinterNameList.Add(json["dispPrinterName"]);
                                            isDelList.Add(json["isDel"]);
                                            patientList.Add(obj);
                                            break;
                                        }
                                    }
                                }
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            }
                            else if (useType == 3)
                            {
                                for (int j = 0; j < dbPrinter.Length; j++)
                                {
                                    obj = new PatientEx();
                                    obj.Selected = false;

                                    Dictionary<String, String> json = TdcLib.JSONLib.JSONtoData(dbPrinter[j]);
                                    if (!string.IsNullOrEmpty(json["clientKey"]))
                                    {
                                        obj.Patient = json["printerName"];
                                        obj.PatientName = json["dispPrinterName"];

                                        printerCdList.Add(json["printerCd"]);
                                        clientKeyList.Add(json["clientKey"]);
                                        printerNameList.Add(json["printerName"]);
                                        dispPrinterNameList.Add(json["dispPrinterName"]);
                                        isDelList.Add(json["isDel"]);
                                        patientList.Add(obj);
                                    }

                                }
                            }
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 end

                            if (patientList.Count == 0)
                            {
                                nidx = ErrorMessage();
                            }
                            else
                            {
                                strClientKey = clientKey;
                                this.Hide();
                                FrmModalBed.patientList = patientList;
                                FrmModalBed frmModalBed = new FrmModalBed();
                                DialogResult result = frmModalBed.ShowDialog();

                                if (result == DialogResult.OK)
                                {
                                    // Send data
                                    SendClientKey(FrmModalBed.patientList);
                                    nidx = 6;
                                }
                                else
                                {
                                    nidx = 7;
                                }

                                FrmModalBed.patientList.Clear();
                                this.Show();
                            }
                        }
                        break;
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end
                }

                //if (0 <= nidx && nidx < listView.Items.Count)
                //{
                //    ListViewItem item = listView.Items[nidx];

                //    // 状態
                //    if (string.IsNullOrWhiteSpace(stritem[1]) == false)
                //    {
                //        item.SubItems[1].Text = stritem[1];
                //    }
                //    // 更新日
                //    item.SubItems[2].Text = stritem[2];
                //    // 内容
                //    item.SubItems[3].Text = stritem[3];
                //}
                if (0 <= nidx)
                {
                    if (nidx < 5)
                    {
                        ListViewItem item = listView.Items[nidx];

                        // 状態
                        if (string.IsNullOrWhiteSpace(stritem[1]) == false)
                        {
                            item.SubItems[1].Text = stritem[1];
                        }
                        // 更新日
                        item.SubItems[2].Text = stritem[2];
                        // 内容
                        item.SubItems[3].Text = stritem[3];
                    }
                    else
                    {
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
                        if (nidx == 6)
                        {
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            if (useType == 2)
                            {
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                                listView.Items.Add("プリンター更新").SubItems.AddRange(new string[] { "更新", stritem[2], "更新処理成功" });
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            }
                            else if (useType == 3)
                            {
                                listView.Items.Add("プリンター削除").SubItems.AddRange(new string[] { "削除", stritem[2], "削除処理成功" });
                            }
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                        }
                        else if (nidx == 7)
                        {
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            if (useType == 2)
                            {
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                                listView.Items.Add("プリンター更新").SubItems.AddRange(new string[] { "未更新", stritem[2], "更新処理未実施" });
                                // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                            }
                            else if (useType == 3)
                            {
                                listView.Items.Add("プリンター削除").SubItems.AddRange(new string[] { "未削除", stritem[2], "削除処理未実施" });
                            }
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                        }
                        else
                        {
                            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
                            // 追加する
                            ListViewItem item = listView.Items.Add("プリンタ");
                            item.SubItems[1].Text = "印刷";
                            item.SubItems[2].Text = stritem[2];
                            item.SubItems[3].Text = stritem[3];
                            // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
                        }
                        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end
                    }

                }
                else
                {
                    // 0 > nidx

                    // 追加する
                    //ListViewItem item = listView.Items.Add("プリンタ");
                    //item.SubItems[1].Text = "印刷";
                    //item.SubItems[2].Text = stritem[2];
                    //item.SubItems[3].Text = stritem[3];
                    // add 2020-11-02 UTバグ1修正 更新後で登録フォームの出力文言不正 夏 start
                    if (FrmModalBed.patientList == null || FrmModalBed.patientList.Count == 0)
                    {
                        // add 2020-11-02 FNSI-仕様追加 更新後で登録フォームの出力文言不正 夏 end
                        listView.Items.Add("プリンタ").SubItems.AddRange(new string[] { "印刷", stritem[2], stritem[3] });
                        // add 2020-11-02 FNSI-仕様追加 更新後で登録フォームの出力文言不正 夏 start
                    }
                    // add 2020-11-02 FNSI-仕様追加 更新後で登録フォームの出力文言不正 夏 end
                }

            }
            catch (Exception ex)
            {
                Debug.WriteLine(ex.Message);
            }
            finally
            {
            }
        }

        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 start
        private int ErrorMessage()
        {
            MessageBox.Show("プリンターはプリンターマスタテーブルに登録されないです。\n\r先にプリンター登録を実施してください。",
                            "プリンター登録要",
                            MessageBoxButtons.OK,
                            MessageBoxIcon.Question);
            return 7;
        }
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 夏 end

        /// <summary>
        /// ［プリンター登録］メニュー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void MnuPostPrinter_Click(object sender, EventArgs e)
        {
            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            useType = 1;
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end

            // listViewに1行追加するローカル関数
            void addListViewItem(string state, string description)
            {
                listView.Items.Add(((ToolStripMenuItem)sender).Text).SubItems.AddRange(new string[] { state, DateTime.Now.ToString(), description });
            }

            try
            {
                // プリンター登録依頼コマンドを送信する
                if (m_soc.CheckConnected())
                {
                    bool ret = m_soc.Write(new byte[] { 0 });
                    //if (false == m_soc.Write(new byte[] { 0 }))
                    //{
                    //    listView.Items.Add("操作").SubItems.AddRange(new string[] { ((ToolStripMenuItem)sender).Text, "プリンター登録依頼コマンド送信失敗", "" });
                    //}
                    //listView.Items.Add("操作").SubItems.AddRange(new string[] { ((ToolStripMenuItem)sender).Text, "プリンター登録依頼コマンド送信結果" + ret.ToString(), "" });
                    addListViewItem(ret.ToString(), "プリンター登録依頼コマンド送信");
                }

            }
            catch (Exception ex)
            {
                //listView.Items.Add("操作").SubItems.AddRange(new string[] { ((ToolStripMenuItem)sender).Text, ex.Message, "" });
                addListViewItem("例外", ex.Message);
            }

        }

        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 start
        /// <summary>
        /// ［プリンター一覧］メニュー
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void ToolStripMenuItem_Click(object sender, EventArgs e)
        {
            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            useType = 2;
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end

            // listViewに1行追加するローカル関数
            void addListViewItem(string state, string description)
            {
                listView.Items.Add(((ToolStripMenuItem)sender).Text).SubItems.AddRange(new string[] { state, DateTime.Now.ToString(), description });
            }

            try
            {
                // プリンター検索依頼コマンドを送信する
                if (m_soc.CheckConnected())
                {
                    bool ret = m_soc.Write(new byte[] { 1 });
                    addListViewItem(ret.ToString(), "プリンター検索依頼コマンド送信");
                }

            }
            catch (Exception ex)
            {
                addListViewItem("例外", ex.Message);
            }

        }

        private void SendClientKey(List<PatientEx> patientList)
        {
            if (patientList.Count != 0)
            {

                List<String> wList = new List<string>();
                List<String> sortList = new List<string>();
                String printerCd = String.Empty;
                String clientKey = String.Empty;
                String type = String.Empty;
                int i = 0;
                foreach (PatientEx row in patientList)
                {

                    Boolean clientKeyFlg = false;
                    printerCd = printerCdList[i];
                    String[] arr = clientKeyList[i].Split(',');
                    clientKey = "";
                    // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                    if (useType == 2)
                    {
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                        //チェック有無をチェックする
                        if (Convert.ToBoolean(row.Selected))
                        {
                            if ("1".Equals(isDelList[i]))
                            {
                                clientKey = strClientKey;
                            }
                            else
                            {
                                //チェックあり：client_keyに追加する。
                                for (int j = 0; j < arr.Length; j++)
                                {
                                    if (arr[j].Equals(strClientKey))
                                    {
                                        clientKeyFlg = true;
                                    }
                                }
                                if (clientKeyFlg == false)
                                {
                                    if (String.IsNullOrEmpty(clientKeyList[i]))
                                    {
                                        clientKey = strClientKey;
                                    }
                                    else
                                    {
                                        //「client_key」を並び替えること
                                        sortList.Clear();
                                        String[] strSortData = clientKeyList[i].Split(',');
                                        foreach (String sortData in strSortData)
                                        {
                                            sortList.Add(sortData);
                                        }
                                        sortList.Add(strClientKey);
                                        sortList.Sort((x, y) => x.CompareTo(y));
                                        clientKey = string.Join(",", sortList.ToArray());
                                    }
                                }
                                else
                                {
                                    clientKey = clientKeyList[i];
                                }
                            }
                            type = "ADD";
                        }
                        else
                        {
                            //チェックなし：client_keyから削除する。
                            if (strClientKey.Equals(clientKeyList[i]))
                            {
                                clientKey = strClientKey;
                            }
                            else
                            {
                                for (int j = 0; j < arr.Length; j++)
                                {
                                    if (!arr[j].Equals(strClientKey))
                                    {
                                        if (String.IsNullOrEmpty(clientKey))
                                        {
                                            clientKey = arr[j];
                                        }
                                        else
                                        {
                                            clientKey = clientKey + "," + arr[j];
                                        }

                                    }
                                }
                            }
                            type = "DELETE";
                        }
                        wList.Add(String.Format("{{\"printerCd\":\"{0}\"; \"clientKey\":\"{1}\"; \"type\":\"{2}\"}}"
                        , printerCd
                        , clientKey
                        , type
                        ));
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                    }
                    else if (useType == 3)
                    {
                        if (Convert.ToBoolean(row.Selected))
                        {
                            clientKey = "";
                            type = "DELETE";
                            wList.Add(String.Format("{{\"printerCd\":\"{0}\"; \"clientKey\":\"{1}\"; \"type\":\"{2}\"}}"
                            , printerCd
                            , clientKey
                            , type
                            ));
                        }
                    }
                    i++;
                    // add FNSI-4749 不要プリンターの削除機能対応 夏 end

                }
                //JSONデータを転換する
                var wJsonData = LayoutDesigner.RldJsonDataSerializeHelper<List<String>>.Serialize(wList);
                byte[] bdata = Encoding.UTF8.GetBytes(wJsonData);

                //m_soc.StartConnect();
                //bool ret = m_soc.Write(bdata);

                // listViewに1行追加するローカル関数
                void addListViewItem(string state, string description)
                {
                    // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                    if (useType == 2)
                    {
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                        listView.Items.Add("プリンター更新").SubItems.AddRange(new string[] { state, DateTime.Now.ToString(), description });
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                    }
                    else if (useType == 3)
                    {
                        listView.Items.Add("プリンター削除").SubItems.AddRange(new string[] { state, DateTime.Now.ToString(), description });
                    }
                    // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                }
                try
                {
                    // プリンター登録依頼コマンドを送信する
                    if (m_soc.CheckConnected())
                    {
                        //bool ret = m_soc.Write(bdata);
                        bool ret = m_soc.Write(bdata);
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                        if (useType == 2)
                        {
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                            addListViewItem(ret.ToString(), "プリンター更新依頼コマンド送信");
                            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
                        }
                        else if (useType == 3)
                        {
                            addListViewItem(ret.ToString(), "プリンター削除依頼コマンド送信");
                        }
                        // add FNSI-4749 不要プリンターの削除機能対応 夏 end
                    }

                }
                catch (Exception ex)
                {
                    addListViewItem("例外", ex.Message);
                }

            }

        }
        // add 2020-09-29 FNSI-仕様追加 印刷アプリを複数登録する 黄 end


        private void MnuDeletePrinter_Click(object sender, EventArgs e)
        {
            // add FNSI-4749 不要プリンターの削除機能対応 夏 start
            useType = 3;
            // add FNSI-4749 不要プリンターの削除機能対応 夏 end

            // listViewに1行追加するローカル関数
            void addListViewItem(string state, string description)
            {
                listView.Items.Add(((ToolStripMenuItem)sender).Text).SubItems.AddRange(new string[] { state, DateTime.Now.ToString(), description });
            }

            try
            {
                // プリンター検索依頼コマンドを送信する
                if (m_soc.CheckConnected())
                {
                    bool ret = m_soc.Write(new byte[] { 1 });
                    addListViewItem(ret.ToString(), "プリンター検索依頼コマンド送信");
                }

            }
            catch (Exception ex)
            {
                addListViewItem("例外", ex.Message);
            }
        }
    }
    //----------------------------------------------------------------------------------------------------
}//----------------------------------------------------------------------------------------------------
