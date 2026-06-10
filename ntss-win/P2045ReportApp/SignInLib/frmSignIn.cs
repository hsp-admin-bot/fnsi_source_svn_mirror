using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using NKKLoggingLib;
using NKKWebAccessLib;

using LayoutDesignerUtilityLib;

using RldUtility = LayoutDesignerUtilityLib.LayoutDesignerUtility;

using System.Net.Http;
using System.Drawing.Text;
using SignInLib.Properties;
using System.Reflection;

namespace SignInLib
{
    /// <summary>
    /// サインイン画面
    /// </summary>
    public partial class FrmSignIn : LayoutDesignerUtilityLib.Controls.frmRldBase
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

        #region 生成と破棄

        /// <summary>
        /// コンストラクタ
        /// </summary>
        /// 
        public FrmSignIn()
        {
            InitializeComponent();

            // アイコンの設定
            //this.Icon = Properties.Resources.LayoutDesigner;
            //this.Icon = signInClinet.Icon;
            //this.signInClient = signInClinet;

            // イベントハンドラ割り当て
            //this.btnSignIn.Click += new EventHandler(this.btnSignIn_Click);

            this.txtLoginID.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtPassword.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtFacility.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtLoginID.Leave += new EventHandler(this.OnKeyControlsLeave);
            this.txtPassword.Leave += new EventHandler(this.OnKeyControlsLeave);
            this.txtFacility.Leave += new EventHandler(this.OnKeyControlsLeave);

            if (String.IsNullOrEmpty(SignIn.SignInInfo.FacilityHashText) == false)
            {
                // 施設情報が設定済の場合
                this.pnlBodyBottom.Visible = false;
                this.Height -= this.pnlBodyBottom.Height;
            }
        }

        #endregion

        #region メンバ関数定義(override)

        /// <summary>
        /// 先頭コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void OnTopControlEnter(object sender, EventArgs e)
        {
            base.OnTopControlEnter(sender, e);

            // 前に行かないようにする
            this.SelectNextControl(this.ActiveControl, true, true, true, false);
        }

        /// <summary>
        /// フォーカスコントロール用コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void OnFocusControlEnter(object sender, EventArgs e)
        {
            base.OnFocusControlEnter(sender, e);

            // サインインボタンを押下する
            this.btnSignIn.PerformClick();
        }

        /// <summary>
        /// 最終コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected override void OnStopControlEnter(object sender, EventArgs e)
        {
            base.OnStopControlEnter(sender, e);

            // 先に行かないようにする
            this.SelectNextControl(this.ActiveControl, false, true, true, false);
        }

        private void FrmSignIn_FormClosed(object sender, FormClosedEventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, RldUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);
        }

        [System.Runtime.InteropServices.DllImport("gdi32.dll", ExactSpelling = true)]
        private static extern IntPtr AddFontMemResourceEx(byte[] pbFont, int cbFont, IntPtr pdv, out uint pcFonts);

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, RldUtility.PRODUCT_NAME,
                GetType().Name, NKKLogging.LOGGING_CLASS.INFO, MethodBase.GetCurrentMethod().Name);

            base.OnLoad(e);

            if (this.DesignMode)
            {
                return;
            }

            // 画面をクリア
            this.DataClear();

            // あらかじめ設定されている接続情報をセット
            this.txtLoginID.Text = SignIn.SignInInfo.LoginID;
            this.txtPassword.Text = SignIn.SignInInfo.Password;
            this.txtFacility.Text = SignIn.SignInInfo.FacilityHashText;

            // フォーカスを先頭に移動
            base.btnTop.Focus();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面に表示中のデータをクリアします。
        /// </summary>
        private void DataClear()
        {
            this.txtLoginID.Clear();
            this.txtPassword.Clear();
            this.txtFacility.Clear();
        }

        /// <summary>
        /// 画面の入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            const String MSG_TITLE = "確認してください";

            // ID 確認
            if (String.IsNullOrWhiteSpace(this.txtLoginID.Text))
            {
                RldMessageBox.Show(this, "ユーザーIDが未入力です。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);

                this.txtLoginID.Focus();
                return false;
            }

            // パスワード確認(チェックしない)

            // 施設ハッシュ確認
            if (String.IsNullOrWhiteSpace(this.txtFacility.Text))
            {
                RldMessageBox.Show(this, "施設情報が未入力です。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);

                this.txtFacility.Focus();
                return false;
            }

            return true;
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
                NKKWebAccess.UrlEncodeFacilityHash = this.txtFacility.Text;
                NKKWebAccess.BaseUri = RldUtility.BaseUri;
              
                var wMsg = new System.Text.StringBuilder();

                NKKWebAccess.GetInstance(); // コンストラクタを走らせるため

                var nwar = await NKKWebAccess.ServerLogin("");
                wResult = int.Parse(nwar.strContent);

                if (wResult == (Int32)EnumLoginResult.Failusure)
                {
                    // 認証エラー時(0)
                    string reasonPhraseCrLf = nwar.response.ReasonPhrase.Replace("<BR>", "\r\n").Replace("<br>", "\r\n"); // 念のため大文字も小文字も

                    // [ユーザIDが存在しない]場合の認証エラーのメッセージ(※REST側で実装)だった
                    if ("bad credentials" == reasonPhraseCrLf.ToLower())
                    {
                        // [ユーザIDが存在したがPW間違い]の場合のメッセージ(※REST側で実装)と同一にすることで「ユーザIDの存在確認」として利用させない
                        reasonPhraseCrLf = "認証に失敗しました。認証情報を確認して下さい。";
                    }

                    RldMessageBox.Show(this, reasonPhraseCrLf, "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
               
                }
                else
                {
                    // サーバ未到達 or サインイン成功

                    // 入力内容を記憶
                    SignIn.SignInInfo.LoginID = this.txtLoginID.Text;
                    SignIn.SignInInfo.Password = this.txtPassword.Text;
                    SignIn.SignInInfo.FacilityHashText = this.txtFacility.Text;

                    if (wResult == (int)EnumLoginResult.NotConnect)
                    {
                        // サーバ未到達時(-1)
                        wMsg.Length = 0;

                        if (nwar.response.ReasonPhrase.CompareTo("このユーザーはアカウントロックされています。管理者にお問い合わせください。") == 0)
                        {
                            wMsg.AppendLine(nwar.response.ReasonPhrase);
                        }
                        else
                        {
                            wMsg.AppendLine("サーバに接続できませんでした。");
                        }
                        string strBaseName = RldUtility.BaseName.Trim();
                        if (strBaseName.Equals("CoopEventCreateOrStopTool"))
                        {
                            // add #6137　2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る  孟堅 statr
                            wMsg.Clear();
                            wMsg.AppendLine("ログインできませんでした。ID、パスワード、接続設定をご確認ください。");
                            // add　#6137 2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る 　孟堅 end
                            // del  #6137　2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る　孟堅 statr
                            // wMsg.AppendLine("アプリを終了します。");
                            // del  #6137 2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る　孟堅 end 
                            RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        }
                        else
                        {
                            wMsg.AppendLine("オフラインモードで動作しますか？");

                            if (RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.No)
                            {
                                wResult = -2;
                            }
                        }
                    }
                    else
                    {
                        // サインイン成功時(1)
                        bool isSignedIn = false;

                        // 応答取得 と JSON分解
                        string strdata = Task.Run(() => nwar.response.Content.ReadAsStringAsync()).Result;
                        Dictionary<String, String> tbl = NKKWebAccess.GetJsonData(strdata);
                        if (tbl.ContainsKey("code") && "2" == tbl["code"])
                        {
                            // {"code":"2"} は 「施設設定の2要素認証設定が必須使用」で秘密鍵未発行 or 初回のOTP確認が未完了の場合の戻り値

                            wResult = (Int32)EnumLoginResult.Failusure;
                            RldMessageBox.Show(this,
                                "施設設定の2要素認証設定が必須使用となっていますが\r\n本ユーザーIDのアカウントでは2要素認証のための設定が未完了です。\r\n管理者にお問い合わせください。",
                                "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        }
                        else if (tbl.ContainsKey("code") && "1" == tbl["code"])
                        {
                            // {"code":"1"} は WebCLでOTP画面に遷移させる場合の戻り値

                            int otpFailureCnt = 5;
                            var ret = await GetSystemOtpFailureCntByHashValue();
                            if (ret.isSuccess)
                            {
                                otpFailureCnt = int.Parse(ret.getData);
                            }

                            // <2要素認証のOTP確認処理>
                            for (int i = 0; i < otpFailureCnt; i++)
                            {
                                wResult = (int)EnumLoginResult.Failusure; // PG構造上、OTP確認の開始時には一旦[認証エラー]で始める

                                FrmOtpInput foi = new FrmOtpInput();
                                if (DialogResult.OK == foi.ShowDialog())
                                {
                                    var nwarInner = await NKKWebAccess.ServerLogin(foi.Tag.ToString());
                                    wResult = int.Parse(nwarInner.strContent);

                                    if (wResult == (Int32)EnumLoginResult.Failusure)
                                    {
                                        // 認証エラー時(0)
                                        string reasonPhraseCrLf = nwarInner.response.ReasonPhrase.Replace("<BR>", "\r\n").Replace("<br>", "\r\n"); // 念のため大文字も小文字も

                                        // [ユーザIDが存在しない]場合の認証エラーのメッセージ(※REST側で実装)だった
                                        if ("bad credentials" == reasonPhraseCrLf.ToLower())
                                        {
                                            // [ユーザIDが存在したがPW間違い]の場合のメッセージ(※REST側で実装)と同一にすることで「ユーザIDの存在確認」として利用させない
                                            reasonPhraseCrLf = "認証に失敗しました。認証情報を確認して下さい。";
                                        }

                                        if (i + 1 >= otpFailureCnt)
                                        {
                                            // OTP試行回数上限まで失敗したら固定エラー文言(※WebCLも同じ仕様)に置き換え
                                            reasonPhraseCrLf = $"2要素認証に{otpFailureCnt}回失敗しましたので\r\n2要素認証割り当てデバイスを確認いただき\r\nサインインからやり直してください。";
                                        }
                                        RldMessageBox.Show(this, reasonPhraseCrLf, "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                    }
                                    else
                                    {
                                        // サーバ未到達 or サインイン成功
                                        if (wResult == (int)EnumLoginResult.NotConnect)
                                        {
                                            // サーバ未到達時(-1)
                                            wMsg.Length = 0;
                                            wMsg.AppendLine("サーバに接続できませんでした。");
                                            string strBaseName = RldUtility.BaseName.Trim();
                                            if (strBaseName.Equals("CoopEventCreateOrStopTool"))
                                            {
                                                wMsg.AppendLine("アプリを終了します。");
                                                RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                                            }
                                            else
                                            {
                                                wMsg.AppendLine("オフラインモードで動作しますか？");

                                                if (RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.YesNo, MessageBoxIcon.Warning) == DialogResult.No)
                                                {
                                                    wResult = -2;
                                                }
                                            }

                                            break;
                                        }
                                        else
                                        {
                                            // サインイン成功時(1)
                                            isSignedIn = true;

                                            break;
                                        }
                                    }
                                }
                                else
                                {
                                    // キャンセルされたらOTP繰り返し確認をやめる
                                    break;
                                }
                            }
                            // </>
                        }
                        else
                        {
                            // 2要素認証不要だったのでサインイン完了
                            isSignedIn = true;
                        }

                        if (isSignedIn)
                        {
                            // ログ出力クラスへ施設コードをセット
                            NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                            // ログ記録：施設コード
                            NKKLogging.GetInstance().AddLogInfo(DateTime.Now, RldUtility.PRODUCT_NAME, GetType().Name,
                                NKKLogging.LOGGING_CLASS.INFO, String.Format("施設コード:{0}", NKKWebAccess.FacilityCd));

                            // 追加情報を記憶
                            SignIn.SignInInfo.FacilityCode = NKKWebAccess.FacilityCd;
                            SignIn.SignInInfo.IsAuthenticated = true;
                            SignIn.SignInInfo.IsOnline = true;

                            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 start
                            SignIn.SignInInfo.UserFirstName = NKKWebAccess.UserFirstName;
                            SignIn.SignInInfo.UserLastName = NKKWebAccess.UserLastName;
                            // add 2020-11-19 FNWで実現していた、「以前の帳票に戻す」機能を追加する 孫 end
                            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 start
                            SignIn.SignInInfo.UserType = NKKWebAccess.UserType;
                            // add 2021-01-29 No.631:日機装ユーザでログインした際には、「施設選択コンボ」を設置 商 end
                        }
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
        /// フォームをモーダル ダイアログ ボックスとして表示します
        /// </summary>
        /// <param name="signIn">IFrmSignInインタフェース</param>
        /// <returns>DialogResult 値のいずれか 1 つです</returns>
        public static DialogResult ShowSignInDialog(Icon icon, Func<string, string, bool> func)
        {

            DialogResult wDialogResult = DialogResult.None;

            // サインイン画面を表示
            using (var wDlg = new FrmSignIn())
            {

                // Iconと施設情報を保存するメソッドを保存
                wDlg.Icon = icon;
                wDlg.saveFacilityInfo = func;

                bool wIsExitLoop = false;

                while (!wIsExitLoop)
                {

                    // サインイン画面を表示して入力結果を取得
                    wDialogResult = wDlg.ShowDialog();

                    // 以下の場合は抜ける
                    // ・サインイン画面でキャンセル(ESC押下)した場合
                    // ・オフラインの場合
                    // ・認証が成功した場合
                    if ((wDialogResult == DialogResult.Cancel) || (!SignIn.SignInInfo.IsOnline) || SignIn.SignInInfo.IsAuthenticated)
                    {
                        wIsExitLoop = true;
                    }
                }

            }
            return wDialogResult;

        }

        /// <summary>
        /// 2要素認証失敗許容回数を取得(※サインイン前に実施可能)
        /// </summary>
        /// <returns>2要素認証失敗許容回数</returns>
        private async Task<(bool isSuccess, string errorReasonPhrase, string getData)> GetSystemOtpFailureCntByHashValue()
        {
            (bool isSuccess, string errorReasonPhrase, string getData) ret = (false, "", "");
            string restUri = "";

            try
            {
                restUri = NKKWebAccess.BaseUri + $"/ntss-admin-web/api/facilities/MstFacilityHash/OtpFailureCnt/hash?hashValue={NKKWebAccess.FacilityHash}";
                var restRes = await NKKWebAccess.GetNoSignIn(MethodBase.GetCurrentMethod().Name, restUri);

                ret.isSuccess = restRes.response.IsSuccessStatusCode;
                ret.errorReasonPhrase
                    = string.IsNullOrWhiteSpace(restRes.response.ReasonPhrase) ? $"{(int)restRes.response.StatusCode}:{restRes.response.StatusCode}" : restRes.response.ReasonPhrase;
                if (ret.isSuccess)
                {
                    ret.getData = restRes.strContent;
                }
            }
            catch (Exception ex)
            {
                NKKLogging.GetInstance().AddLogInfo(DateTime.Now, RldUtility.PRODUCT_NAME, GetType().Name, NKKLogging.LOGGING_CLASS.ERROR,
                    String.Format("ログイン失敗,{0},{1}", restUri, ex.ToString().Replace("\r\n", "{CRLF}")));
            }

            return ret;
        }

        #endregion

        #region イベントハンドラ定義

        /// <summary>
        /// 入力キー項目用コントロールの Enter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnKeyControlsEnter(Object sender, System.EventArgs e)
        {
            base.btnFocusControl.TabStop = true;
        }

        /// <summary>
        /// 入力キー項目用コントロールの Leave イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnKeyControlsLeave(Object sender, System.EventArgs e)
        {
            base.btnFocusControl.TabStop = false;
        }

        private Func<string, string, bool> saveFacilityInfo;

        /// <summary>
        /// サインインボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void btnSignIn_Click(object sender, EventArgs e)
        {
            // 入力チェックでエラーが発生した場合は抜ける
            if (!this.DataCheck())
            {
                return;
            }

            // デバッグ用スーパーユーザの場合
            if (SignIn.IsSuperUser(this.txtLoginID.Text, this.txtPassword.Text))
            {
                SignIn.SignInInfo.LoginID = this.txtLoginID.Text;
                SignIn.SignInInfo.IsAuthenticated = true;
                SignIn.SignInInfo.IsOnline = false;

                // 表示結果をセット
                this.DialogResult = DialogResult.OK;

                return;
            }

            try
            {
                // ボタンを押せないようにする
                this.btnSignIn.Enabled = false;

                // サインイン処理実行
                var wResult = await this.ExecSingin();

                // サインインが成功して、初回サインイン時は施設ハッシュの保存を行うか確認
                if ((wResult == EnumLoginResult.Success) && (this.pnlBodyBottom.Visible))
                {

                    var wMsg = new System.Text.StringBuilder();
                    wMsg.Length = 0;
                    wMsg.AppendLine("入力された施設情報を保存します。")
                        .Append("よろしいですか？");

                    // 保存確認ダイアログで［はい］が選択された場合、施設コードと施設ハッシュ値を保存する
                    if ((RldMessageBox.Show(this, wMsg.ToString(), "確認してください", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes)
                        && (this.saveFacilityInfo != null) && !this.saveFacilityInfo(SignIn.SignInInfo.FacilityCode, SignIn.SignInInfo.FacilityHashText))
                    {
                        // 保存失敗
                        wMsg.Length = 0;
                        wMsg.AppendLine("施設情報の保存に失敗しました。")
                            .Append("次回サインイン時に再度入力してください。");
                        RldMessageBox.Show(this, wMsg.ToString(), "処理中にエラーが発生しました", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                }

                // 認証エラー時はユーザーIDに移動

                // mod 2021-08-23 #6137:ログインに失敗した場合はプログラムを終了しないでください 鄭 start
                //if (wResult == EnumLoginResult.Failusure)
                //{
                //    this.txtLoginID.Focus();
                //}
                //// 認証エラー以外は閉じる
                //else
                //{
                //    this.DialogResult = DialogResult.OK;
                //}

               //string strFi = System.IO.Path.GetFileName(Application.ExecutablePath);
                string strBaseName = RldUtility.BaseName.Trim();             
                if (strBaseName.Equals("CoopEventCreateOrStopTool"))
                {
                    if (wResult == EnumLoginResult.Failusure)
                    {
                        this.txtLoginID.Focus();
                    }
                    else if  (wResult == EnumLoginResult.NotConnect)
                    {
                        // del　#6137 2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る　孟堅  start
                        // this.DialogResult = DialogResult.Cancel;
                        // del  #6137 2022-01-07　ログインに失敗するとオフラインモードで起動するメッセージが出る　孟堅 end
                    }
                    // 認証エラー以外は閉じる
                    else
                    {
                        this.DialogResult = DialogResult.OK;
                    }

                }
                else {
                    if (wResult == EnumLoginResult.Failusure)
                    {
                        this.txtLoginID.Focus();
                    }
                    else if (wResult == EnumLoginResult.Abort)
                    {
                        this.DialogResult = DialogResult.Abort;
                    }
                    // 認証エラー以外は閉じる
                    else
                    {
                        this.DialogResult = DialogResult.OK;
                    }
                }
               
               
                // mod 2021-08-23 #6137:ログインに失敗した場合はプログラムを終了しないでください 鄭 end


            }
            catch (Exception ex)
            {
                RldUtility.RecordException(this, ex, true);
            }
            finally
            {
                // ボタンを押せるようにする
                this.btnSignIn.Enabled = true;
            }
        }

        #endregion

        // add #11501 レイアウトデザイナのユーザビリティ改善 高 start
        private void txtLoginID_Enter(object sender, EventArgs e)
        {
            txtLoginID.SelectAll();
        }

        private void txtPassword_Enter(object sender, EventArgs e)
        {
            txtPassword.SelectAll();
        }
        // add #11501 レイアウトデザイナのユーザビリティ改善 高 end
    }
}
