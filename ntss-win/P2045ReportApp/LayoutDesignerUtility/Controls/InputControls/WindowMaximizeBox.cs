using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// 最大化ボタンクラス
    /// </summary>
    public class WindowMaximizeBox : NoFocusButton
    {
        #region メンバ定数定義

        private const String FONT_NAME = "segoe mdl2 assets";
        private const String CHROME_MAXIMIZE = "E922";
        private const String CHROME_RESTORE = "E923";

        #endregion

        #region メンバ変数定義

        private ToolTip m_ToolTip = null;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 最大化ボタンクラスの新しいインスタンスを初期化します。
        /// </summary>
        public WindowMaximizeBox()
        {
            base.Anchor = AnchorStyles.Top | AnchorStyles.Right;
            base.FlatStyle = FlatStyle.Flat;
            base.FlatAppearance.BorderSize = 0;
            base.Font = new System.Drawing.Font(FONT_NAME, 9U);
            base.Size = new System.Drawing.Size(27, 25);
            base.Text = "最大化";
            base.UseVisualStyleBackColor = false;

            this.m_ToolTip = new ToolTip() {
                BackColor = System.Drawing.Color.White,
                ForeColor = System.Drawing.Color.Black
            };
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 親フォームへの参照の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        protected Form OwnerForm
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.FindForm();
            }
        }

        /// <summary>
        /// ボタンの状態の取得及び設定を行います。
        /// </summary>
        private System.Windows.Forms.VisualStyles.PushButtonState ButtonState { get; set; } = System.Windows.Forms.VisualStyles.PushButtonState.Normal;

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Control.Click イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnClick(EventArgs e)
        {
            base.OnClick(e);

            var wForm = base.FindForm();
            if(wForm != null) {
                switch( wForm.WindowState ) {
                    case FormWindowState.Maximized:
                        wForm.WindowState = FormWindowState.Normal;
                        base.Text = "最大化";
                        break;

                    case FormWindowState.Normal:
                        wForm.WindowState = FormWindowState.Maximized;
                        base.Text = "元に戻す";
                        break;

                    default:
                        break;
                }
            }
        }

        /// <summary>
        /// Control.EnabledChanged イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnEnabledChanged(EventArgs e)
        {
            base.OnEnabledChanged(e);

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Disabled:
                    this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Normal;
                    break;

                case System.Windows.Forms.VisualStyles.PushButtonState.Normal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Disabled;
                    break;
            }
            base.Invalidate();
        }

        /// <summary>
        /// Control.OnMouseEnter イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseEnter(EventArgs e)
        {
            base.OnMouseEnter(e);

            if( !base.Enabled ) return;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Hot:
                case System.Windows.Forms.VisualStyles.PushButtonState.Normal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Hot;
                    break;
            }

            this.m_ToolTip.SetToolTip(this, this.Text);
            this.m_ToolTip.Active = true;

            base.Invalidate();
        }

        /// <summary>
        /// Control.OnMouseLeave イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseLeave(EventArgs e)
        {
            base.OnMouseLeave(e);

            if( !base.Enabled ) return;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Hot:
                case System.Windows.Forms.VisualStyles.PushButtonState.Normal:
                case System.Windows.Forms.VisualStyles.PushButtonState.Pressed:
                    this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Normal;
                    break;
            }

            this.m_ToolTip.Active = false;

            base.Invalidate();

        }

        /// <summary>
        /// Control.OnMouseDown イベントを発生させます。
        /// </summary>
        /// <param name="mevent"></param>
        protected override void OnMouseDown(MouseEventArgs mevent)
        {
            base.OnMouseDown(mevent);

            if( mevent.Button != MouseButtons.Left ) return;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Hot:
                case System.Windows.Forms.VisualStyles.PushButtonState.Normal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Pressed;
                    break;
            }
            base.Invalidate();
        }

        /// <summary>
        /// Control.OnMouseUp イベントを発生させます。
        /// </summary>
        /// <param name="mevent"></param>
        protected override void OnMouseUp(MouseEventArgs mevent)
        {
            base.OnMouseUp(mevent);

            if( mevent.Button != MouseButtons.Left ) return;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Normal:
                case System.Windows.Forms.VisualStyles.PushButtonState.Pressed:
                    if( base.RectangleToScreen(this.ClientRectangle).Contains(Cursor.Position) )
                        this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Hot;
                    else
                        this.ButtonState = System.Windows.Forms.VisualStyles.PushButtonState.Normal;
                    break;
            }
            base.Invalidate();
        }

        /// <summary>
        /// Control.Paint イベントを発生させます。
        /// </summary>
        /// <param name="pevent"></param>
        protected override void OnPaint(PaintEventArgs pevent)
        {
            base.OnPaint(pevent);

            // 念のため確認
            if( this.OwnerForm == null ) return;

            base.SuspendLayout();

            // 背景色を決定
            var wBackColor = this.GetBackColor();

            // 背景を描画
            using( var wPen = new System.Drawing.SolidBrush(wBackColor) )
                pevent.Graphics.FillRectangle(wPen, pevent.ClipRectangle);

            // 文字コードを決定
            String wCharCode = CHROME_RESTORE;
            if( this.OwnerForm.WindowState == FormWindowState.Normal )
                wCharCode = CHROME_MAXIMIZE;

            Int32 wHexCharCode = Convert.ToInt32(wCharCode, 16);    // 16進数文字列 -> 数値
            Char wChar = Convert.ToChar(wHexCharCode);              // 数値(文字コード) -> 文字
            String wText = wChar.ToString();                        // 文字列

            // 前景色を決定
            var wForeColor = this.GetForeColor();

            // 文字列を描画
            using( var wPen = new System.Drawing.SolidBrush(wForeColor) )
            using( var wFont = new System.Drawing.Font(FONT_NAME, base.Font.Size) ) {
                pevent.Graphics.DrawString(
                    wText,
                    wFont,
                    wPen,
                    base.ClientRectangle,
                    new System.Drawing.StringFormat() {
                        Alignment = System.Drawing.StringAlignment.Center,
                        LineAlignment = System.Drawing.StringAlignment.Center
                    });
            }

            base.ResumeLayout();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// 背景色を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Drawing.Color GetBackColor()
        {
            var wRet = base.BackColor;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Hot:
                    wRet = System.Drawing.SystemColors.ButtonShadow;
                    break;

                case System.Windows.Forms.VisualStyles.PushButtonState.Pressed:
                    wRet = System.Drawing.SystemColors.HotTrack;
                    break;

                default:
                    break;
            }

            return wRet;
        }

        /// <summary>
        /// 前景色を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Drawing.Color GetForeColor()
        {
            var wRet = base.ForeColor;

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.PushButtonState.Disabled:
                    wRet = System.Drawing.SystemColors.ButtonShadow;
                    break;

                default:
                    break;
            }

            return wRet;
        }

        #endregion
    }
}
