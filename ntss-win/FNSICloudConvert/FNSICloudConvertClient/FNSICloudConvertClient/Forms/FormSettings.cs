using System;
using System.Drawing;
using System.Threading;
using System.Windows.Forms;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Forms
{
    public partial class FormSettings : Form
    {
        private readonly bool _useCurrentModeLayout;
        private readonly ToolTip _cloudInfoToolTip = new ToolTip();

        public FormSettings(bool useCurrentModeLayout = true)
        {
            _useCurrentModeLayout = useCurrentModeLayout;
            InitializeComponent();

            // タイトルをモードに応じて変更
            string titleText;
            if (_useCurrentModeLayout && AppState.Instance.CurrentMode == OperationMode.Export)
                titleText = "\u30aa\u30f3\u30d7\u30ec\u2192\u30af\u30e9\u30a6\u30c9\u8a2d\u5b9a";
            else if (_useCurrentModeLayout && AppState.Instance.CurrentMode == OperationMode.Import)
                titleText = "\u30af\u30e9\u30a6\u30c9\u2192\u30aa\u30f3\u30d7\u30ec\u8a2d\u5b9a";
            else
                titleText = "\u8a2d\u5b9a";
            lblTitle.Text = titleText;
            this.Text     = titleText;

            // on2off モード時はクラウド側を左・オンプレ側を右に入れ替える（データフロー方向に合わせる）
            if (_useCurrentModeLayout && AppState.Instance.CurrentMode == OperationMode.Import)
            {
                var cloudLocation = pnlCloud.Location;
                pnlCloud.Location = pnlOnpre.Location;
                pnlOnpre.Location = cloudLocation;
            }

            ApplyTemporaryFolderLabels();

            // AppState から現在の設定値を画面に反映（起動時に user_settings.json から復元済み）
            var s = AppState.Instance.Settings;
            txtRdbIp.Text      = s.OnpreRdbIpAddress;
            txtMongoIp.Text    = s.OnpreMongoIpAddress;
            txtFnsiFolder.Text = s.OnpreFnsiRootFolder;
            txtOnpreTmp.Text   = s.OnpreTempFolder;

            SetCloudDisplayValue(lblCloudServerValue, AppConfigLoader.ConverterBaseUri + " [確認中...]");
            SetCloudDisplayValue(lblCloudDbValue, "(取得中...)");

            this.Shown += async (s2, e2) => await LoadCloudSideInfoAsync();
        }

        private void ApplyTemporaryFolderLabels()
        {
            if (!_useCurrentModeLayout || AppState.Instance.CurrentMode == OperationMode.None)
            {
                lblOnpreTmp.Text = "一時フォルダ";
                return;
            }

            lblOnpreTmp.Text = AppState.Instance.CurrentMode == OperationMode.Export
                ? "一時アップロードフォルダ"
                : "一時ダウンロードフォルダ";
        }

        // [参照...] FNSi物理ファイルルートフォルダ
        private void btnBrowseFnsi_Click(object sender, EventArgs e)
        {
            using (var dlg = new FolderBrowserDialog())
            {
                dlg.Description = "FNSi物理ファイルルートフォルダを選択してください";
                if (!string.IsNullOrEmpty(txtFnsiFolder.Text))
                    dlg.SelectedPath = txtFnsiFolder.Text;
                if (dlg.ShowDialog(this) == DialogResult.OK)
                    txtFnsiFolder.Text = dlg.SelectedPath;
            }
        }

        // [参照...] オンプレ臨時フォルダ
        private void btnBrowseOnpreTmp_Click(object sender, EventArgs e)
        {
            using (var dlg = new FolderBrowserDialog())
            {
                dlg.Description = lblOnpreTmp.Text + "を選択してください";
                if (!string.IsNullOrEmpty(txtOnpreTmp.Text))
                    dlg.SelectedPath = txtOnpreTmp.Text;
                if (dlg.ShowDialog(this) == DialogResult.OK)
                    txtOnpreTmp.Text = dlg.SelectedPath;
            }
        }

        private async System.Threading.Tasks.Task LoadCloudSideInfoAsync()
        {
            try
            {
                var client = new ConverterApiClient(AppConfigLoader.ConverterBaseUri);
                using (var cts = new CancellationTokenSource(TimeSpan.FromSeconds(5)))
                {
                    ConverterServerHealth health = await client.GetServerHealthAsync(cts.Token);
                    string serverStatusText = BuildServerStatusText(health);
                    SetCloudDisplayValue(lblCloudServerValue,
                        string.Format("{0} [{1}]", AppConfigLoader.ConverterBaseUri, serverStatusText));

                    try
                    {
                        ConverterSystemInfo systemInfo = await client.GetSystemInfoAsync(cts.Token);
                        SetCloudDisplayValue(lblCloudDbValue,
                            string.Format("{0}:{1}", systemInfo.ConverterDbHost, systemInfo.ConverterDbPort));
                    }
                    catch
                    {
                        SetCloudDisplayValue(lblCloudDbValue, "(取得失敗)");
                    }
                }
            }
            catch
            {
                SetCloudDisplayValue(lblCloudServerValue,
                    string.Format("{0} [未接続]", AppConfigLoader.ConverterBaseUri));
                SetCloudDisplayValue(lblCloudDbValue, "(取得失敗)");
            }
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

        private void SetCloudDisplayValue(Label label, string text)
        {
            label.Text = text;
            label.AutoEllipsis = true;
            _cloudInfoToolTip.SetToolTip(label, text);
        }

        // [確定]
        private void btnConfirm_Click(object sender, EventArgs e)
        {
            var s = AppState.Instance.Settings;
            s.OnpreRdbIpAddress   = txtRdbIp.Text.Trim();
            s.OnpreMongoIpAddress = txtMongoIp.Text.Trim();
            s.OnpreFnsiRootFolder = txtFnsiFolder.Text.Trim();
            s.OnpreTempFolder     = txtOnpreTmp.Text.Trim();

            // 設定をファイルに保存（次回起動時に自動復元）
            UserSettingsStore.FromSettings(s).Save();

            this.DialogResult = DialogResult.OK;
            this.Close();
        }

        // [キャンセル]
        private void btnCancel_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
    }
}
