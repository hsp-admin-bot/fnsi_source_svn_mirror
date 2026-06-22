using System;
using System.Windows.Forms;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;


namespace FNSICloudConvertClient.Forms
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 操作モード選択画面
    /// [データ導出] ボタン / [データ導入] ボタン の 2 択
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormSelectMode : Form
    {
        private AppLogger _log;

        public FormSelectMode()
        {
            InitializeComponent();
            _log = AppLogger.GetInstance();

            // ユーザーIDをタイトルバーに表示する
            this.Text = string.Format("操作モード選択  |  ログイン中: {0}", AppState.Instance.UserId);
        }

        // --------------------------------------------------
        // データ導出ボタン押下
        // --------------------------------------------------
        private void btnExport_Click(object sender, EventArgs e)
        {
            AppState.Instance.CurrentMode = OperationMode.Export;

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "操作モード選択: データ導出");

            // オンプレ→クラウド: RDB IPアドレスが未設定の場合は設定画面を開く
            if (string.IsNullOrWhiteSpace(AppState.Instance.Settings.OnpreRdbIpAddress))
            {
                MessageBox.Show(
                    "オンプレ→クラウド を実行するには、先に設定画面で RDB IPアドレス を設定してください。",
                    "設定が必要です",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                var settings = new FormSettings();
                settings.ShowDialog(this);
                // 設定後も未入力なら処理を中断
                if (string.IsNullOrWhiteSpace(AppState.Instance.Settings.OnpreRdbIpAddress))
                {
                    AppState.Instance.CurrentMode = OperationMode.None;
                    return;
                }
            }

            OpenFacilitySelect();
        }

        // --------------------------------------------------
        // データ導入ボタン押下
        // --------------------------------------------------
        private void btnImport_Click(object sender, EventArgs e)
        {
            AppState.Instance.CurrentMode = OperationMode.Import;

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO, "操作モード選択: データ導入");

            OpenFacilitySelect();
        }

        // --------------------------------------------------
        // ログアウトボタン押下
        // --------------------------------------------------
        private void btnLogout_Click(object sender, EventArgs e)
        {
            var result = MessageBox.Show(
                "ログアウトしますか？",
                "確認",
                MessageBoxButtons.YesNo,
                MessageBoxIcon.Question);

            if (result == DialogResult.Yes)
            {
                AppState.Instance.Reset();
                var loginForm = new FormLogin();
                loginForm.Show();
                this.Close();
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設選択画面を開き、選択完了後にメイン画面へ遷移する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        // --------------------------------------------------
        // 設定ボタン押下
        // --------------------------------------------------
        private void btnSettings_Click(object sender, EventArgs e)
        {
            var settings = new FormSettings(useCurrentModeLayout: false);
            settings.ShowDialog(this);
        }

        private void OpenFacilitySelect()
        {
            AppState.Instance.SelectedFacilities.Clear();
            var form = new FormFacilitySelect();
            if (form.ShowDialog(this) == DialogResult.OK)
            {
                // 1 件以上選択されていればメイン画面へ遷移
                if (AppState.Instance.SelectedFacilities.Count > 0)
                {
                    var main = new FormMain();
                    main.Show();
                    this.Hide();
                    return;
                }
            }

            AppState.Instance.CurrentMode = OperationMode.None;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォームクローズ時: アプリケーション終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void FormSelectMode_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
