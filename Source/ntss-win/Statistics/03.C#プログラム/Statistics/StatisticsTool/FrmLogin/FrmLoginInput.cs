using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Windows.Forms;
using Fnw.StatisticsTool.Properties;
using NKKLoggingLib;
using NKKWebAccessLib;
using System.Threading.Tasks;
using System.Reflection;
using System.Text.RegularExpressions;

namespace Fnw.StatisticsTool.FrmLogin
{
    /// <summary>
    /// ログイン画面
    /// </summary>
    public partial class FrmLoginInput : Form
    {
        #region メンバ列挙体定義

        /// <summary>
        /// サーバログイン結果
        /// </summary>
        private enum EnumLoginResult
        {
            /// <summary>
            /// ユーザアボート
            /// </summary>
            Abort = -2,
            /// <summary>
            /// サーバ未到達
            /// </summary>
            NotConnect = -1,
            /// <summary>
            /// 認証エラー
            /// </summary>
            Failusure = 0,
            /// <summary>
            /// 成功
            /// </summary>
            Success = 1
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// サインイン情報の取得を行います。値の取得のみ可能です。
        /// </summary>
        //public static LoginInfo SignInInfo { get; set; } = null;

        #endregion

        /// <summary>
        /// コンストラクタ
        /// </summary>
        public FrmLoginInput() 
        {
            InitializeComponent();
            // 読み込み済みの情報でサインイン情報を生成
            Login.LoginInfo = new LoginInfo()
            {
                LoginID = string.Empty,
                Password = string.Empty,
                FacilityHashText = ConfigHelper.ReadSetting("FacilityHash"),
                domain = ConfigHelper.ReadSetting("BaseName")
            };
            if (String.IsNullOrEmpty(Login.LoginInfo.FacilityHashText) == false)
            {
                // 施設情報が設定済の場合
                this.pnlBody.Visible = false;
                this.Height -= this.pnlBody.Height;
            }
        }
        /// <summary>
        /// 初期表示イベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void FrmLogin_Load(object sender, EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            txtLoginID.Text = string.Empty;
            txtPassword.Text = string.Empty;
            txtUrl.Text = string.Empty;

            // あらかじめ設定されている接続情報をセット
            this.txtLoginID.Text = Login.LoginInfo.LoginID;
            this.txtPassword.Text = Login.LoginInfo.Password;
            if (!string.IsNullOrEmpty(Login.LoginInfo.domain))
            {
                txtUrl.Text = string.Format(@"{0}/ntss-admin-web/#/?key={1}", Login.LoginInfo.domain, Login.LoginInfo.FacilityHashText);
            }
        }
        /// <summary>
        /// ボタンOKイベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void btnLogin_Click(object sender, EventArgs e)
        {
            //入力項目チェック
            if (this.txtLoginID.Text.Length < 1)
            {
                MessageBox.Show("ユーザーIDを入力して下さい");
                return;
            };
            if (this.txtPassword.Text.Length < 1)
            {
                MessageBox.Show("パスワードを入力して下さい");
                return;
            };
            if (this.txtUrl.Text.Length < 1)
            {
                if (string.IsNullOrEmpty(Login.LoginInfo.FacilityHashText))
                {
                    MessageBox.Show("施設情報を入力して下さい");
                    return;
                }
            };

            string url = txtUrl.Text.Trim();
            if (!string.IsNullOrEmpty(url))
            {
                //URLの分析
                // 正規表現を使用して、URLのハッシュとドメインを抽出
                var match = Regex.Match(url, @"^(https?://[^/?#]+)(?:[/?#].*key=([a-zA-Z0-9$./%]+))?");

                if (match.Success)
                {
                    // ドメイン部分の抽出
                    Login.LoginInfo.domain = match.Groups[1].Value;

                    // ハッシュ部分の抽出（key=の後ろの部分）
                    if (match.Groups[2].Success)
                    {
                        string raw = match.Groups[2].Value;

                        // まずURLデコードを試す（%24 → $, %2F → /, など）
                        string decoded;
                        try
                        {
                            decoded = System.Uri.UnescapeDataString(raw);
                        }
                        catch
                        {
                            decoded = raw; // 失敗したらそのまま判定
                        }

                        // bcryptチェックパターン（全世代対応）
                        Regex bcrypt = new Regex(
                            @"^\$2[abxy]\$\d{2}\$[A-Za-z0-9./]{53}$"
                        );

                        // 長さチェック（bcryptは常に60文字固定）
                        bool isValidBcrypt = decoded.Length == 60 && bcrypt.IsMatch(decoded);

                        if (!isValidBcrypt)
                        {
                            MessageBox.Show("施設ハッシュ値の形式が正しくありません。値を確認してください。");
                            NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("ハッシュ値エラー：,{0}", Login.LoginInfo.FacilityHashText));
                            return;
                        }

                        Login.LoginInfo.FacilityHashText = decoded;
                    }
                    else
                    {
                        MessageBox.Show("施設ハッシュ値が見つかりませんでした。値を入力してください。");
                        NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("ハッシュ値がない：,{0}", Login.LoginInfo.FacilityHashText));
                        return;
                    }
                }
                else
                {
                    MessageBox.Show("無効なURL形式です。");
                    NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("無効なURL形式"));
                    return;
                }
            }

            try
            {
                this.Cursor = Cursors.WaitCursor; // 砂時計カーソルに変更
                this.btnLogin.Enabled = false;
                var wResult = await this.ExecSingin();

                // サインインが成功して、初回サインイン時は施設ハッシュの保存を行うか確認
                if ((wResult == EnumLoginResult.Success) && (string.IsNullOrEmpty(ConfigHelper.ReadSetting("FacilityCd"))))
                {
                    var wMsg = new System.Text.StringBuilder();
                    wMsg.Length = 0;
                    wMsg.AppendLine("入力された施設情報を保存します。")
                        .Append("よろしいですか？");

                    // 保存確認ダイアログで［はい］が選択された場合、施設コードと施設ハッシュ値を保存する
                    if ((MessageBox.Show(this, wMsg.ToString(), "確認してください", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes))
                    {
                        ConfigHelper.WriteSetting("FacilityCd", Login.LoginInfo.FacilityCode);
                        ConfigHelper.WriteSetting("FacilityHash", Login.LoginInfo.FacilityHashText);
                        ConfigHelper.WriteSetting("BaseName", Login.LoginInfo.domain);
                    }
                    else
                    {
                        // 保存失敗
                        wMsg.Length = 0;
                        wMsg.AppendLine("施設情報を保存しませんでした。")
                            .Append("次回サインイン時に再度入力してください。終了します。");
                        MessageBox.Show(this, wMsg.ToString(), "中止", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        wResult = EnumLoginResult.Abort;
                    }
                }
                if (wResult == EnumLoginResult.Failusure)
                {
                    this.txtLoginID.Focus();
                }
                else if (wResult == EnumLoginResult.Abort)
                {
                    this.DialogResult = DialogResult.Abort;
                }
                else if (wResult == EnumLoginResult.NotConnect)
                {
                    this.DialogResult = DialogResult.Cancel;
                }
                // 認証エラー以外は閉じる
                else
                {
                    this.DialogResult = DialogResult.OK;
                }
            }
            catch (Exception ex)
            {
                StatisticsUtility.RecordException(this, ex, true);
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("サインイン時の実行エラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
            }
            finally
            {
                // ボタンを押せるようにする
                this.btnLogin.Enabled = true;
                this.Cursor = Cursors.Default;
            }
        }

        /// <summary>
        /// サインイン処理を行います。
        /// </summary>
        /// <returns></returns>
        private async Task<EnumLoginResult> ExecSingin() 
        {
            Int32 wResult = (int)EnumLoginResult.Failusure;
            try
            {
                // ログイン処理開始
                NKKWebAccess.UserId = this.txtLoginID.Text;
                NKKWebAccess.Password = this.txtPassword.Text;
                NKKWebAccess.UrlEncodeFacilityHash = Login.LoginInfo.FacilityHashText;
                NKKWebAccess.BaseUri = Login.LoginInfo.domain;

                var wMsg = new System.Text.StringBuilder();

                NKKWebAccess.GetInstance(); // コンストラクタを走らせるため
                wResult = await NKKWebAccess.ServerLogin();
                if (wResult == (Int32)EnumLoginResult.Failusure)
                {
                    // 認証エラー時
                    wMsg.Length = 0;
                    wMsg.AppendFormat("認証エラーが発生しました。{0}ログインID、パスワード", System.Environment.NewLine);
                    if (this.pnlBody.Visible) wMsg.Append("、施設情報");
                    wMsg.Append("を確認してください。");
                    MessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("認証エラー"));
                }
                else
                {
                    // サーバ未到達 or サインイン成功
                    // 入力内容を記憶
                    Login.LoginInfo.LoginID = this.txtLoginID.Text;
                    Login.LoginInfo.Password = this.txtPassword.Text;

                    if (wResult == (int)EnumLoginResult.NotConnect)
                    {
                        // サーバ未到達時
                        wMsg.Clear();
                        wMsg.AppendLine("ログインできませんでした。ID、パスワード、接続設定をご確認ください。");
                        MessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(FrmLogin), NKKLogging.LOGGING_CLASS.ERROR, String.Format("サーバ未到達"));
                    }
                    else
                    {
                        // サインイン成功時

                        // ログ出力クラスへ施設コードをセット
                        NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                        // ログ記録：施設コード
                        NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, NKKLogging.LOGGING_CLASS.INFO, String.Format("施設コード:{0}", NKKWebAccess.FacilityCd));

                        // 追加情報を記憶
                        Login.LoginInfo.FacilityCode = NKKWebAccess.FacilityCd;
                        Login.LoginInfo.IsAuthenticated = true;
                        Login.LoginInfo.IsOnline = true;
                    }
                }
            }
            catch
            {
                throw;
            }
            finally
            {

            }

            return (EnumLoginResult)wResult;
        }

        /// <summary>
        /// ボタンキャンセルイベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFin_Click(object sender, EventArgs e)
        {
            this.DialogResult = DialogResult.Cancel;
            this.Close();
        }
        /// <summary>
        /// ユーザー入力時のイベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtUserId_TextChanged(object sender, EventArgs e)
        {
            if (txtLoginID.MaxLength == txtLoginID.Text.Length)
            {
                btnLogin.Focus();
            }
        }
        /// <summary>
        /// パスワード入力時のイベント処理です。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void txtPassword_TextChanged(object sender, EventArgs e)
        {
            if (txtPassword.MaxLength == txtPassword.Text.Length)
            {
                btnLogin.Focus();
            }
        }

        private void FrmLoginInput_FormClosed(object sender, FormClosedEventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
        }

        /// <summary>
        /// フォームをモーダル ダイアログ ボックスとして表示します
        /// </summary>
        /// <param name="signIn">IFrmSignInインタフェース</param>
        /// <returns>DialogResult 値のいずれか 1 つです</returns>
        public static DialogResult ShowSignInDialog()
        {

            DialogResult wDialogResult = DialogResult.None;

            // サインイン画面を表示
            using (var wDlg = new FrmLoginInput())
            {

                bool wIsExitLoop = false;

                while (!wIsExitLoop)
                {
                    // サインイン画面を表示して入力結果を取得
                    wDialogResult = wDlg.ShowDialog();

                    // 以下の場合は抜ける
                    // ・サインイン画面でキャンセル(ESC押下)した場合
                    // ・オフラインの場合
                    // ・認証が成功した場合
                    if ((wDialogResult == DialogResult.Cancel) || (!Login.LoginInfo.IsOnline) || Login.LoginInfo.IsAuthenticated)
                    {
                        wIsExitLoop = true;
                    }
                }

            }
            return wDialogResult;

        }
    }
}
