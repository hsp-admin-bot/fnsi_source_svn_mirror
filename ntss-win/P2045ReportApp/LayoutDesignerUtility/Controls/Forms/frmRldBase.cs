using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    public partial class frmRldBase : Form
    {
        #region メンバ定数定義

        /// <summary>
        /// CS_NOCLOSE
        /// </summary>
        private const int CS_NOCLOSE = 0x200;

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// 閉じるボタンの使用有無
        /// </summary>
        private Boolean m_CloseBox = true;

        #endregion
        
        #region 生成と破棄

        /// <summary>
        /// フォームのインスタンスを生成します。
        /// </summary>
        public frmRldBase()
        {
            InitializeComponent();
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 閉じるボタンを有効にするかどうかの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category("ウィンドウ スタイル")]
        [System.ComponentModel.Description("フォームがキャプション バーの右上に閉じるボタンを指定するかどうかを決定します。")]
        [System.ComponentModel.DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Boolean CloseBox
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_CloseBox;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_CloseBox = value;
                base.UpdateStyles();
                base.RecreateHandle();
            }
        }

        /// <summary>
        /// Escape キーの押下でウィンドウを閉じるかどうかの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category("Custom Property")]
        [System.ComponentModel.Description("フォームが Escape キーの押下で終了するかどうかを決定します。")]
        [System.ComponentModel.DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Boolean CloseEscapeKey { get; set; } = true;

        /// <summary>
        /// Enter キーの押下でタブインデックスが次のコントロールにフォーカスを移動するかどうかの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category("Custom Property")]
        [System.ComponentModel.Description("フォームが Enter キーの押下で次のコントロールへフォーカスを移動するかどうかを決定します。")]
        [System.ComponentModel.DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public Boolean MoveNextEnterKey { get; set; } = true;

        /// <summary>
        /// コントロール ハンドルが作成されるときに必要な作成パラメーターを取得します。
        /// </summary>
        protected override CreateParams CreateParams
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                //return base.CreateParams;
                var wParams = base.CreateParams;

                if( !this.CloseBox )
                    wParams.ClassStyle |= CS_NOCLOSE;

                return wParams;
            }
        }
              
        #endregion

        #region メンバ関数定義

        /// <summary>
        /// Form.Load イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnLoad(EventArgs e)
        {
            base.OnLoad(e);

            if( this.DesignMode ) return;

            // 非表示用コントロールの設定
            this.btnFocusControl.Left = this.Width * -1;
            this.btnTop.Left = this.Width * -1;
            this.btnStop.Left = this.Width * -1;
        }

        /// <summary>
        /// Control.OnKeyDown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnKeyDown(KeyEventArgs e)
        {
            var wActiveControl = this.ActiveControl;

            if( e.KeyCode == Keys.Return) {
                if(this.MoveNextEnterKey && wActiveControl != null ) {

                    // フォームの場合は自前の処理を行う。
                    if( wActiveControl is System.Windows.Forms.Form ) return;
                    // DataGridView コントロールの場合は自前の処理を行う。
                    if( wActiveControl is System.Windows.Forms.DataGridView ) return;
                    // DataGridViewComboBoxEditingControl の場合は自前の処理を行う。
                    if( wActiveControl is System.Windows.Forms.DataGridViewComboBoxEditingControl ) return;

                    // TextBox で且つマルチラインでリターンキーで改行できるの場合は自前の処理を行う。
                    if( wActiveControl is System.Windows.Forms.TextBox ) {
                        var wTextBox = wActiveControl as System.Windows.Forms.TextBox;
                        if( wTextBox != null && wTextBox.Multiline && wTextBox.AcceptsReturn ) return;
                    }

                    this.SelectNextControl(wActiveControl, !e.Shift, true, true, false);

                    e.Handled = true;
                }
            }
            // add 2020-08-10 FNSI-仕様追加 ショートカットキー機能を追加 李 start
            // システムヘルプファイルをF1ボタンで開く
            else if (e.KeyCode == Keys.F1)
            {
                string docPath = System.IO.Path.Combine(AppDomain.CurrentDomain.BaseDirectory, LayoutDesignerUtility.HelpDocument);
                if (File.Exists(docPath))
                    System.Diagnostics.Process.Start(docPath);
                else
                    MessageBox.Show("ヘルプファイルが存在しません、確認してください!");
            }
            // add 2020-08-10 FNSI-仕様追加 ショートカットキー機能を追加 李 end

            base.OnKeyDown(e);
        }

        /// <summary>
        /// Control.OnKeyPress イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnKeyPress(KeyPressEventArgs e)
        {
            bool wIsHandled = false;

            if( e.KeyChar == (char)System.Windows.Forms.Keys.Return ) {
                var wTextBox = this.ActiveControl as System.Windows.Forms.TextBox;
                if( (wTextBox != null) && (wTextBox.Multiline) && (wTextBox.AcceptsReturn) ) return;

                wIsHandled = true;
            }
            else if( (e.KeyChar == (char)System.Windows.Forms.Keys.Escape) && (this.CloseEscapeKey)) {
                wIsHandled = true;
                base.Close();
            }

            e.Handled = wIsHandled; // Beep音対策

            base.OnKeyPress(e);
        }

        /// <summary>
        /// 先頭コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void OnTopControlEnter(Object sender, System.EventArgs e) { }

        /// <summary>
        /// フォーカスコントロール用コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void OnFocusControlEnter(object sender, System.EventArgs e) { }

        /// <summary>
        /// 最終コントロールで Enter イベントが発生した場合に呼び出されます。
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        protected virtual void OnStopControlEnter(Object sender, System.EventArgs e) { }

        /// <summary>
        /// ウィンドウタイトルを設定します。
        /// </summary>
        /// <param name="wTitle"></param>
        protected void SetWindowTitle(string wTitle)
        {
            this.winlblTitle.Text = wTitle;
        }

        #endregion

        #region イベントハンドラ定義

        /// <summary>
        /// フォーカスコントロール用コントロールの Enter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnFocusControl_Enter(object sender, EventArgs e)
        {
            this.OnFocusControlEnter(sender, e);
        }

        /// <summary>
        /// 先頭コントロールの Enter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnTop_Enter(object sender, EventArgs e)
        {
            this.OnTopControlEnter(sender, e);
        }

        /// <summary>
        /// 行き止まりコントロールの Enter イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void btnStop_Enter(object sender, EventArgs e)
        {
            this.OnStopControlEnter(sender, e);
        }

        #endregion
    }
}
