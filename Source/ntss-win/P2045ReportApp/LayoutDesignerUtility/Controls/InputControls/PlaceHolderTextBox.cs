using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// プレースホルダー付きテキストボックス
    /// </summary>
    public class PlaceHolderTextBox : System.Windows.Forms.TextBox
    {
        #region メンバ定数定義

        /// <summary>
        /// プロパティウィンドウ 表示カテゴリ名
        /// </summary>
        private const string CATEGORY_TEXT = "Custom Property";

        /// <summary>
        /// Window メッセージ (WM_PAINT)
        /// </summary>
        private const int WM_PAINT = 0x000F;

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// プレースホルダーテキストの文字色
        /// </summary>
        private System.Drawing.Color m_PlaceHolderForeColor = System.Drawing.Color.Empty;
        /// <summary>
        /// プレースホルダーテキストのフォント
        /// </summary>
        private System.Drawing.Font m_PlaceHolderFont = null;
        /// <summary>
        /// フォーカス取得状態時にプレースホルダーを表示するかどうか
        /// </summary>
        private Boolean m_IsShowFocused = false;
        /// <summary>
        /// プレースホルダーテキスト
        /// </summary>
        private string m_PlaceHolderText = string.Empty;
        /// <summary>
        /// プレースホルダーテキストの配置方法
        /// </summary>
        private System.Windows.Forms.HorizontalAlignment m_PlaceHolderTextAlign;
        private System.Drawing.StringFormat m_PlaceHolderStringFormat;

        /// <summary>
        /// プレースホルダーテキストの文字色の既定値
        /// </summary>
        private readonly System.Drawing.Color DefaultValuePlaceHolderForeColor = System.Drawing.Color.Gray;
        /// <summary>
        /// プレースホルダーテキストの配置方法の既定値
        /// </summary>
        private readonly System.Windows.Forms.HorizontalAlignment DefaultValuePlaceHolderTextAlign = HorizontalAlignment.Left;

        /// <summary>
        /// Dispose 重複呼び出しチェック用
        /// </summary>
        private bool m_IsDisposed = false;


        #endregion

        #region 生成と破棄

        /// <summary>
        /// プレースホルダー付きテキストボックスの新しいインスタンスを生成を生成します。
        /// </summary>
        public PlaceHolderTextBox()
        {
            // 既定値にリセットしておく
            this.ResetPlaceHolderFont();
            this.ResetPlaceHolderForeColor();
            this.ResetPlaceHolderTextAlign();
        }

        /// <summary>
        /// System.Windows.Forms.TextBox によって使用されているアンマネージ リソースを解放し、オプションでマネージ リソースも解放します。
        /// </summary>
        /// <param name="disposing"></param>
        protected override void Dispose(bool disposing)
        {
            try {
                if( !this.m_IsDisposed ) {
                    if( disposing ) {
                        this.ReleaseStringFormat();
                    }
                }
                this.m_IsDisposed = true;
            }
            finally {
                base.Dispose(disposing);
            }
        }

        #endregion

        #region メンバプロパティ定義

        #region PlaceHolderForeColor

        /// <summary>
        /// プレースホルダーテキストの前景色の取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("プレースホルダーテキストを表示するのに使用される、このコンポーネントの前景色です。")]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public System.Drawing.Color PlaceHolderForeColor
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_PlaceHolderForeColor;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_PlaceHolderForeColor = value;
                base.Invalidate();
            }
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        protected virtual bool ShouldSerializePlaceHolderForeColor()
        {
            return !(this.m_PlaceHolderForeColor == this.DefaultValuePlaceHolderForeColor);
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public virtual void ResetPlaceHolderForeColor()
        {
            this.PlaceHolderForeColor = this.DefaultValuePlaceHolderForeColor;
        }

        #endregion

        #region PlaceHolderFont

        /// <summary>
        /// プレースホルダーテキストのフォントの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("コントロールでプレースホルダーテキストを表示するフォントです。")]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public System.Drawing.Font PlaceHolderFont
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return (this.m_PlaceHolderFont == null ? this.Font : this.m_PlaceHolderFont);
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_PlaceHolderFont = value;
                base.Invalidate();
            }
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        protected virtual bool ShouldSerializePlaceHolderFont()
        {
            return (this.m_PlaceHolderFont != null);
        }
        
        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public virtual void ResetPlaceHolderFont()
        {
            this.PlaceHolderFont = null;
        }

        #endregion
        
        /// <summary>
        /// プレースホルダーテキストの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("コントロールのプレースホルダーに関連付けられたテキストです。")]
        [System.ComponentModel.DefaultValue("")]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public string PlaceHolderText
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_PlaceHolderText;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_PlaceHolderText = value;
                base.Invalidate();
            }
        }

        #region PlaceHolderTextAlign

        /// <summary>
        /// プレースホルダーテキストの配置方法の取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("エディットコントロールに対してプレースホルダーテキストをどのように配置するかを示します。")]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public System.Windows.Forms.HorizontalAlignment PlaceHolderTextAlign
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_PlaceHolderTextAlign;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_PlaceHolderTextAlign = value;

                // レイアウト情報を生成
                this.MakeStringFormat(value);
                base.Invalidate();
            }
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public virtual bool ShouldSerializePlaceHolderTextAlign()
        {
            return !(this.m_PlaceHolderTextAlign == this.DefaultValuePlaceHolderTextAlign);
        }

        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public virtual void ResetPlaceHolderTextAlign()
        {
            this.PlaceHolderTextAlign = this.DefaultValuePlaceHolderTextAlign;
        }

        #endregion

        /// <summary>
        /// 入力フォーカス取得状態時にプレースホルダーテキストを表示するかどうかの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("入力フォーカス取得状態時にプレースホルダーを表示するかどうかを指定します。")]
        [System.ComponentModel.DefaultValue(false)]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public Boolean ShowFocused
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_IsShowFocused;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_IsShowFocused = value;
                base.Invalidate();
            }
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// テキストレイアウトオブジェクトを生成します。
        /// 生成済みの場合は一旦破棄します。
        /// </summary>
        /// <param name="aAlignment"></param>
        private void MakeStringFormat(System.Windows.Forms.HorizontalAlignment aAlignment)
        {
            // 一旦破棄する
            this.ReleaseStringFormat();

            this.m_PlaceHolderStringFormat = new System.Drawing.StringFormat { LineAlignment = System.Drawing.StringAlignment.Center };

            switch( aAlignment ) {
                case HorizontalAlignment.Center:
                    this.m_PlaceHolderStringFormat.Alignment = System.Drawing.StringAlignment.Center;
                    break;

                case HorizontalAlignment.Left:
                    this.m_PlaceHolderStringFormat.Alignment =
                        base.RightToLeft == RightToLeft.No ? System.Drawing.StringAlignment.Near : System.Drawing.StringAlignment.Far;
                    break;

                case HorizontalAlignment.Right:
                    this.m_PlaceHolderStringFormat.Alignment =
                        base.RightToLeft == RightToLeft.No ? System.Drawing.StringAlignment.Far : System.Drawing.StringAlignment.Near;
                    break;

                default:
                    break;
            }
        }

        /// <summary>
        /// テキストレイアウトオブジェクトを破棄します。
        /// </summary>
        private void ReleaseStringFormat()
        {
            if( this.m_PlaceHolderStringFormat != null ) {
                this.m_PlaceHolderStringFormat.Dispose();
                this.m_PlaceHolderStringFormat = null;
            }
        }

        #endregion

        #region Override...

        /// <summary>
        /// Control.TextChanged イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnTextChanged(EventArgs e)
        {
            base.OnTextChanged(e);

            if( base.TextLength <= 0 ) base.Invalidate();
        }

        /// <summary>
        /// Windows メッセージを処理します。
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            base.WndProc(ref m);

            if( m.Msg == WM_PAINT ) {
                if( this.Enabled && 
                    !this.ReadOnly && 
                    (!this.Focused || (this.Focused && this.ShowFocused)) &&
                    !string.IsNullOrEmpty(this.PlaceHolderText) && 
                    this.TextLength == 0 ) {

                    using( var wGraphics = base.CreateGraphics() )
                    using( var wBackBrush = new System.Drawing.SolidBrush(base.BackColor) )
                    using( var wTextBrush = new System.Drawing.SolidBrush(this.PlaceHolderForeColor) ) {

                        // 一旦消す
                        wGraphics.FillRectangle(wBackBrush, base.ClientRectangle);

                        // プレースホルダーテキストを描画
                        wGraphics.DrawString(
                            this.PlaceHolderText, 
                            this.PlaceHolderFont, 
                            wTextBrush, 
                            base.ClientRectangle, 
                            this.m_PlaceHolderStringFormat);
                    }
                }
            }
        }

        #endregion
    }
}
