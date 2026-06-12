using System;
using System.Drawing;
using System.Windows.Forms;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Forms
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// メインアプリケーション画面
    ///
    /// 最上部: 対象施設情報バー（施設変更ボタン）
    /// 上部:   設定表示パネル（読み取り専用 / 設定ボタン）
    /// 中部:   操作モード表示 / 状態表示 / 操作ボタン（開始・中止）
    /// 下部:   左右分割
    ///             左: オンプレ側 実行ログ（プログレスバー + ログ出力）
    ///             右: クラウド側 実行ログ（プログレスバー + ログ出力）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormMain : Form
    {
        private AppLogger           _log;
        private DataMigrationLogic  _logic;
        private bool                _navigatingBack;
        private readonly ToolTip    _settingsToolTip = new ToolTip();

        private IProgress<ProgressInfo> _pgProgress;
        private IProgress<ProgressInfo> _mongoProgress;
        private bool _hasCloudTaskDetail;

        // 実行中アニメーション
        private readonly System.Windows.Forms.Timer _spinnerTimer = new System.Windows.Forms.Timer { Interval = 200 };
        private int _spinnerStep;
        private static readonly string[] SPINNER_FRAMES = { "実行中  |", "実行中  /", "実行中  —", "実行中  \\" };

        public FormMain()
        {
            InitializeComponent();
            this.DoubleBuffered = true;
            _log   = AppLogger.GetInstance();
            _logic = new DataMigrationLogic();
            EnableDoubleBuffer(splitCloud.Panel1);
            EnableDoubleBuffer(splitOnpre.Panel1);
            EnableDoubleBuffer(splitBottom);

            // on2off モード時は左右パネル（オンプレ側 ⇔ クラウド側）を入れ替える
            if (AppState.Instance.CurrentMode == OperationMode.Import)
            {
                SwapSettingsPanels();
                SwapBottomPanels();
            }

            splitSettings.SizeChanged += (s, e) => ApplySettingsSummaryLayout();

            // 設定値を読み取り専用ラベルに反映する
            RefreshSettingsDisplay();

            // 施設情報を表示する
            UpdateFacilityLabel();

            // 操作モードを表示する（タイトルバーにも反映）
            bool isExport = AppState.Instance.CurrentMode == OperationMode.Export;
            string modeStr = isExport ? "\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9" : "\u30af\u30e9\u30a6\u30c9\u2192\u30aa\u30f3\u30d7\u30ec";
            string networkModeStr = AppConfigLoader.IsLanMode ? " [LAN\u30e2\u30fc\u30c9]" : " [WAN\u30e2\u30fc\u30c9]";
            lblMode.Text = "操作モード: ";
            lblModeValue.Text = string.Format("{0}{1}", modeStr, networkModeStr);
            this.Text = isExport
                ? "FutureNetWeb\u207ASi \u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u30b3\u30f3\u30d0\u30fc\u30c8"
                : "FutureNetWeb\u207ASi \u30af\u30e9\u30a6\u30c9\u2192\u30aa\u30f3\u30d7\u30ec\u30b3\u30f3\u30d0\u30fc\u30c8";

            // LAN / WAN モード: ボタン切り替え
            if (AppConfigLoader.IsLanMode)
            {
                btnStart.Visible = false;
                btnLanLeft.Visible  = true;
                btnLanRight.Visible = true;
                if (isExport)
                {
                    // off2on: 左=オンプレ側（緑）、右=クラウド側（青）
                    btnLanLeft.Text      = "\u30aa\u30f3\u30d7\u30ec Export";
                    btnLanRight.Text     = "\u30af\u30e9\u30a6\u30c9 Import";
                }
                else
                {
                    // on2off: パネルが左右反転しているので左=クラウド側（青）、右=オンプレ側（緑）
                    btnLanLeft.Text       = "\u30af\u30e9\u30a6\u30c9 Export";
                    btnLanLeft.BackColor  = System.Drawing.Color.FromArgb(24, 119, 242);
                    btnLanRight.Text      = "\u30aa\u30f3\u30d7\u30ec Import";
                    btnLanRight.BackColor = System.Drawing.Color.FromArgb(46, 139, 87);
                }
            }
            else
            {
                // WAN モード: 1ボタン、モードに応じてテキスト・色を設定
                if (isExport)
                {
                    btnStart.Text      = "\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u5b9f\u884c";
                    btnStart.BackColor = System.Drawing.Color.FromArgb(46, 139, 87);
                }
                else
                {
                    btnStart.Text      = "\u30af\u30e9\u30a6\u30c9\u2192\u30aa\u30f3\u30d7\u30ec\u5b9f\u884c";
                    btnStart.BackColor = System.Drawing.Color.FromArgb(24, 119, 242);
                }
                btnStart.Size = new System.Drawing.Size(160, 34);
            }

            // 進捗コールバックの設定
            _pgProgress = new Progress<ProgressInfo>(info =>
            {
                UpdateProgress(pbPostgres, rtbPgLog, info);
            });
            _mongoProgress = new Progress<ProgressInfo>(info =>
            {
                UpdateProgress(pbMongo, rtbMongoLog, info);
            });

            SetControlButtons(idle: true);
            ResetProgressDisplay();

            // スピナータイマー設定
            _spinnerTimer.Tick += (s, e) =>
            {
                _spinnerStep++;
                lblStatus.Text = "状態: " + SPINNER_FRAMES[_spinnerStep % SPINNER_FRAMES.Length];
            };

            // 件数エリア 22% / ログエリア 78% の比率を動的に維持する
            splitOnpre.SizeChanged += (s, e) => ApplyLogSplitterRatio(splitOnpre);
            splitCloud.SizeChanged += (s, e) => ApplyLogSplitterRatio(splitCloud);

            this.Load += (s, e) =>
            {
                ApplySettingsSummaryLayout();
                ApplyLogSplitterRatio(splitOnpre);
                ApplyLogSplitterRatio(splitCloud);
                _ = LoadCloudSettingsSummaryAsync();
            };
        }

        /// <summary>
        /// on2off モード用: 設定表示 SplitContainer の Panel1（オンプレ側）と Panel2（クラウド側）を入れ替える
        /// </summary>
        private void SwapSettingsPanels()
        {
            var p1Controls = new System.Windows.Forms.Control[splitSettings.Panel1.Controls.Count];
            splitSettings.Panel1.Controls.CopyTo(p1Controls, 0);

            var p2Controls = new System.Windows.Forms.Control[splitSettings.Panel2.Controls.Count];
            splitSettings.Panel2.Controls.CopyTo(p2Controls, 0);

            splitSettings.Panel1.Controls.Clear();
            splitSettings.Panel2.Controls.Clear();

            foreach (var c in p2Controls)
                splitSettings.Panel1.Controls.Add(c);
            foreach (var c in p1Controls)
                splitSettings.Panel2.Controls.Add(c);
        }

        /// <summary>
        /// on2off モード用: splitBottom の Panel1（オンプレ側）と Panel2（クラウド側）を入れ替える
        /// </summary>
        private void SwapBottomPanels()
        {
            var p1Controls = new System.Windows.Forms.Control[splitBottom.Panel1.Controls.Count];
            splitBottom.Panel1.Controls.CopyTo(p1Controls, 0);

            var p2Controls = new System.Windows.Forms.Control[splitBottom.Panel2.Controls.Count];
            splitBottom.Panel2.Controls.CopyTo(p2Controls, 0);

            splitBottom.Panel1.Controls.Clear();
            splitBottom.Panel2.Controls.Clear();

            foreach (var c in p2Controls)
                splitBottom.Panel1.Controls.Add(c);
            foreach (var c in p1Controls)
                splitBottom.Panel2.Controls.Add(c);
        }

        private void ApplyLogSplitterRatio(System.Windows.Forms.SplitContainer sc)
        {
            int minTotal = sc.Panel1MinSize + sc.SplitterWidth + sc.Panel2MinSize;
            if (sc.Width > minTotal)
                sc.SplitterDistance = Math.Max((int)(sc.Width * 0.30), sc.Panel1MinSize);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// AppState の設定値を読み取り専用ラベルへ反映する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void RefreshSettingsDisplay()
        {
            var s = AppState.Instance.Settings;
            SetSettingsValue(lblRdbIpValue, string.IsNullOrEmpty(s.OnpreRdbIpAddress)   ? "(未設定)" : s.OnpreRdbIpAddress);
            SetSettingsValue(lblMongoIpValue, string.IsNullOrEmpty(s.OnpreMongoIpAddress) ? "(未設定)" : s.OnpreMongoIpAddress);
            SetSettingsValue(lblFnsiValue, string.IsNullOrEmpty(s.OnpreFnsiRootFolder) ? "(未設定)" : s.OnpreFnsiRootFolder);
            SetSettingsValue(lblOnpreTmpValue, string.IsNullOrEmpty(s.OnpreTempFolder)     ? "(未設定)" : s.OnpreTempFolder);
            SetSettingsValue(lblCloudTmpValue, AppConfigLoader.ConverterBaseUri + " [確認中...]");
            SetSettingsValue(lblCloudDbValue, "(取得中...)");
            ApplySettingsSummaryLayout();
        }

        private void SetSettingsValue(Label label, string value)
        {
            label.Text = value;
            _settingsToolTip.SetToolTip(label, value);
        }

        private void ApplySettingsSummaryLayout()
        {
            if (splitSettings.Width <= 0)
                return;

            int availableWidth = splitSettings.ClientSize.Width - splitSettings.SplitterWidth;
            if (availableWidth <= 0)
                return;

            int minSplitterDistance = Math.Max(50, splitSettings.Panel1MinSize);
            int maxSplitterDistance = availableWidth - Math.Max(50, splitSettings.Panel2MinSize);
            int splitterDistance = availableWidth / 2;
            splitterDistance = Math.Max(minSplitterDistance, Math.Min(splitterDistance, maxSplitterDistance));

            if (splitterDistance > 0 && splitterDistance < splitSettings.Width - splitSettings.SplitterWidth)
                splitSettings.SplitterDistance = splitterDistance;

            ResizeSettingsValueLabel(lblRdbIpValue);
            ResizeSettingsValueLabel(lblMongoIpValue);
            ResizeSettingsValueLabel(lblFnsiValue);
            ResizeSettingsValueLabel(lblOnpreTmpValue);
            ResizeSettingsValueLabel(lblCloudTmpValue);
            ResizeSettingsValueLabel(lblCloudDbValue);
        }

        private static void ResizeSettingsValueLabel(Label label)
        {
            if (label.Parent == null)
                return;

            int width = label.Parent.ClientSize.Width - label.Left - 8;
            if (width <= 0)
                return;

            label.Width = width;
            label.AutoEllipsis = true;
        }

        private static void EnableDoubleBuffer(Control control)
        {
            if (control == null)
                return;

            typeof(Control).GetProperty("DoubleBuffered",
                    System.Reflection.BindingFlags.Instance | System.Reflection.BindingFlags.NonPublic)
                ?.SetValue(control, true, null);
        }

        private async System.Threading.Tasks.Task LoadCloudSettingsSummaryAsync()
        {
            try
            {
                var client = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
                using (var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(5)))
                {
                    ConverterServerHealth health = await client.GetServerHealthAsync(cts.Token);
                    string serverStatusText = BuildServerStatusText(health);
                    SetSettingsValue(lblCloudTmpValue,
                        string.Format("{0} [{1}]", AppConfigLoader.ConverterBaseUri, serverStatusText));

                    try
                    {
                        ConverterSystemInfo systemInfo = await client.GetSystemInfoAsync(cts.Token);
                        SetSettingsValue(lblCloudDbValue,
                            string.Format("{0}:{1}", systemInfo.ConverterDbHost, systemInfo.ConverterDbPort));
                    }
                    catch
                    {
                        SetSettingsValue(lblCloudDbValue, "(取得失敗)");
                    }
                }
            }
            catch
            {
                SetSettingsValue(lblCloudTmpValue,
                    string.Format("{0} [未接続]", AppConfigLoader.ConverterBaseUri));
                SetSettingsValue(lblCloudDbValue, "(取得失敗)");
            }

            ApplySettingsSummaryLayout();
        }

        private static string BuildServerStatusText(ConverterServerHealth health)
        {
            if (health == null || !health.IsReachable)
                return "未接続";

            if (string.Equals(health.Status, "UP", StringComparison.OrdinalIgnoreCase))
                return "接続OK";

            if (string.IsNullOrWhiteSpace(health.Status))
                return "接続OK";

            return "接続OK/" + health.Status;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設ラベルを更新する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void UpdateFacilityLabel()
        {
            var facilities = AppState.Instance.SelectedFacilities;
            if (facilities.Count == 0)
            {
                lblFacilities.Text = "対象施設: (未選択)";
            }
            else if (facilities.Count <= 3)
            {
                var names = new System.Text.StringBuilder();
                foreach (var f in facilities)
                {
                    if (names.Length > 0) names.Append("、");
                    names.Append(f.FacilityName);
                }
                lblFacilities.Text = string.Format("対象施設: {0}件  [{1}]", facilities.Count, names);
            }
            else
            {
                lblFacilities.Text = string.Format("対象施設: {0}件", facilities.Count);
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// プログレスバーとログ出力エリアを更新する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void UpdateProgress(ProgressBarEx pb, RichTextBox rtb, ProgressInfo info)
        {
            if (info.Percentage >= 0)
                pb.Value = Math.Min(info.Percentage, 100);

            if (info.IsError)
                pb.IsError = true;

            // 件数更新の場合はログ出力をスキップして件数ラベルだけ更新する
            if (info.IsCountUpdate)
            {
                UpdateCountLabel(info.CountKey, info.CountTotal, info.CountDone, info.CountText);
                return;
            }

            if (string.IsNullOrWhiteSpace(info.Message))
                return;

            DateTime now = DateTime.Now;
        string line;
        string rawLine;
        if (info.IsPreformattedLogLine)
        {
            line = info.Message + Environment.NewLine;
            rawLine = string.IsNullOrWhiteSpace(info.RawMessage)
                ? line
                : info.RawMessage + Environment.NewLine;
        }
        else
        {
            string timestamp = now.ToString("HH:mm:ss");
            line = string.Format("[{0}] {1}{2}", timestamp, info.Message, Environment.NewLine);
            rawLine = line;
        }

            if (!string.IsNullOrEmpty(info.Message))
            {
                if (!info.IsPreformattedLogLine)
                {
                    var logClass = info.IsError
                        ? AppLogger.LOGGING_CLASS.ERROR
                        : AppLogger.LOGGING_CLASS.INFO;
                    _log.AddLogInfo(now, "FNSICloudConvertClient", logClass, info.Message);
                }
            _log.AddRawLine(now, rawLine.TrimEnd('\r', '\n'));
        }

            rtb.AppendText(line);
            rtb.ScrollToCaret();

            if (info.IsError)
            {
                int start = rtb.TextLength - line.Length;
                rtb.Select(start, line.Length);
                rtb.SelectionColor = Color.Red;
                rtb.SelectionLength = 0;
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 件数ラベルを更新する（オンプレ処理件数エリア）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private int _countDb4Total, _countDb4Done;
        private int _countDb5Total, _countDb5Done;
    private int _countDb6Total, _countDb6Done;
    private int _countMongoTotal, _countMongoDone;
    private int _countCloudTaskTotal, _countCloudTaskDone;
    private string _lastCloudCountText = "---";

        private void UpdateCountLabel(string key, int total, int done, string countText)
        {
            switch (key)
            {
                case "db4":        _countDb4Total = total;       _countDb4Done = done;       break;
                case "db5":        _countDb5Total = total;       _countDb5Done = done;       break;
                case "db6":        _countDb6Total = total;       _countDb6Done = done;       break;
                case "mongo":      _countMongoTotal = total;     _countMongoDone = done;     break;
            case "cloud_task": _countCloudTaskTotal = total; _countCloudTaskDone = done; break;
            case "cloud_task_detail":
                if (!string.IsNullOrWhiteSpace(countText)
                    && !string.Equals(_lastCloudCountText, countText, StringComparison.Ordinal))
                {
                    lblCloudCount.Text = countText;
                    _lastCloudCountText = countText;
                    _hasCloudTaskDetail = true;
                }
                return;
        }

        if (key == "cloud_task")
        {
            if (_hasCloudTaskDetail)
                return;

            string summaryText = string.Format(
                "タスク: {0}/{1}", _countCloudTaskDone, _countCloudTaskTotal);
            if (!string.Equals(_lastCloudCountText, summaryText, StringComparison.Ordinal))
            {
                lblCloudCount.Text = summaryText;
                    _lastCloudCountText = summaryText;
                }
                return;
            }

            lblOnpreCount.Text = string.Format(
                "DB4:  {0}/{1}\nDB5:  {2}/{3}\nDB6:  {4}/{5}\nMongo:{6}/{7}",
                _countDb4Done,   _countDb4Total,
                _countDb5Done,   _countDb5Total,
                _countDb6Done,   _countDb6Total,
                _countMongoDone, _countMongoTotal);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 進捗表示・カウンタを初期状態にリセットする
        /// 起動時と開始ボタン押下時にのみ呼ぶ（完了後はリセットしない）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void ResetProgressDisplay()
        {
            lblStatus.Text           = "状態: 待機中";
            lblStatus.ForeColor      = Color.Black;
            pnlStatusRow.BackColor = Color.FromArgb(180, 180, 180); // 灰: 待機中
            pbPostgres.Reset();
            pbMongo.Reset();
            _countDb4Total = _countDb4Done = 0;
            _countDb5Total = _countDb5Done = 0;
            _countDb6Total = _countDb6Done = 0;
        _countMongoTotal = _countMongoDone = 0;
        _countCloudTaskTotal = _countCloudTaskDone = 0;
        lblOnpreCount.Text = "DB4: ---\nDB5: ---\nDB6: ---\nMongo: ---";
        lblCloudCount.Text = "---";
        _lastCloudCountText = "---";
        _hasCloudTaskDetail = false;
    }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 操作ボタンの有効 / 無効を切り替える
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void SetControlButtons(bool idle)
        {
            btnStart.Enabled          = idle;
            btnLanLeft.Enabled        = idle;
            btnLanRight.Enabled       = idle;
            btnStop.Enabled           = !idle;
            btnSettings.Enabled       = idle;
            btnChangeFacility.Enabled = idle;

            if (idle)
            {
                _spinnerTimer.Stop();
                // 表示リセットはここでは行わない（完了後も結果を表示し続ける）
                // リセットは起動時と開始ボタン押下時のみ（ResetProgressDisplay 参照）
            }
            else
            {
                _spinnerStep             = 0;
                lblStatus.ForeColor      = Color.Blue;
                pnlStatusRow.BackColor = Color.FromArgb(24, 119, 242); // 青: 実行中
                _spinnerTimer.Start();
            }
        }

        // --------------------------------------------------
        // 設定値ラベルクリック（どのラベルをクリックしても設定画面を開く）
        // --------------------------------------------------
        private void lblSettingsValue_Click(object sender, EventArgs e)
        {
            btnSettings_Click(sender, e);
        }

        // --------------------------------------------------
        // [設定...] ボタン押下
        // --------------------------------------------------
        private void btnSettings_Click(object sender, EventArgs e)
        {
            string oldRdbIp = AppState.Instance.Settings.OnpreRdbIpAddress;

            var form = new FormSettings();
            if (form.ShowDialog(this) != DialogResult.OK)
                return;

            // 設定表示を更新する
            RefreshSettingsDisplay();
            _ = LoadCloudSettingsSummaryAsync();

            // Export モードで RDB IP が変更された場合は施設の再選択を促す
            if (AppState.Instance.CurrentMode == OperationMode.Export &&
                oldRdbIp != AppState.Instance.Settings.OnpreRdbIpAddress)
            {
                var result = MessageBox.Show(
                    "RDB IPアドレスが変更されました。\n選択済み施設はクリアされます。\n施設を再選択しますか？",
                    "施設の再選択が必要です",
                    MessageBoxButtons.YesNo,
                    MessageBoxIcon.Warning);

                if (result == DialogResult.Yes)
                {
                    AppState.Instance.SelectedFacilities.Clear();
                    UpdateFacilityLabel();
                    var facilityForm = new FormFacilitySelect();
                    if (facilityForm.ShowDialog(this) == DialogResult.OK)
                        UpdateFacilityLabel();
                }
            }
        }

        // --------------------------------------------------
        // [施設変更...] ボタン押下
        // --------------------------------------------------
        private void btnChangeFacility_Click(object sender, EventArgs e)
        {
            var form = new FormFacilitySelect();
            if (form.ShowDialog(this) == DialogResult.OK)
                UpdateFacilityLabel();
        }

        // --------------------------------------------------
        // [開始] ボタン押下
        // --------------------------------------------------
        private async void btnStart_Click(object sender, EventArgs e)
        {
            // ログ・進捗表示をリセットしてから開始
            rtbPgLog.Clear();
            rtbMongoLog.Clear();
            ResetProgressDisplay();

            SetControlButtons(idle: false);

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("移行処理開始: モード={0}", AppState.Instance.CurrentMode));

            try
            {
                var facilities = AppState.Instance.SelectedFacilities;
                var settings   = AppState.Instance.Settings;

                if (AppState.Instance.CurrentMode == OperationMode.Export)
                    await _logic.RunExportAsync(facilities, settings, _pgProgress, _mongoProgress);
                else
                    await _logic.RunImportAsync(facilities, settings, _pgProgress, _mongoProgress);

                // スピナーを先に止めてからラベルをセット（MessageBox中もTimerが動くため）
                SetControlButtons(idle: true);
                lblStatus.Text           = "状態: 完了";
                lblStatus.ForeColor      = Color.Green;
                pnlStatusRow.BackColor = Color.FromArgb(46, 139, 87); // 緑: 完了

                MessageBox.Show(
                    "処理が完了しました。",
                    "完了",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Information);
            }
            catch (OperationCanceledException)
            {
                lblStatus.Text           = "状態: キャンセル";
                lblStatus.ForeColor      = Color.OrangeRed;
                pnlStatusRow.BackColor = Color.OrangeRed; // オレンジ: キャンセル
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("移行処理エラー: {0}", ex.Message));

                SetControlButtons(idle: true);
                lblStatus.Text           = "状態: エラー";
                lblStatus.ForeColor      = Color.Red;
                pnlStatusRow.BackColor = Color.FromArgb(178, 34, 34); // 赤: エラー

                MessageBox.Show(
                    string.Format("処理中にエラーが発生しました。\n{0}", ex.Message),
                    "エラー",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                SetControlButtons(idle: true);
            }
        }

        // --------------------------------------------------
        // [LAN左] ボタン押下（off2on: オンプレExport / on2off: クラウドExport）
        // --------------------------------------------------
        private async void btnLanLeft_Click(object sender, EventArgs e)
        {
            rtbPgLog.Clear();
            rtbMongoLog.Clear();
            ResetProgressDisplay();
            SetControlButtons(idle: false);

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("[LAN] 左ボタン実行: モード={0}", AppState.Instance.CurrentMode));

            try
            {
                var facilities = AppState.Instance.SelectedFacilities;
                var settings   = AppState.Instance.Settings;

                if (AppState.Instance.CurrentMode == OperationMode.Export)
                    await _logic.RunExportOnpreAsync(facilities, settings, _pgProgress, _mongoProgress);
                else
                    await _logic.RunImportCloudAsync(facilities, settings, _pgProgress, _mongoProgress);

                SetControlButtons(idle: true);
                lblStatus.Text           = "状態: 完了";
                lblStatus.ForeColor      = System.Drawing.Color.Green;
                pnlStatusRow.BackColor   = System.Drawing.Color.FromArgb(46, 139, 87);

                if (AppState.Instance.CurrentMode == OperationMode.Export
                    && !AppState.Instance.IsConverterAuthenticated)
                {
                    MessageBox.Show(
                        "Export完了。ネットワークを切り替え、サインインURLを再設定し、再ログイン後にクラウド実行を押してください。",
                        "Export完了",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Information);
                }
                else
                {
                    MessageBox.Show("処理が完了しました。", "完了", MessageBoxButtons.OK, MessageBoxIcon.Information);
                }
            }
            catch (OperationCanceledException)
            {
                lblStatus.Text         = "状態: キャンセル";
                lblStatus.ForeColor    = System.Drawing.Color.OrangeRed;
                pnlStatusRow.BackColor = System.Drawing.Color.OrangeRed;
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("[LAN] 左ボタンエラー: {0}", ex.Message));
                SetControlButtons(idle: true);
                lblStatus.Text         = "状態: エラー";
                lblStatus.ForeColor    = System.Drawing.Color.Red;
                pnlStatusRow.BackColor = System.Drawing.Color.FromArgb(178, 34, 34);
                MessageBox.Show(string.Format("処理中にエラーが発生しました。\n{0}", ex.Message),
                    "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                SetControlButtons(idle: true);
            }
        }

        // --------------------------------------------------
        // [LAN右] ボタン押下（off2on: クラウドImport / on2off: オンプレImport）
        // --------------------------------------------------
        private async void btnLanRight_Click(object sender, EventArgs e)
        {
            rtbPgLog.Clear();
            rtbMongoLog.Clear();
            ResetProgressDisplay();
            SetControlButtons(idle: false);

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("[LAN] 右ボタン実行: モード={0}", AppState.Instance.CurrentMode));

            try
            {
                var facilities = AppState.Instance.SelectedFacilities;
                var settings   = AppState.Instance.Settings;

                if (AppState.Instance.CurrentMode == OperationMode.Export)
                    await _logic.RunExportCloudAsync(facilities, settings, _pgProgress, _mongoProgress);
                else
                    await _logic.RunImportOnpreAsync(facilities, settings, _pgProgress, _mongoProgress);

                SetControlButtons(idle: true);
                lblStatus.Text           = "状態: 完了";
                lblStatus.ForeColor      = System.Drawing.Color.Green;
                pnlStatusRow.BackColor   = System.Drawing.Color.FromArgb(46, 139, 87);

                MessageBox.Show("処理が完了しました。", "完了", MessageBoxButtons.OK, MessageBoxIcon.Information);
            }
            catch (OperationCanceledException)
            {
                lblStatus.Text         = "状態: キャンセル";
                lblStatus.ForeColor    = System.Drawing.Color.OrangeRed;
                pnlStatusRow.BackColor = System.Drawing.Color.OrangeRed;
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("[LAN] 右ボタンエラー: {0}", ex.Message));
                SetControlButtons(idle: true);
                lblStatus.Text         = "状態: エラー";
                lblStatus.ForeColor    = System.Drawing.Color.Red;
                pnlStatusRow.BackColor = System.Drawing.Color.FromArgb(178, 34, 34);
                MessageBox.Show(string.Format("処理中にエラーが発生しました。\n{0}", ex.Message),
                    "エラー", MessageBoxButtons.OK, MessageBoxIcon.Error);
            }
            finally
            {
                SetControlButtons(idle: true);
            }
        }

        // --------------------------------------------------
        // [中止] ボタン押下
        // --------------------------------------------------
        private void btnStop_Click(object sender, EventArgs e)
        {
            using (var dlg = new FormStopDialog())
            {
                var result = dlg.ShowDialog(this);
                if (result == DialogResult.Yes)
                {
                    _logic.Cancel();
                }
            }
        }

        // --------------------------------------------------
        // 操作モードラベルクリック → 確認後にモード選択画面へ戻る
        // --------------------------------------------------
        private void lblModeValue_Click(object sender, EventArgs e)
        {
            // 実行中は切り替え不可
            if (!btnStart.Enabled && !btnLanLeft.Enabled)
                return;

            var result = MessageBox.Show(
                "操作モードを切り替えますか？\n現在の画面を閉じて、モード選択画面に戻ります。",
                "操作モード切り替え",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (result != DialogResult.Yes)
                return;

            // 隠れている FormSelectMode を探して再表示する
            foreach (Form f in Application.OpenForms)
            {
                if (f is FormSelectMode selectModeForm)
                {
                    AppState.Instance.CurrentMode = OperationMode.None;
                    AppState.Instance.SelectedFacilities.Clear();
                    _navigatingBack = true;
                    selectModeForm.Show();
                    this.Close();
                    return;
                }
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォームクローズ時: モード切り替えによる遷移でなければアプリケーション終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void FormMain_FormClosed(object sender, FormClosedEventArgs e)
        {
            if (!_navigatingBack)
                Application.Exit();
        }
    }
}
