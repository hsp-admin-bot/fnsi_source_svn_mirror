//----------------------------------------------------------------------------------------------------
//　GUI画面用クラス定義
//----------------------------------------------------------------------------------------------------
using System;
using System.Collections.Generic;
using System.IO;
using System.ServiceProcess;
using System.Threading;
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
//  名前空間:NKKAccessCardTool
//----------------------------------------------------------------------------------------------------
namespace NKKAccessCardTool
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
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe start
        private readonly String LOG_FILE_EXT = "AccessCardTool";
        // mod #9696 アプリケーションログのパスとファイル名の修正。 limingzhe end
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイル名
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private readonly String CONFIG_FILE_NAME = "NKKAccessCardTool.config";
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
        private const string APP_DISPLAY_NAME = "FNWeb⁺Si カード保守ツール";
        private const string TRAY_STATUS_RUNNING = "FNWSiカードアプリ処理中";
        private const string TRAY_STATUS_STOPPED = "FNWSiカードアプリ停止中";
        private const string CARD_SERVICE_NAME = "FNWebSi カードサービス";
        private const string CARD_SERVICE_INTERNAL_NAME = "NKKAccessCardService";
        private const string RESTART_FLAG_FILE_NAME = "FNWSiAccessCardTool.restart.flag";
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
        /// <summary>
        /// サービスから再起動指示を受信したか
        /// </summary>
        private bool m_restartRequested = false;
        /// <summary>同一プロセス内で再起動ウォッチャーを二重起動しない</summary>
        private static int s_restartWatcherLaunched = 0;
        //----------------------------------------------------------------------------------------------------
        // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　start
        /// <summary>
        /// フラグ
        /// </summary>
        private bool flg = false;
        // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　end
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// GUI待受への接続用クライアントソケットオブジェクト
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private TdcBaseSocketClient m_soc = new TdcBaseSocketClient(1024);
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 前回画面更新日時
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private DateTime m_BeforeRefreshDateTime = DateTime.MinValue;
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        ///  コンストラクタ
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public FormGUI()
        {
            InitializeComponent();

            // add #12227 カードアプリ＆ツール　アイコン差し替え 高 start
            this.Icon = Properties.Resources.NKKAccessCardService;
            // add #12227 カードアプリ＆ツール　アイコン差し替え 高 end

            // 画面タイトル取得
            this.Text = APP_DISPLAY_NAME;
            this.m_strAppTitle = this.Text;

            // 起動時は最小状態でタスクバーに表示されないように設定
            this.WindowState = FormWindowState.Minimized;
            this.ShowInTaskbar = false;

            // 
            this.notifyIcon.Icon = this.Icon;
            // 起動直後は未接続想定
            this.UpdateTrayStatusText(false);
            // Explorer 側の通知領域アイコンキャッシュにより、再起動直後に表示されないことがあるため明示的に再表示する
            this.notifyIcon.Visible = false;
            this.notifyIcon.Visible = true;

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
                item.SubItems[3].Text = CARD_SERVICE_NAME + "と未接続";
            }


            // ログ設定
            NKKLogging log = NKKLogging.GetInstance();

            //mod  20210908 #5967 値を変更する  鄭  start
            //  識別子
            // log.LogExt = this.LOG_FILE_EXT;
            log.LogExt = $"{LOG_FILE_EXT}_{System.Net.Dns.GetHostName()}";
            //mod  20210908 #5967 値を変更する  鄭  start

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
            if (Int32.TryParse(sys.GetSingleLineValue(CONFIG_GUI_SECTION, "PortNo", String.Empty).Trim(), out nwork) && 0 < nwork)
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

        /// <summary>
        /// 通知アイコン文言更新
        /// </summary>
        /// <param name="isRunning">処理中の場合 true</param>
        //----------------------------------------------------------------------------------------------------
        private void UpdateTrayStatusText(bool isRunning)
        {
            bool serviceRunning = isRunning;
            try
            {
                using (ServiceController service = new ServiceController(CARD_SERVICE_INTERNAL_NAME))
                {
                    service.Refresh();
                    serviceRunning = service.Status == ServiceControllerStatus.Running
                                     || service.Status == ServiceControllerStatus.StartPending
                                     || service.Status == ServiceControllerStatus.ContinuePending;
                }
            }
            catch
            {
                // Fall back to socket-based status when service query fails.
            }

            string trayStatusText = serviceRunning ? TRAY_STATUS_RUNNING : TRAY_STATUS_STOPPED;

            // 悬浮名称按服务状态显示
            this.notifyIcon.Text = trayStatusText;
            this.notifyIcon.BalloonTipText = trayStatusText;
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 自動更新後に GUI ツールを再起動するためのウォッチャーを起動する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void StartRestartWatcher()
        {
            try
            {
                if (Interlocked.CompareExchange(ref s_restartWatcherLaunched, 1, 0) != 0)
                {
                    WriteRestartTrace("StartRestartWatcher skipped (already launched in this process).");
                    return;
                }

                string exePath = Application.ExecutablePath;
                string flagPath = this.GetRestartFlagPath();
                string tracePath = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "FNWSiAccessCardTool.restart.log");
                DateTime baselineWriteTimeUtc = File.Exists(exePath) ? File.GetLastWriteTimeUtc(exePath) : DateTime.MinValue;
                // サービス側 Updater が msiexec /l*v に渡すログ（NKKCommon.Updater と同じ相対パス）
                string installDir = Path.GetDirectoryName(exePath) ?? string.Empty;
                string msiLogPath = Path.GetFullPath(Path.Combine(installDir, "..", "SelfUpdate", "FNWSiAccessCard", "update.log"));
                string msiLogPs = msiLogPath.Replace("'", "''");
                WriteRestartTrace("StartRestartWatcher begin. exe=" + exePath + ", trace=" + tracePath + ", msiLog=" + msiLogPath);

                // 再起動ウォッチャー用 PowerShell: ①msiexec 未検出で長時間空待ちしない ②他プロセスの msiexec が残っても、自製品 MSI ログに成功行が出たら待機終了
                string script = "$exe='" + exePath.Replace("'", "''") + "';" +
                                "$flag='" + flagPath.Replace("'", "''") + "';" +
                                "$log='" + tracePath.Replace("'", "''") + "';" +
                                "$msiLog='" + msiLogPs + "';" +
                                "$baseline=[datetime]::Parse('" + baselineWriteTimeUtc.ToString("o") + "');" +
                                "function Log($m){ try { Add-Content -Path $log -Value ((Get-Date -Format 'yyyy-MM-dd HH:mm:ss.fff') + ' ' + $m) } catch {} };" +
                                "Log 'watcher started';" +
                                "$initLogT=$null; if(Test-Path -LiteralPath $msiLog){ $initLogT=(Get-Item -LiteralPath $msiLog).LastWriteTimeUtc };" +
                                "$seenMsi=$false;" +
                                "for($i=0;$i -lt 360;$i++){" +
                                "  if(Get-Process msiexec -ErrorAction SilentlyContinue){ $seenMsi=$true; break };" +
                                "  Start-Sleep -Milliseconds 500" +
                                "};" +
                                "if(-not $seenMsi){ Log 'msiexec not seen in 180s, proceed without msi wait' };" +
                                "if($seenMsi){" +
                                "  for($k=0;$k -lt 1800;$k++){" +
                                "    $msiHas=$null -ne (Get-Process msiexec -ErrorAction SilentlyContinue);" +
                                "    $logDone=$false;" +
                                "    if((($k % 5) -eq 0) -and (Test-Path -LiteralPath $msiLog)){" +
                                "      $lw=(Get-Item -LiteralPath $msiLog).LastWriteTimeUtc;" +
                                "      if(($null -eq $initLogT) -or ($lw -gt $initLogT)){" +
                                "        $__t=(Get-Content -LiteralPath $msiLog -Tail 200 -ErrorAction SilentlyContinue | Out-String);" +
                                "        if($__t -match 'Installation completed successfully|MainEngineThread is returning 0'){ $logDone=$true; Log 'msi log reports install success' }" +
                                "      }" +
                                "    };" +
                                "    if((-not $msiHas) -or $logDone){ break };" +
                                "    Start-Sleep -Milliseconds 400" +
                                "  }" +
                                "};" +
                                "Log ('msiexec wait finished, seen=' + $seenMsi);" +
                                "Start-Sleep -Seconds 1;" +
                                "for($j=0;$j -lt 40;$j++){" +
                                "  if(Test-Path $exe){" +
                                "    $w=(Get-Item $exe).LastWriteTimeUtc;" +
                                "    $force=($seenMsi -and $j -ge 2);" +
                                "    if($force -or $w -gt $baseline -or -not $seenMsi){" +
                                "      try{ if(Test-Path $flag){ Remove-Item -Path $flag -Force -ErrorAction SilentlyContinue }; Start-Process -FilePath $exe; Log ('restart success, writeTime=' + $w.ToString('o') + ', forced=' + $force); break } catch { Log ('restart failed: ' + $_.Exception.Message) }" +
                                "    } else { Log ('waiting exe update, writeTime=' + $w.ToString('o')) }" +
                                "  } else { Log 'exe not found' };" +
                                "  Start-Sleep -Milliseconds 800" +
                                "}";
                string encoded = Convert.ToBase64String(Encoding.Unicode.GetBytes(script));

                using (System.Diagnostics.Process restartProc = new System.Diagnostics.Process())
                {
                    restartProc.StartInfo.FileName = "powershell.exe";
                    restartProc.StartInfo.Arguments = "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -EncodedCommand " + encoded;
                    restartProc.StartInfo.CreateNoWindow = true;
                    restartProc.StartInfo.UseShellExecute = false;
                    restartProc.Start();
                }
                WriteRestartTrace("StartRestartWatcher powershell launched.");
            }
            catch (Exception ex)
            {
                WriteRestartTrace("StartRestartWatcher exception: " + ex.Message);
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 自動更新再起動のトレースログ出力
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void WriteRestartTrace(string message)
        {
            try
            {
                string tracePath = System.IO.Path.Combine(System.IO.Path.GetTempPath(), "FNWSiAccessCardTool.restart.log");
                string line = string.Format("{0:yyyy-MM-dd HH:mm:ss.fff} {1}", DateTime.Now, message);
                System.IO.File.AppendAllText(tracePath, line + Environment.NewLine, Encoding.UTF8);
            }
            catch
            {
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再起動フラグファイルのパスを取得
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private string GetRestartFlagPath()
        {
            string restartFlagFolder = Path.Combine(
                Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData),
                "NIKKISO",
                "FNWSiAccessCard");
            return Path.Combine(restartFlagFolder, RESTART_FLAG_FILE_NAME);
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再起動フラグを削除
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void TryDeleteRestartFlag()
        {
            try
            {
                string flagPath = this.GetRestartFlagPath();
                if (File.Exists(flagPath))
                {
                    File.Delete(flagPath);
                    WriteRestartTrace("Restart flag deleted: " + flagPath);
                }
            }
            catch (Exception ex)
            {
                WriteRestartTrace("Restart flag delete failed: " + ex.Message);
            }
        }
        //----------------------------------------------------------------------------------------------------

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 再起動フラグを1回だけ消費する（削除成功時のみ true）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private bool TryConsumeRestartFlag(out string flagPath)
        {
            flagPath = this.GetRestartFlagPath();
            try
            {
                if (File.Exists(flagPath) == false)
                {
                    return false;
                }

                File.Delete(flagPath);
                WriteRestartTrace("Restart flag consumed: " + flagPath);
                return true;
            }
            catch (Exception ex)
            {
                WriteRestartTrace("Restart flag consume failed: " + ex.Message + ", path=" + flagPath);
                return false;
            }
        }
        //----------------------------------------------------------------------------------------------------

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

                // 更新フラグがある場合は、サービス更新中と判断して GUI 再起動フローへ移行する。
                try
                {
                    string flagPath;
                    bool consumedRestartFlag = this.TryConsumeRestartFlag(out flagPath);
                    bool wasRestartRequested = this.m_restartRequested;
                    bool restartSignal = consumedRestartFlag || wasRestartRequested;
                    this.m_restartRequested = false;
                    if (restartSignal)
                    {
                        WriteRestartTrace(
                            "Service disconnect with upgrade signal. Start watcher. " +
                            "flagConsumed=" + consumedRestartFlag.ToString() + ", restartRequested=" + wasRestartRequested.ToString() +
                            ", path=" + flagPath);
                        this.StartRestartWatcher();
                        this.m_bExit = true;
                        this.notifyIcon.Visible = false;
                        this.Close();
                        return;
                    }
                }
                catch (Exception exFlag)
                {
                    WriteRestartTrace("Restart flag check failed: " + exFlag.Message);
                }

                DateTime dtnow = DateTime.Now;
                StringBuilder sbwork = new StringBuilder();

                // 保持要素すべてが対象
                foreach (KeyValuePair<String, String> item in this.m_lstViewLogInfo)
                {
                    // 項目の分割
                    String[] stritems = item.Value.Split('\t');

                    // 状態
                    stritems[1] = "不明";
                    // 内容
                    stritems[3] = CARD_SERVICE_NAME + "から切断";

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
                this.m_restartRequested = false;
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
        private void ReceivedMessage(Object sender, Byte[] cRecvData, int nRecvSize)
        {
            // 受信データの文字列化
            String strdata = Encoding.UTF8.GetString(cRecvData, 0, nRecvSize);
            WriteRestartTrace("ReceivedMessage raw: " + strdata.Replace("\r", "\\r").Replace("\n", "\\n"));

            // 電文の分割
            String[] stritems = strdata.Split(new String[] { "\r\n" }, StringSplitOptions.RemoveEmptyEntries);
            foreach (String strline in stritems)
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

                // 受信コマンド（RESTART/EXIT 含む）は表示状態に関係なく処理する
                this.BeginInvoke((MethodInvoker)delegate ()
                {
                    ShowListView(strline);
                });
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
            // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　start
            if (flg)
            {
                return;
            }
            flg = true;
            // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　end

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

            // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　start
            flg = false;
            // add #8798 連続で終了ボタンを押下すると、複数回ポップアップ画面が表示される 董昊　end
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
        private void ShowListView(String strData)
        {
            try
            {
                // データの分割
                String[] stritem = strData.Split('\t');

                // データ表示
                int nidx = -1;
                switch (stritem[0].ToUpper())
                {
                    case "RESTART":
                        // 自動更新シナリオ: 先に再起動ウォッチャーを仕込み、自身を終了する。
                        WriteRestartTrace("ShowListView RESTART received.");
                        this.m_restartRequested = true;
                        this.StartRestartWatcher();
                        this.m_bExit = true;
                        this.notifyIcon.Visible = false;
                        this.Close();
                        break;

                    case "EXIT":
                        WriteRestartTrace("ShowListView EXIT received.");
                        // Keep tray resident: do not close tool when service requests EXIT.
                        // Switch to stopped state and try reconnect.
                        this.m_bExit = false;
                        this.UpdateTrayStatusText(false);
                        try
                        {
                            this.m_soc.Close();
                            this.m_soc.StartConnect();
                        }
                        catch
                        {
                        }
                        break;

                    case "INFO":
                        this.Text = String.Format("{0}：{1}", this.m_strAppTitle, stritem[3]);
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
                }
                if (0 <= nidx && nidx < this.listView.Items.Count)
                {
                    ListViewItem item = this.listView.Items[nidx];

                    // 状態
                    if (String.IsNullOrWhiteSpace(stritem[1]) == false)
                    {
                        item.SubItems[1].Text = stritem[1];
                    }
                    // 更新日
                    item.SubItems[2].Text = stritem[2];
                    // 内容
                    item.SubItems[3].Text = stritem[3];
                }
            }
            catch (Exception ex)
            {
            }
            finally
            {
            }
        }
    }
    //----------------------------------------------------------------------------------------------------
}//----------------------------------------------------------------------------------------------------
