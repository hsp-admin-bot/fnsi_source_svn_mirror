//----------------------------------------------------------------------------------------------------
//　GUI画面用クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;
using System.Windows.Forms;
#if DEBUG
    using System.Diagnostics;
#endif

//----------------------------------------------------------------------------------------------------
//  名前空間:TdcLib
//----------------------------------------------------------------------------------------------------
using TdcLib;
//----------------------------------------------------------------------------------------------------
// 名前空間:TdcSocketLib
//----------------------------------------------------------------------------------------------------
using TdcSocketLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:NKKLoggingLib
//----------------------------------------------------------------------------------------------------
using NKKLoggingLib;
//----------------------------------------------------------------------------------------------------
//  名前空間:TdcVersionLib
//----------------------------------------------------------------------------------------------------
using TdcVersionInfoLib;
//----------------------------------------------------------------------------------------------------

//----------------------------------------------------------------------------------------------------
//  名前空間:NKKWeightTool
//----------------------------------------------------------------------------------------------------
namespace NKKWeightTool
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
        private readonly String SERVICE_NAME = System.Reflection.Assembly.GetExecutingAssembly().GetName().Name;
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ログファイル識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao start
        private readonly String LOG_FILE_EXT = "WeightTool";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 donghao end
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKWeightTool.config";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内ログ設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_LOG_SECTION = "Settings\\Log";
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル内GUI設定セッション識別子
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_GUI_SECTION = "Settings\\Tool";
        //----------------------------------------------------------------------------------------------------
        /// <summary>FNWSiAccessCardTool の APP_DISPLAY_NAME と同様、画面タイトル・製品表示名用（AssemblyProduct と一致）</summary>
        private const string APP_DISPLAY_NAME = "体重計保守ツール";
        //----------------------------------------------------------------------------------------------------
        private const string TRAY_STATUS_RUNNING = "体重計アプリ処理中";
        private const string TRAY_STATUS_STOPPED = "体重計アプリ停止中";
        /// <summary>Windows サービス登録名（ProjectInstaller.ServiceName と一致）</summary>
        private const string WEIGHT_SERVICE_INTERNAL_NAME = "NKKWeightService";
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
        private Dictionary<String, String> m_lstViewLogInfo = new Dictionary<String, String>();
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 画面タイトル
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private String m_strAppTitle = String.Empty;
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
        // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　start
        /// <summary>
        /// フラグ
        /// </summary>
        private bool flg = false;
        // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI待受への接続用クライアントソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private TdcBaseSocketClient m_soc = new TdcBaseSocketClient( 1024 );
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回画面更新日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_BeforeRefreshDateTime = DateTime.MinValue;
        //----------------------------------------------------------------------------------------------------
        /// <summary>通知領域のサービス稼働状態を定期的に再取得する（NKKAccessCardTool と同様）</summary>
        private readonly System.Windows.Forms.Timer m_trayServiceStatusTimer = new System.Windows.Forms.Timer();

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public FormGUI()
        {
            InitializeComponent();

            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKWeight;
            // add #12209 体重計アプリ&ツール　アイコン差し替え 高 end

            // 画面タイトル（FNWSiAccessCardTool と同様に定数で明示。タスクバー固定時の表示名も製品名系と揃える）
            this.Text = APP_DISPLAY_NAME;
            this.m_strAppTitle = this.Text;

            // 起動時は最小状態でタスクバーに表示されないように設定
            this.WindowState = FormWindowState.Minimized;
            this.ShowInTaskbar = false;

            // 
            this.notifyIcon.Icon = this.Icon;
            this.UpdateTrayStatusText(false);
            // Explorer 側の通知領域アイコンキャッシュにより、再起動直後に表示されないことがあるため明示的に再表示する（FNWSiAccessCardTool と同様）
            this.RefreshNotifyIconShellRegistration();

            this.m_trayServiceStatusTimer.Interval = 2000;
            this.m_trayServiceStatusTimer.Tick += (sender, args) => this.UpdateTrayStatusText(false);
            this.m_trayServiceStatusTimer.Start();

            //ダブルバッファリングを有効化(ちらつき防止)
            this.DoubleBuffered = true;
            // Reflectionにて設定
            System.Type myType = typeof(ListView);
            System.Reflection.PropertyInfo myPropertyInfo = myType.GetProperty("DoubleBuffered", System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic);
            myPropertyInfo.SetValue(this.listView, true, null);


            //項目初期化
            DateTime dtnow = DateTime.Now;
            foreach (ListViewItem item in this.listView.Items)
            {
                // 状態
                item.SubItems[1].Text = "不明";
                // 更新日
                item.SubItems[2].Text = dtnow.ToString("yyyy/MM/dd HH:mm:ss:ffff");
                // 内容
                item.SubItems[3].Text = "未接続";
            }


            // ログ設定
            NKKLogging log = NKKLogging.GetInstance();

            //mod  20210908 #5967 値を変更する  鄭  start
            //  識別子
            //log.LogExt = this.LOG_FILE_EXT;
            //log.LogExt = $"{LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
            log.LogExt = LOG_FILE_EXT+ "_"+System.Net.Dns.GetHostName();
            //mod  20210908 #5967 値を変更する  鄭  end

            //  バージョン情報記録用処理登録(ログが変わった場合にログの先頭に記録するため)
            log.FirstWriteEvent = VersionInfos.GetVersionInfo;

            // 設定ファイル名作成
            String strfile = AppDomain.CurrentDomain.BaseDirectory;
            if (strfile.EndsWith("\\") == false)
            {
                strfile += "\\";
            }
            strfile += this.CONFIG_FILE_NAME;

            // システム共通設定クラス初期化
            SystemSettingInfo sys = SystemSettingInfo.GetInstance();
            if (sys.Load(strfile) == false)
            {
                // 設定読み込み失敗

                throw (new Exception(String.Format("Config,{0}", SystemSettingInfo.GetInstance().Error.ToString())));
            }

            // ログ格納先フォルダ
            log.LogFolder = sys.GetSingleLineValue(CONFIG_LOG_SECTION, "Folder", String.Empty).Trim();
            // ログ保持日数[既定：20日]
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_LOG_SECTION, "KeepNumberOfDays", String.Empty).Trim(), out int nwork) && 0 <= nwork)
            {
                // ログ保持日数
                this.m_nLogFileKeepNumberDays = nwork;
            }

            // ログ記録：処理開始
            log.AddLogInfo(DateTime.Now, this.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "処理開始");


            // GUI用接続先IPアドレス
            String ip = sys.GetSingleLineValue(CONFIG_GUI_SECTION, "IPAddress", "127.0.0.1").Trim();
            // GUI用待受ポート番号
            int nport = 5010;
            if(Int32.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", String.Empty).Trim(), out nwork) && 0 < nwork)
            {
                nport = nwork;
            }


            // クライアントソケット設定
            this.m_soc.SetParams(ip, nwork, 30 * 1000);
            // 接続/切断時
            this.m_soc.ConnectedHandler = this.Connected;
            // 受信時
            this.m_soc.ReceivedHandler = this.ReceivedMessage;

            // クライアントソケット接続
            this.m_soc.StartConnect();
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通知アイコンを Shell に再登録する（FNWSiAccessCardTool の Visible トグルと同趣旨）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void RefreshNotifyIconShellRegistration()
        {
            if (this.notifyIcon == null)
            {
                return;
            }
            this.notifyIcon.Icon = this.Icon;
            this.notifyIcon.Visible = false;
            this.notifyIcon.Visible = true;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 通知アイコン文言更新（NKKAccessCardTool と同様に ServiceController で実状態を取得）
        /// </summary>
        /// <param name="isRunning">サービス状態取得失敗時のフォールバック（接続中なら true）</param>
        //----------------------------------------------------------------------------------------------------
        private void UpdateTrayStatusText(bool isRunning)
        {
            bool serviceRunning = isRunning;
            try
            {
                using (ServiceController service = new ServiceController(WEIGHT_SERVICE_INTERNAL_NAME))
                {
                    service.Refresh();
                    serviceRunning = service.Status == ServiceControllerStatus.Running
                                     || service.Status == ServiceControllerStatus.StartPending
                                     || service.Status == ServiceControllerStatus.ContinuePending;
                }
            }
            catch
            {
                // サービス参照失敗時は引数 isRunning に従う
            }

            string trayStatusText = serviceRunning ? TRAY_STATUS_RUNNING : TRAY_STATUS_STOPPED;
            this.notifyIcon.Text = trayStatusText;
            this.notifyIcon.BalloonTipText = trayStatusText;
        }
        //----------------------------------------------------------------------------------------------------

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
            if (this.m_bExit == false)
            {
                // 終了処理のキャンセル
                e.Cancel = true;

                // フォームの非表示
                this.Visible = false;
            }
            else
            {
                this.m_trayServiceStatusTimer.Stop();
                this.m_trayServiceStatusTimer.Dispose();

                // ログ削除
                log.DeleteLogFiles(this.SERVICE_NAME, this.m_nLogFileKeepNumberDays, true);

                // ログ記録：処理終了
                log.AddLogInfo(DateTime.Now, this.SERVICE_NAME, NKKLogging.LOGGING_CLASS.INFO, "処理終了");

                // ログ記録クラス破棄
                NKKLogging.DeleteInstance();
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// サービスとのクライアントソケット接続/切断時
        /// </summary>
        /// <param name="Sender">ベースオブジェクト</param>
        /// <param name="Status">接続状態</param>
        //----------------------------------------------------------------------------------------------------
        private void Connected(Object Sender, TdcBaseSocket.ConnectionStatus Status)
        {
            // 接続状態判定
            if (Status == TdcBaseSocket.ConnectionStatus.CLOSE || Status == TdcBaseSocket.ConnectionStatus.ERROR)
            {
                // 切断時
                this.UpdateTrayStatusText(false);

                DateTime dtnow = DateTime.Now;
                StringBuilder sbwork = new StringBuilder();

                // 保持要素すべてが対象
                foreach ( KeyValuePair<String, String> item in this.m_lstViewLogInfo )
                {
                    // 項目の分割
                    String[] stritems = item.Value.Split('\t');

                    // 状態
                    stritems[1] = "不明";
                    // 内容
                    stritems[3] = "サービスから切断";

                    // 記録内容：種別{TAB}状態{TAB}更新日時{TAB}発生内容{CRLF}
                    sbwork.AppendLine(String.Format("{0}\t{1}\t{2:yyyy/MM/dd HH:mm:ss:ffff}\t{3}", stritems[0], stritems[1], dtnow, stritems[3]));
                }

                // 記録内容をバイナリ化
                Byte[] buff = Encoding.UTF8.GetBytes(sbwork.ToString());

                // 通知
                this.ReceivedMessage(Sender, buff, buff.Length);
            }
            else
            {
                // 接続時/接続中
                this.UpdateTrayStatusText(true);
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
        private void ReceivedMessage( Object sender, Byte[] cRecvData, int nRecvSize )
        {
            // 受信データの文字列化
            String strdata = Encoding.UTF8.GetString(cRecvData, 0, nRecvSize);

            // 電文の分割
            String[] stritems = strdata.Split(new String[] { "\r\n"}, StringSplitOptions.RemoveEmptyEntries);
            foreach( String strline in stritems )
            {
                // 項目の分割
                String[] stritem = strline.Split('\t');

                // 処理履歴の保持
                if (this.m_lstViewLogInfo.ContainsKey(stritem[0]) == true)
                {
                    // 該当情報あり

                    //　更新
                    this.m_lstViewLogInfo[stritem[0]] = strline;
                }
                else
                {
                    // 該当情報なし

                    //　新規追加
                    this.m_lstViewLogInfo.Add(stritem[0], strline);
                }

                // 画面が表示されている場合
                if (this.Visible == true)
                {
                    // 画面更新(非同期:匿名メソッドによるデリゲート処理)
                    this.BeginInvoke((MethodInvoker)delegate ()
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
            // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　start
            if (flg)
            {
                return;
            }
            flg = true;
            // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　end

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

            // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　start
            flg = false;
            // add #8799 連続で終了ボタンを押下すると連続で終了画面が表示される 董昊　end
        }
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再接続
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        //----------------------------------------------------------------------------------------------------
        private void ToolStripMenuItem_reconnect_Click(object sender, EventArgs e)
        {
            // クライアントソケット切断
            this.m_soc.Close();

            // クライアントソケット接続
            this.m_soc.StartConnect();
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
            if (0 < this.listView.SelectedItems.Count)
            {
                // 選択項目分処理
                StringBuilder sbitem = new StringBuilder();
                foreach (ListViewItem item in this.listView.SelectedItems)
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
            foreach( KeyValuePair<String, String> item in this.m_lstViewLogInfo)
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
        private void ShowListView( String strData )
        {
            try
            {
                // データの分割
                String[] stritem = strData.Split('\t');

                // データ表示
                int nidx = -1;
                switch (stritem[0].ToUpper())
                {
                    case "EXIT":
                        // アプリケーション終了のため、終了フラグをセット
                        this.m_bExit = true;

                        // アプリケーションの終了
                        this.Close();
                        break;

                    case "INFO":
                        this.Text = String.Format("{0}：{1}", this.m_strAppTitle , stritem[3]);
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
                    
                }
                if (0 <= nidx && nidx < this.listView.Items.Count)
                {
                    ListViewItem item = this.listView.Items[nidx];

                    // 状態
                    if( String.IsNullOrWhiteSpace(stritem[1]) == false )
                    {
                        item.SubItems[1].Text = stritem[1];
                    }
                    // 更新日
                    item.SubItems[2].Text = stritem[2];
                    // 内容
                    item.SubItems[3].Text = stritem[3];
                }
            }
            catch(Exception ex)
            {
            }
            finally
            {
            }
        }
    }
    //----------------------------------------------------------------------------------------------------
}//----------------------------------------------------------------------------------------------------
