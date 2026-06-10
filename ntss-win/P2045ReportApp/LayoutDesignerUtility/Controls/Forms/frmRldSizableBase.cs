using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// 境界線の無いフォームを表します。
    /// </summary>
    public partial class frmRldSizableBase : frmRldBase
    {
        #region メンバ定数定義

        /// <summary>
        /// フォームの境界線のサイズ
        /// </summary>
        private const int BORDER_SIZE = 2;

        /// <summary>
        /// ウィンドウメッセージ(WM_NCHITTEST)
        /// </summary>
        private const int WM_NCHITTEST = 0x0084;

        private const int HTLEFT = 10;
        private const int HTRIGHT = 11;
        private const int HTTOP = 12;
        private const int HTTOPLEFT = 13;
        private const int HTTOPRIGHT = 14;
        private const int HTBOTTOM = 15;
        private const int HTBOTTOMLEFT = 16;
        private const int HTBOTTOMRIGHT = 17;

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// フォームの境界線の色
        /// </summary>
        private System.Drawing.Color m_FormBorderColor = System.Drawing.Color.Empty;

        ///// <summary>
        ///// フォームの内側の余白サイズ
        ///// </summary>
        //private System.Windows.Forms.Padding m_Padding = new System.Windows.Forms.Padding(BORDER_SIZE);

        /// <summary>
        /// フォームの境界線の色の既定値
        /// </summary>
        private readonly System.Drawing.Color DefaultValueFormBorderColor = SystemColors.WindowFrame;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 境界線の無いフォームの新しいインスタンスを初期化します。
        /// </summary>
        public frmRldSizableBase()
        {
            InitializeComponent();

            // フォームの境界線は常に無し
            base.FormBorderStyle = FormBorderStyle.None;

            // 余白をセット(これを行わないとリサイズできない)
            base.Padding = new System.Windows.Forms.Padding(BORDER_SIZE);

            base.DoubleBuffered = true;
            base.SetStyle(ControlStyles.ResizeRedraw, true);

            // 既定値にリセットしておく
            this.ResetFormBorderColor();
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// フォームの境界線スタイルを取得します。
        /// </summary>
        public new System.Windows.Forms.FormBorderStyle FormBorderStyle
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get
            {
                return FormBorderStyle.Sizable;
            }
        }

        /// <summary>
        /// フォームの境界線の色を取得または設定します。
        /// </summary>
        [System.ComponentModel.Category("表示")]
        [System.ComponentModel.Description("フォームの周りの境界線の色を指定します。")]
        [System.ComponentModel.DesignerSerializationVisibility(DesignerSerializationVisibility.Visible)]
        public System.Drawing.Color FormBorderColor
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_FormBorderColor;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_FormBorderColor = value;
                this.Invalidate();
            }
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        protected virtual bool ShouldSerializeFormBorderColor()
        {
            return !(this.m_FormBorderColor == this.DefaultValueFormBorderColor);
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public virtual void ResetFormBorderColor()
        {
            this.FormBorderColor = this.DefaultValueFormBorderColor;
        }

        /// <summary>
        /// コントロールの埋め込みを取得または設定します。
        /// </summary>
        public new System.Windows.Forms.Padding Padding
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return base.Padding;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                var wValue = new System.Windows.Forms.Padding(0);

                wValue.Top = value.Top >= BORDER_SIZE ? value.Top : BORDER_SIZE;
                wValue.Left = value.Left >= BORDER_SIZE ? value.Left : BORDER_SIZE;
                wValue.Bottom = value.Bottom >= BORDER_SIZE ? value.Bottom : BORDER_SIZE;
                wValue.Right = value.Right >= BORDER_SIZE ? value.Right : BORDER_SIZE;

                base.Padding = wValue;
            }
        }

        /// <summary>
        /// フォームの境界線領域(上側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle TopBorderArea
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    0, 0, this.ClientSize.Width, this.Padding.Top);
            }
        }

        /// <summary>
        /// フォームの境界線領域(左側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle LeftBorderArea
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    0, 0, this.Padding.Left, this.ClientSize.Height);
            }
        }

        /// <summary>
        /// フォームの境界線領域(下側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle BottomBorderArea
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    0, this.ClientSize.Height - this.Padding.Bottom, this.ClientSize.Width, this.Padding.Bottom);
            }
        }

        /// <summary>
        /// フォームの境界線領域(右側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle RightBorderArea
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    this.ClientSize.Width - this.Padding.Right, 0, this.Padding.Right, this.ClientSize.Height);
            }
        }

        /// <summary>
        /// フォームのヒットテスト領域(左上側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle TopLeft
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    0, 0, this.Padding.Left, this.Padding.Top);
            }
        }

        /// <summary>
        /// フォームのヒットテスト領域(右上側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle TopRight
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    this.ClientSize.Width - this.Padding.Right, 0, this.Padding.Right, this.Padding.Top);
            }
        }

        /// <summary>
        /// フォームのヒットテスト領域(左下側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle BottomLeft
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    0, this.ClientSize.Height - this.Padding.Bottom, this.Padding.Left, this.Padding.Bottom);
            }
        }

        /// <summary>
        /// フォームのヒットテスト領域(右下側)の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        private System.Drawing.Rectangle BottomRight
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return new System.Drawing.Rectangle(
                    this.ClientSize.Width - this.Padding.Right, this.ClientSize.Height - this.Padding.Bottom, this.Padding.Right, this.Padding.Bottom);
            }
        }

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Control.Paint イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnPaint(PaintEventArgs e)
        {
            base.OnPaint(e);

            using( var wBrush = new System.Drawing.SolidBrush(this.FormBorderColor) ) {
                e.Graphics.FillRectangle(wBrush, this.TopBorderArea);
                e.Graphics.FillRectangle(wBrush, this.LeftBorderArea);
                e.Graphics.FillRectangle(wBrush, this.RightBorderArea);
                e.Graphics.FillRectangle(wBrush, this.BottomBorderArea);
            }
        }

        /// <summary>
        /// Windows メッセージを処理します。
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);

            if( m.Msg == WM_NCHITTEST ) {

                // マウスカーソル位置を取得
                var wCursorPos = this.PointToClient(System.Windows.Forms.Cursor.Position);

                if( this.TopLeft.Contains(wCursorPos) )                 // 左上
                    m.Result = (IntPtr)HTTOPLEFT;
                else if( this.TopRight.Contains(wCursorPos) )           // 右上
                    m.Result = (IntPtr)HTTOPRIGHT;
                else if( this.BottomLeft.Contains(wCursorPos) )         // 左下
                    m.Result = (IntPtr)HTBOTTOMLEFT;
                else if( this.BottomRight.Contains(wCursorPos) )        // 右下
                    m.Result = (IntPtr)HTBOTTOMRIGHT;
                else if( this.TopBorderArea.Contains(wCursorPos) )      // 上
                    m.Result = (IntPtr)HTTOP;
                else if( this.LeftBorderArea.Contains(wCursorPos) )     // 左
                    m.Result = (IntPtr)HTLEFT;
                else if( this.BottomBorderArea.Contains(wCursorPos) )   // 下
                    m.Result = (IntPtr)HTBOTTOM;
                else if( this.RightBorderArea.Contains(wCursorPos) )    // 右
                    m.Result = (IntPtr)HTRIGHT;
            }
        }

        #endregion

        private void frmRldSizableBase_FormClosing(object sender, FormClosingEventArgs e)
        {
            try
            {
                // 徐々に閉じるエフェクト
                for (int i = 10; i > 0; i--)
                {
                    this.Opacity = (float)i / 10;
                    Application.DoEvents();
                    System.Threading.Thread.Sleep(2);
                }

            }
            catch (Exception ex)
            {
                // 例外発生に伴うアプリ停止を目的としたtry～catchであるためログ出力は行わない
                System.Diagnostics.Debug.Print(ex.ToString());
            }

        }
    }
}
