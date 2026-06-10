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

namespace LayoutDesigner
{
    /// <summary>
    /// サインイン画面
    /// </summary>
    public partial class frmSignIn : LayoutDesignerUtilityLib.Controls.frmRldBase
    {
        #region メンバ列挙体定義

        /// <summary>
        /// サーバログイン結果
        /// </summary>
        private enum EnumLoginResult
        {
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
        public frmSignIn()
        {
            InitializeComponent();

            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;

            // イベントハンドラ割り当て
            //this.btnSignIn.Click += new EventHandler(this.btnSignIn_Click);

            this.txtLoginID.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtPassword.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtFacility.Enter += new EventHandler(this.OnKeyControlsEnter);
            this.txtLoginID.Leave += new EventHandler(this.OnKeyControlsLeave);
            this.txtPassword.Leave += new EventHandler(this.OnKeyControlsLeave);
            this.txtFacility.Leave += new EventHandler(this.OnKeyControlsLeave);

            if( String.IsNullOrEmpty(RldLib.SignInInfo.FacilityHashText) == false ) {
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

        /// <summary>
        /// Form.OnFormClosing イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnFormClosing(FormClosingEventArgs e)
        {
            base.OnFormClosing(e);
        }

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if( this.DesignMode ) return;
            
            // 画面をクリア
            this.DataClear();

            // あらかじめ設定されている接続情報をセット
            this.txtLoginID.Text = RldLib.SignInInfo.LoginID;
            this.txtPassword.Text = RldLib.SignInInfo.Password;
            this.txtFacility.Text = RldLib.SignInInfo.FacilityHashText;

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
            if( String.IsNullOrWhiteSpace(this.txtLoginID.Text) ) {
                RldMessageBox.Show(this, "ログインIDが未入力です。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Warning);

                this.txtLoginID.Focus();
                return false;
            }

            // パスワード確認(チェックしない)

            // 施設ハッシュ確認
            if( String.IsNullOrWhiteSpace(this.txtFacility.Text) ) {
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

            try {
                // ログイン処理開始
                NKKWebAccess.UserId = this.txtLoginID.Text;
                NKKWebAccess.Password = this.txtPassword.Text;
                NKKWebAccess.UrlEncodeFacilityHash = this.txtFacility.Text;
                NKKWebAccess.BaseUri = RldUtility.BaseUri;

                var wMsg = new System.Text.StringBuilder();

                NKKWebAccess.GetInstance(); // コンストラクタを走らせるため
                wResult = await NKKWebAccess.ServerLogin();
                if( wResult == (Int32)EnumLoginResult.Failusure ) {
                    // 認証エラー時

                    wMsg.Length = 0;
                    wMsg.AppendFormat("認証エラーが発生しました。{0}ログインID、パスワード", System.Environment.NewLine);
                    if( this.pnlBodyBottom.Visible ) wMsg.Append("、施設情報");
                    wMsg.Append("を確認してください。");

                    RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                }
                else {
                    // サーバ未到達 or サインイン成功

                    // 入力内容を記憶
                    RldLib.SignInInfo.LoginID = this.txtLoginID.Text;
                    RldLib.SignInInfo.Password = this.txtPassword.Text;
                    RldLib.SignInInfo.FacilityHashText = this.txtFacility.Text;

                    if( wResult == (int)EnumLoginResult.NotConnect ) {
                        // サーバ未到達時
                        wMsg.Length = 0;
                        wMsg.AppendLine("サーバに接続できませんでした。")
                            .Append("オフラインモードで動作します。");
                        RldMessageBox.Show(this, wMsg.ToString(), "サインインエラー", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                    }
                    else {
                        // サインイン成功時

                        // ログ出力クラスへ施設コードをセット
                        NKKLogging.GetInstance().FacilityCd = NKKWebAccess.FacilityCd;

                        // ログ記録：施設コード
                        NKKLogging.GetInstance().AddLogInfo(DateTime.Now, RldUtility.PRODUCT_NAME, NKKLogging.LOGGING_CLASS.INFO, String.Format("施設コード:{0}", NKKWebAccess.FacilityCd));

                        // 追加情報を記憶
                        RldLib.SignInInfo.FacilityCode = NKKWebAccess.FacilityCd;
                        RldLib.SignInInfo.IsAuthenticated = true;
                        RldLib.SignInInfo.IsOnline = true;
                    }
                }
            }
            catch{
                throw;
            }
            finally {

            }

            return (EnumLoginResult)wResult;
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

        /// <summary>
        /// サインインボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private async void btnSignIn_Click(object sender, EventArgs e)
        {
            // 入力チェックでエラーが発生した場合は抜ける
            if( !this.DataCheck() ) return;

            // デバッグ用スーパーユーザの場合
            if( RldLib.IsSuperUser(this.txtLoginID.Text, this.txtPassword.Text) ) {
                RldLib.SignInInfo.LoginID = this.txtLoginID.Text;
                RldLib.SignInInfo.IsAuthenticated = true;
                RldLib.SignInInfo.IsOnline = false;

                // 表示結果をセット
                this.DialogResult = DialogResult.OK;

                return;
            }

            try {
                // ボタンを押せないようにする
                this.btnSignIn.Enabled = false;

                // サインイン処理実行
                var wResult = await this.ExecSingin();

                // サインインが成功して、初回サインイン時は施設ハッシュの保存を行うか確認
                if( (wResult == EnumLoginResult.Success) && (this.pnlBodyBottom.Visible) ) {

                    var wMsg = new System.Text.StringBuilder();
                    wMsg.Length = 0;
                    wMsg.AppendLine("入力された施設情報を保存します。")
                        .AppendLine("保存された施設情報は変更出来ません。")
                        .Append("続行してよろしいですか？");

                    if( RldMessageBox.Show(this, wMsg.ToString(), "確認してください", MessageBoxButtons.YesNo, MessageBoxIcon.Question) == DialogResult.Yes ) {

                        // 施設コードと施設ハッシュ値を保存
                        if( !RldUtility.SaveFacilityInfo(RldLib.SignInInfo.FacilityCode, RldLib.SignInInfo.FacilityHashText) ) {
                            // 保存失敗
                            wMsg.Length = 0;
                            wMsg.AppendLine("施設情報の保存に失敗しました。")
                                .Append("次回サインイン時に再度入力してください。");
                            RldMessageBox.Show(this, wMsg.ToString(), "処理中にエラーが発生しました", MessageBoxButtons.OK, MessageBoxIcon.Warning);
                        }
                    }
                }

                // 認証エラー時はユーザーIDに移動
                if( wResult == EnumLoginResult.Failusure )
                    this.txtLoginID.Focus();
                // 認証エラー以外は閉じる
                else
                    this.DialogResult = DialogResult.OK;
            }
            catch( Exception ex ) {
                RldUtility.RecordException(this, ex, true);
            }
            finally {
                // ボタンを押せるようにする
                this.btnSignIn.Enabled = true;
            }
        }

        #endregion
    }
}
