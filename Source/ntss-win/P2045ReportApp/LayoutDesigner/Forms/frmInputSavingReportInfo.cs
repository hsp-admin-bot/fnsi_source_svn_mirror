using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

using RldMsgBox = LayoutDesignerUtilityLib.RldMessageBox;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票保存設定画面
    /// </summary>
    public partial class frmInputSavingReportInfo : LayoutDesignerUtilityLib.Controls.frmRldBase
    {
        #region 生成と破棄

        /// <summary>
        /// 帳票保存設定画面の新しいインスタンスを初期化します。
        /// </summary>
        public frmInputSavingReportInfo()
        {
            InitializeComponent();

            // add #11574 編集中のタスクバーのアイコンがデフォルトになっている 高 start
            // アイコンの設定
            this.Icon = Properties.Resources.LayoutDesigner;
            // add #11574 編集中のタスクバーのアイコンがデフォルトになっている 高 end

            // イベントハンドラ割り当て
            this.btnOK.Click += new EventHandler(this.btnOK_Click);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 入力された帳票名の取得及び設定を行います。
        /// </summary>
        public String InputReportName { get; set; } = String.Empty;

        /// <summary>
        /// 表示する帳票とするかどうかの取得及び設定を行います。
        /// </summary>
        public Boolean IsDisplay { get; set; } = true; 

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            // 画面をクリア
            this.DataClear();

            // 禁則文字をツールチップへセット
            String wInvalidChars = String.Empty;
            foreach( var wChar in System.IO.Path.GetInvalidFileNameChars() ) {
                // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 start
                //if( wChar == '\0' ) continue;
                //wInvalidChars += wChar;
                if (wChar == '\0' || ((int)wChar > 0 && (int)wChar < 32)) continue;
                wInvalidChars += wChar + " ";
                // mod #7943 帳票レイアウトデザイナーが正しく動作しないの対応 夏 end
            }

            this.toolTipInputSavingReportInfo.SetToolTip(this.txtReportName, $"{wInvalidChars}は指定できません。");

            // 画面にデータを表示
            this.DataRead();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 画面をクリアします。
        /// </summary>
        private void DataClear()
        {
            this.txtReportName.Clear();
            this.chkIsHide.Checked = false;
        }

        /// <summary>
        /// 入力内容を確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean DataCheck()
        {
            const String MSG_TITLE = "確認してください";

            // 未入力チェック
            if( String.IsNullOrEmpty(this.txtReportName.Text) ) {
                RldMsgBox.Show(this, "帳票名を入力してください。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.txtReportName.Focus();

                return false;
            }

            // 禁則文字チェック
            if( this.txtReportName.Text.IndexOfAny(System.IO.Path.GetInvalidFileNameChars()) >= 0 ) {
                RldMsgBox.Show(this, "帳票名に指定できない文字が含まれています。", MSG_TITLE, MessageBoxButtons.OK, MessageBoxIcon.Exclamation);
                this.txtReportName.Focus();

                return false;
            }

            //// 帳票マスタに同名の帳票が登録されているか確認し、存在した場合は上書き確認
            //if( this.IsExistsSameNameReport() ) {
            //    var wMsg = new System.Text.StringBuilder();
            //    wMsg.AppendLine("同じ名前の帳票が既に登録されています。")
            //        .Append("上書きしてもよろしいですか？");

            //    if( RldMsgBox.Show(this, wMsg.ToString(), MSG_TITLE, MessageBoxButtons.YesNo, MessageBoxIcon.Question, MessageBoxDefaultButton.Button2) == DialogResult.No ) {
            //        this.txtReportName.Focus();
            //        return false;
            //    }
            //}

            return true;
        }

        /// <summary>
        /// 帳票マスタに同名の帳票が登録されているかどうか確認します。
        /// </summary>
        /// <returns></returns>
        private Boolean IsExistsSameNameReport()
        {
            return false;
        }

        /// <summary>
        /// 画面にデータを表示します。
        /// </summary>
        private void DataRead()
        {
            // 既定の帳票名をセット
            this.txtReportName.Text = this.InputReportName;
            this.chkIsHide.Checked = !this.IsDisplay;
        }

        #endregion

        #region コントロールイベントハンドラ定義

        /// <summary>
        /// OKボタンの Click イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnOK_Click(object sender, EventArgs e)
        {
            if( !this.DataCheck() ) return;
            this.InputReportName = this.txtReportName.Text;
            this.IsDisplay = !this.chkIsHide.Checked;

            this.DialogResult = DialogResult.OK;
        }

        #endregion
    }
}
