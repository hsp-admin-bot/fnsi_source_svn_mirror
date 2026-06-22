using System;
using System.Threading.Tasks;
using System.Windows.Forms;
using FNSICloudConvertClient.Logic;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Forms
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// ログイン画面（二段階認証）
    /// ステップ１: ユーザーID + パスワード入力
    /// ステップ２: ワンタイムパスワード（OTP）入力
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public partial class FormLogin : Form
    {
        private sealed class ToolCheckTarget
        {
            public string Label { get; set; }
            public string Path { get; set; }
        }

        private readonly AppLogger _log;
        private bool _toolCheckLogged;
        private string[] _cachedMissingTools = new string[0];

        public FormLogin()
        {
            InitializeComponent();
            _log = AppLogger.GetInstance();
            this.Shown += (s, e) => LogStartupToolCheck();
        }

        // --------------------------------------------------
        // ログインボタン押下: ユーザーID + パスワードで認証
        // --------------------------------------------------
        private async void btnNext_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtUserId.Text))
            {
                MessageBox.Show(
                    "ユーザーIDを入力してください。",
                    "入力確認",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                txtUserId.Focus();
                return;
            }
            if (string.IsNullOrWhiteSpace(txtPassword.Text))
            {
                MessageBox.Show(
                    "パスワードを入力してください。",
                    "入力確認",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                txtPassword.Focus();
                return;
            }

            btnNext.Enabled = false;
            this.Cursor = Cursors.WaitCursor;

            try
            {
                // BusinessApiClient に認証情報をセット
                BusinessApiClient.UserId   = txtUserId.Text.Trim();
                BusinessApiClient.Password = txtPassword.Text;
                BusinessApiClient.UrlEncodeFacilityHash = AppConfigLoader.FacilityHash;

                // ID/パスワード認証（otpCode = "" → ステップ1）
                BusinessLoginResponse result = await BusinessApiClient.ServerLoginAsync(string.Empty);

                if (result.strContent == "-1")
                {
                    MessageBox.Show(
                        "サーバーに接続できません。\nBaseUri の設定を確認してください。",
                        "接続エラー",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return;
                }

                if (result.strContent == "0" || !result.isLogin && result.strContent != "1")
                {
                    const string reason = "ユーザーIDまたはパスワードが正しくありません。";
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                        string.Format("ログイン失敗: {0}", reason));
                    MessageBox.Show(reason, "認証エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                if (result.isLogin)
                {
                    // 二段階認証不要 → ログイン完了
                    await ProceedToNextScreenAsync();
                }
                else
                {
                    // 二段階認証が必要なアカウント → 認証コード入力へ
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                        "ID/PW 認証成功、二段階認証へ移行");
                    pnlStep1.Visible  = false;
                    pnlStep2.Visible  = true;
                    btnNext.Visible   = false;
                    btnLogin.Visible  = true;
                    btnBack.Visible   = true;
                    this.AcceptButton = btnLogin;
                    txtAuthCode.Focus();
                }
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("ログインエラー: {0}", ex.Message));
                MessageBox.Show(
                    string.Format("ログインに失敗しました。\n{0}", ex.Message),
                    "エラー",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                btnNext.Enabled  = true;
                this.Cursor = Cursors.Default;
            }
        }

        // --------------------------------------------------
        // 認証ボタン押下（二段階認証: OTP）
        // --------------------------------------------------
        private async void btnLogin_Click(object sender, EventArgs e)
        {
            if (string.IsNullOrWhiteSpace(txtAuthCode.Text))
            {
                MessageBox.Show(
                    "認証コードを入力してください。",
                    "入力確認",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Warning);
                txtAuthCode.Focus();
                return;
            }

            btnLogin.Enabled = false;
            this.Cursor = Cursors.WaitCursor;

            try
            {
                // OTP 認証（otpCode = OTPコード）
                BusinessLoginResponse result = await BusinessApiClient.ServerLoginAsync(txtAuthCode.Text.Trim());

                if (result.strContent == "-1")
                {
                    MessageBox.Show(
                        "サーバーに接続できません。",
                        "接続エラー",
                        MessageBoxButtons.OK,
                        MessageBoxIcon.Error);
                    return;
                }

                if (!result.isLogin)
                {
                    const string reason = "認証コードが正しくありません。";
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                        string.Format("OTP 認証失敗: {0}", reason));
                    MessageBox.Show(reason, "認証エラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    return;
                }

                // OTP 認証成功 → ログイン完了
                await ProceedToNextScreenAsync();
            }
            catch (Exception ex)
            {
                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    string.Format("OTP 認証エラー: {0}", ex.Message));
                MessageBox.Show(
                    string.Format("認証に失敗しました。\n{0}", ex.Message),
                    "エラー",
                    MessageBoxButtons.OK,
                    MessageBoxIcon.Error);
            }
            finally
            {
                btnLogin.Enabled = true;
                this.Cursor = Cursors.Default;
            }
        }

        // --------------------------------------------------
        // 認証コード画面: 戻るボタン押下
        // --------------------------------------------------
        private void btnBack_Click(object sender, EventArgs e)
        {
            txtAuthCode.Clear();
            pnlStep2.Visible  = false;
            pnlStep1.Visible  = true;
            btnLogin.Visible  = false;
            btnBack.Visible   = false;
            btnNext.Visible   = true;
            this.AcceptButton = btnNext;
            txtUserId.Focus();
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 認証完了後に操作選択画面へ遷移する共通処理
        /// コンバーターサーバーへの認証も並行して試みる
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private System.Threading.Tasks.Task ProceedToNextScreenAsync()
        {
            AppState.Instance.UserId = txtUserId.Text.Trim();

            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                string.Format("ログイン成功: ユーザーID={0}", AppState.Instance.UserId));

            // コンバーターサーバーへの認証をバックグラウンドで試みる
            // LAN モードでは接続不可の可能性があるため await しない（fire-and-forget）
            // タイムアウトをこの呼び出し限定で 5 秒に短縮する
            string capFacilityCd      = BusinessApiClient.FacilityCd;
            string capUserId          = BusinessApiClient.UserId;
            string capPassword        = BusinessApiClient.Password;
            string capConverterUri    = AppConfigLoader.ConverterBaseUri;
            AppLogger capLog          = _log;

            AppState.Instance.ConverterFacilityCd = capFacilityCd;
            AppState.Instance.ConverterDispUserId = capUserId;
            AppState.Instance.ConverterPassword   = capPassword;

            _ = Task.Run(async () =>
            {
                using (var cts = new System.Threading.CancellationTokenSource(TimeSpan.FromSeconds(5)))
                {
                    try
                    {
                        var converterClient = new ConverterApiClient(capConverterUri);
                        string jwtToken = await converterClient.LoginAsync(
                            capFacilityCd, capUserId, capPassword, cts.Token);

                        AppState.Instance.ConverterJwtToken        = jwtToken ?? string.Empty;
                        AppState.Instance.IsConverterAuthenticated = !string.IsNullOrEmpty(jwtToken);

                        capLog.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                            string.Format("コンバーター認証: {0}",
                                AppState.Instance.IsConverterAuthenticated ? "成功" : "失敗"));
                    }
                    catch (Exception ex)
                    {
                        AppState.Instance.IsConverterAuthenticated = false;
                        AppState.Instance.ConverterJwtToken        = string.Empty;
                        capLog.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                            string.Format("コンバーター認証例外（無視）: {0}", ex.Message));
                    }
                }
            });

            // ツール事前チェック
            CheckRequiredTools();

            var next = new FormSelectMode();
            next.Show();
            this.Hide();
            return Task.CompletedTask;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// フォームクローズ時: アプリケーション終了
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        private void CheckRequiredTools()
        {
            LogStartupToolCheck();
            var missing = new System.Collections.Generic.List<string>(_cachedMissingTools);

            if (missing.Count > 0)
            {
                string msg = string.Format(
                    "以下のツールが見つかりません。移行処理を実行すると失敗します。\n" +
                    "必要なツールをインストールしてから再度お試しください。\n\n" +
                    "{0}\n\n" +
                    "このまま続行しますか？",
                    string.Join("\n", missing));

                _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.ERROR,
                    "必須ツール未インストール: " + string.Join(", ", missing));

                MessageBox.Show(msg, "ツール確認", MessageBoxButtons.OK, MessageBoxIcon.Warning);
            }
        }

        private void LogStartupToolCheck()
        {
            if (_toolCheckLogged)
                return;

            _toolCheckLogged = true;
            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                "ツール事前チェック開始");

            var missing = new System.Collections.Generic.List<string>();
            foreach (var tool in EnumerateRequiredTools())
            {
                if (System.IO.File.Exists(tool.Path))
                {
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.INFO,
                        string.Format("ツール確認OK: [{0}] {1}", tool.Label.Trim(), tool.Path));
                }
                else
                {
                    string line = string.Format("  [{0}]  {1}", tool.Label, tool.Path);
                    missing.Add(line);
                    _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient", AppLogger.LOGGING_CLASS.WARNING,
                        string.Format("ツール確認NG: [{0}] {1}", tool.Label.Trim(), tool.Path));
                }
            }

            _cachedMissingTools = missing.ToArray();
            _log.AddLogInfo(DateTime.Now, "FNSICloudConvertClient",
                missing.Count == 0 ? AppLogger.LOGGING_CLASS.INFO : AppLogger.LOGGING_CLASS.WARNING,
                missing.Count == 0
                    ? "ツール事前チェック完了: すべて利用可能"
                    : string.Format("ツール事前チェック完了: 不足 {0} 件", missing.Count));
        }

        private static System.Collections.Generic.IEnumerable<ToolCheckTarget> EnumerateRequiredTools()
        {
            return new[]
            {
                new ToolCheckTarget { Label = "pg_dump    ",  Path = AppConfigLoader.PgDumpExe      },
                new ToolCheckTarget { Label = "psql       ",  Path = AppConfigLoader.PsqlExe        },
                new ToolCheckTarget { Label = "pg_restore ",  Path = AppConfigLoader.PgRestoreExe   },
                new ToolCheckTarget { Label = "mongodump   ", Path = AppConfigLoader.MongoDumpExe    },
                new ToolCheckTarget { Label = "mongorestore", Path = AppConfigLoader.MongoRestoreExe },
            };
        }

        private void FormLogin_FormClosed(object sender, FormClosedEventArgs e)
        {
            Application.Exit();
        }
    }
}
