using System;
using System.Collections.Generic;
using System.Drawing;
using System.Threading.Tasks;
using System.Windows.Forms;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;


namespace FNSICloudConvertClient.Forms
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 施設選択画面
    /// 左側: 選択済み施設を DOM 行形式で表示（各行に削除ボタン）＋末尾に追加行
    /// 右側: 未選択施設一覧パネル（追加行クリックで展開）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormFacilitySelect : Form
    {
        private AppLogger _log;

        // 行の高さ・区切り線の高さ
        private const int ROW_HEIGHT = 36;
        private const int SEP_HEIGHT = 1;

        private readonly int _collapsedClientWidth;
        private readonly int _expandedClientWidth;
        private readonly int _rowHeight;
        private readonly int _separatorHeight;

        public FormFacilitySelect()
        {
            InitializeComponent();
            _log = AppLogger.GetInstance();

            _collapsedClientWidth = pnlLeft.Right + pnlLeft.Left;
            _expandedClientWidth  = pnlRight.Right + pnlLeft.Left;
            _rowHeight            = ScaleLogicalY(ROW_HEIGHT);
            _separatorHeight      = System.Math.Max(1, ScaleLogicalY(SEP_HEIGHT));

            // 初期表示は左パネルのみ
            SetRightPanelVisible(false);

            // LAN モード時のみ手入力ボタンを表示する
            btnManualInput.Visible = AppConfigLoader.IsLanMode;

            // AppState の選択済みリストを行として描画する
            BuildSelectedRows();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 選択済み施設をDOMライクな行スタイルで pnlSelectedContent に描画する
        /// 末尾に「＋ 施設を追加...」行を追加する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フッターボタンの表示・活性状態を更新する
        /// 右パネル表示中: 選択ボタンのみ / 右パネル非表示: 確定ボタンのみ（選択数に応じて活性）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void UpdateFooterButtons()
        {
            bool rightOpen = pnlRight.Visible;
            bool hasItems  = AppState.Instance.SelectedFacilities.Count > 0;

            // 確定 / 選択 は右パネルの状態で切り替え（同位置・同サイズ）
            btnConfirm.Visible = !rightOpen;
            btnSelect.Visible  = rightOpen;
            btnConfirm.Enabled   = hasItems;
            btnConfirm.BackColor = hasItems
                ? System.Drawing.Color.FromArgb(24, 119, 242)
                : System.Drawing.Color.FromArgb(180, 180, 180);
        }

        private void SetRightPanelVisible(bool visible)
        {
            pnlRight.Visible = visible;
            this.ClientSize  = new Size(
                visible ? _expandedClientWidth : _collapsedClientWidth,
                this.ClientSize.Height);
            UpdateFooterButtons();
        }

        private int ScaleLogicalX(int logicalPixels)
        {
            return (int)System.Math.Round(logicalPixels * (CurrentAutoScaleDimensions.Width / AutoScaleDimensions.Width));
        }

        private int ScaleLogicalY(int logicalPixels)
        {
            return (int)System.Math.Round(logicalPixels * (CurrentAutoScaleDimensions.Height / AutoScaleDimensions.Height));
        }

        private void BuildSelectedRows()
        {
            // 既存コントロールを破棄・クリア
            var old = new List<Control>();
            foreach (Control c in pnlSelectedContent.Controls) old.Add(c);
            pnlSelectedContent.Controls.Clear();
            foreach (Control c in old) c.Dispose();

            int rowW = pnlSelectedContent.ClientSize.Width;
            int y    = 0;

            foreach (var facility in AppState.Instance.SelectedFacilities)
            {
                // --------------------------------------------------
                // 施設行パネル
                // --------------------------------------------------
                var row = new Panel
                {
                    Location  = new Point(0, y),
                    Size      = new Size(rowW, _rowHeight),
                    BackColor = Color.White,
                };

                // 施設CD＋施設名ラベル
                var lbl = new Label
                {
                    Location  = new Point(ScaleLogicalX(12), 0),
                    Size      = new Size(System.Math.Max(0, rowW - ScaleLogicalX(84)), _rowHeight),
                    Text      = string.Format("{0}\u3000{1}", facility.FacilityCd, facility.FacilityName),
                    Font      = new Font("MS UI Gothic", 10F),
                    TextAlign = ContentAlignment.MiddleLeft,
                    ForeColor = Color.FromArgb(30, 30, 30),
                };

                // 削除ボタン（右端）
                var btnDel = new Button
                {
                    Location  = new Point(rowW - ScaleLogicalX(66), (_rowHeight - ScaleLogicalY(24)) / 2),
                    Size      = new Size(ScaleLogicalX(54), ScaleLogicalY(24)),
                    Text      = "\u524a\u9664",
                    Font      = new Font("MS UI Gothic", 9F),
                    FlatStyle = FlatStyle.Flat,
                    BackColor = Color.FromArgb(220, 222, 226),
                    ForeColor = Color.FromArgb(60, 60, 60),
                    Cursor    = Cursors.Hand,
                    Tag       = facility.FacilityCd,
                };
                btnDel.FlatAppearance.BorderSize = 0;
                btnDel.Click += async (s, e) =>
                {
                    string cd = (string)((Button)s).Tag;
                    AppState.Instance.SelectedFacilities.RemoveAll(f => f.FacilityCd == cd);
                    BuildSelectedRows();
                    // 右パネルが開いていれば一覧を更新して削除した施設を戻す
                    if (pnlRight.Visible) await LoadAvailableFacilitiesAsync();
                };

                row.Controls.Add(lbl);
                row.Controls.Add(btnDel);
                pnlSelectedContent.Controls.Add(row);
                y += _rowHeight;

                // 行区切り線
                pnlSelectedContent.Controls.Add(new Panel
                {
                    Location  = new Point(0, y),
                    Size      = new Size(rowW, _separatorHeight),
                    BackColor = Color.FromArgb(232, 234, 237),
                });
                y += _separatorHeight;
            }

            // --------------------------------------------------
            // 末尾: 「＋ 施設を追加...」行ボタン
            // --------------------------------------------------
            var btnAddRow = new Button
            {
                Location  = new Point(0, y),
                Size      = new Size(rowW, _rowHeight),
                Text      = "\uff0b  \u65bd\u8a2d\u3092\u8ffd\u52a0...",
                Font      = new Font("MS UI Gothic", 10F),
                FlatStyle = FlatStyle.Flat,
                BackColor = Color.White,
                ForeColor = Color.FromArgb(24, 119, 242),
                TextAlign = ContentAlignment.MiddleLeft,
                ImageAlign= ContentAlignment.MiddleLeft,
                Cursor    = Cursors.Hand,
            };
            btnAddRow.FlatAppearance.BorderSize         = 0;
            btnAddRow.FlatAppearance.MouseOverBackColor = Color.FromArgb(235, 242, 255);
            btnAddRow.Padding = new Padding(ScaleLogicalX(10), 0, 0, 0);
            btnAddRow.Click  += btnAdd_Click;
            pnlSelectedContent.Controls.Add(btnAddRow);

            UpdateFooterButtons();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 利用可能な施設一覧を右パネルのリストへ非同期で読み込む（選択済みは除外）
        ///   オンプレ→クラウド: サーバー API から取得
        ///   クラウド→オンプレ: PostgreSQL ntss.mst_facility から取得
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private async Task LoadAvailableFacilitiesAsync()
        {
            lstAvailable.Items.Clear();
            lstAvailable.Items.Add("\u8aad\u307f\u8fbc\u307f\u4e2d...");
            lstAvailable.Enabled = false;

            try
            {
                var all = await FacilityLoader.LoadAsync(AppState.Instance);

                var selectedCodes = new HashSet<string>();
                foreach (var f in AppState.Instance.SelectedFacilities)
                    selectedCodes.Add(f.FacilityCd);

                lstAvailable.Items.Clear();
                foreach (var f in all)
                    if (!selectedCodes.Contains(f.FacilityCd))
                        lstAvailable.Items.Add(f);

                if (lstAvailable.Items.Count == 0)
                    lstAvailable.Items.Add("(\u65bd\u8a2d\u306a\u3057)");
            }
            catch (Exception ex)
            {
                lstAvailable.Items.Clear();
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("\u65bd\u8a2d\u4e00\u89a7\u53d6\u5f97\u30a8\u30e9\u30fc: {0}", ex.Message));
                MessageBox.Show(
                    "\u65bd\u8a2d\u4e00\u89a7\u306e\u53d6\u5f97\u306b\u5931\u6557\u3057\u307e\u3057\u305f\u3002\n" + ex.Message,
                    "\u30a8\u30e9\u30fc",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                lstAvailable.Enabled = true;
            }
        }

        // --------------------------------------------------
        // 「＋ 施設を追加...」行クリック: 右パネルを展開する
        // --------------------------------------------------
        private async void btnAdd_Click(object sender, EventArgs e)
        {
            SetRightPanelVisible(true);
            await LoadAvailableFacilitiesAsync();
            lstAvailable.Focus();
        }

        // --------------------------------------------------
        // 右パネル: 施設をダブルクリック → 選択済みリストへ追加し右パネルを閉じる
        // --------------------------------------------------
        private void lstAvailable_DoubleClick(object sender, EventArgs e)
        {
            AddSelectedFacility();
        }

        // Enter キーでも選択できるようにする
        private void lstAvailable_KeyDown(object sender, KeyEventArgs e)
        {
            if (e.KeyCode == Keys.Enter)
                AddSelectedFacility();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 右パネルで選択した施設を選択済みリストへ追加する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void AddSelectedFacility()
        {
            var facility = lstAvailable.SelectedItem as FacilityInfo;
            if (facility == null) return;

            // 重複チェック（念のため）
            if (AppState.Instance.SelectedFacilities.Exists(
                    f => f.FacilityCd == facility.FacilityCd))
                return;

            AppState.Instance.SelectedFacilities.Add(facility);

            // 右パネルを閉じてから行を再描画（UpdateFooterButtons は BuildSelectedRows 内で呼ばれる）
            SetRightPanelVisible(false);
            BuildSelectedRows();
        }

        // --------------------------------------------------
        // 右パネル: [×] 閉じるボタン押下
        // --------------------------------------------------
        private void btnCloseRight_Click(object sender, EventArgs e)
        {
            SetRightPanelVisible(false);
        }

        // --------------------------------------------------
        // [選択] ボタン押下（右パネル表示中）
        // --------------------------------------------------
        private void btnSelect_Click(object sender, EventArgs e)
        {
            AddSelectedFacility();
        }

        // --------------------------------------------------
        // [確定] ボタン押下
        // --------------------------------------------------
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            if (AppState.Instance.SelectedFacilities.Count == 0)
            {
                MessageBox.Show(
                    "\u65bd\u8a2d\u3092 1 \u4ef6\u4ee5\u4e0a\u9078\u629e\u3057\u3066\u304f\u3060\u3055\u3044\u3002",
                    "\u5165\u529b\u78ba\u8a8d",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                return;
            }

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("\u65bd\u8a2d\u9078\u629e\u78ba\u5b9a: {0}\u4ef6", AppState.Instance.SelectedFacilities.Count));

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        // --------------------------------------------------
        // [手入力] ボタン押下（LAN モード時のみ表示）
        // 施設コードと施設名を手動入力して選択済みリストへ追加する
        // --------------------------------------------------
        private void btnManualInput_Click(object sender, EventArgs e)
        {
            // 入力ダイアログを動的に生成する
            using (var dlg = new Form())
            {
                dlg.Text            = "施設を手入力";
                dlg.ClientSize      = new Size(320, 160);
                dlg.FormBorderStyle = FormBorderStyle.FixedDialog;
                dlg.StartPosition   = FormStartPosition.CenterParent;
                dlg.MaximizeBox     = false;
                dlg.MinimizeBox     = false;

                var lblCd = new Label  { Text = "施設コード:", Location = new Point(16, 20),  Size = new Size(90, 20), TextAlign = ContentAlignment.MiddleLeft };
                var txtCd = new TextBox { Location = new Point(116, 18), Size = new Size(184, 22) };

                var lblNm = new Label  { Text = "施設名:",     Location = new Point(16, 54),  Size = new Size(90, 20), TextAlign = ContentAlignment.MiddleLeft };
                var txtNm = new TextBox { Location = new Point(116, 52), Size = new Size(184, 22) };

                var btnOk = new Button
                {
                    Text      = "確定",
                    DialogResult = DialogResult.OK,
                    Location  = new Point(120, 108),
                    Size      = new Size(80, 30),
                    Font      = new Font("MS UI Gothic", 9F, FontStyle.Bold),
                    FlatStyle = FlatStyle.Flat,
                    BackColor = Color.FromArgb(24, 119, 242),
                    ForeColor = Color.White,
                };
                btnOk.FlatAppearance.BorderSize = 0;

                var btnCancelDlg = new Button
                {
                    Text         = "キャンセル",
                    DialogResult = DialogResult.Cancel,
                    Location     = new Point(212, 108),
                    Size         = new Size(90, 30),
                    FlatStyle    = FlatStyle.Flat,
                    BackColor    = Color.FromArgb(220, 222, 226),
                    ForeColor    = Color.FromArgb(60, 60, 60),
                };
                btnCancelDlg.FlatAppearance.BorderSize = 0;

                dlg.AcceptButton = btnOk;
                dlg.CancelButton = btnCancelDlg;
                dlg.Controls.AddRange(new Control[] { lblCd, txtCd, lblNm, txtNm, btnOk, btnCancelDlg });

                if (dlg.ShowDialog(this) != DialogResult.OK)
                    return;

                string cd = txtCd.Text.Trim();
                string nm = txtNm.Text.Trim();

                if (string.IsNullOrEmpty(cd) || string.IsNullOrEmpty(nm))
                {
                    MessageBox.Show(
                        "施設コードと施設名を両方入力してください。",
                        "入力確認",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                    return;
                }

                // 重複チェック
                if (AppState.Instance.SelectedFacilities.Exists(f => f.FacilityCd == cd))
                {
                    MessageBox.Show(
                        string.Format("施設コード「{0}」はすでに選択されています。", cd),
                        "重複",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Warning);
                    return;
                }

                AppState.Instance.SelectedFacilities.Add(new FacilityInfo
                {
                    FacilityCd   = cd,
                    FacilityName = nm,
                });

                BuildSelectedRows();
            }
        }

        // --------------------------------------------------
        // [キャンセル] ボタン押下
        // --------------------------------------------------
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}
