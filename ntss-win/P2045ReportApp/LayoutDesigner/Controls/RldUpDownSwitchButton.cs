using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// 上下切り替えボタン
    /// </summary>
    public class RldUpDownSwitchButton : LayoutDesignerUtilityLib.Controls.NoFocusButton
    {
        #region メンバ列挙体定義

        /// <summary>
        /// 表示する向き
        /// </summary>
        public enum EnumUpDownState
        {
            /// <summary>
            /// 下向き
            /// </summary>
            Down = 0,
            /// <summary>
            /// 上向き
            /// </summary>
            Up
        }

        #endregion

        #region メンバ変数定義

        private EnumUpDownState m_UpDownState = EnumUpDownState.Down;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// 上下切り替えボタンの新しいインスタンスを初期化します。
        /// </summary>
        public RldUpDownSwitchButton() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 現在の状態の取得及び設定を行います。
        /// </summary>
        public EnumUpDownState UpDownState
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_UpDownState;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                this.m_UpDownState = value;
                switch( this.m_UpDownState ) {
                    case EnumUpDownState.Down:
                        switch( this.ButtonState ) {
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpDisabled:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownDisabled;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed;
                                break;
                            default:
                                break;
                        }
                        break;

                    case EnumUpDownState.Up:
                        switch( this.ButtonState ) {
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownDisabled:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpDisabled;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal;
                                break;
                            case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed:
                                this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed;
                                break;
                            default:
                                break;
                        }
                        break;
                }
            }
        }

        /// <summary>
        /// ボタンの状態の取得及び設定を行います。
        /// </summary>
        private System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState ButtonState { get; set; } = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal;

        #endregion

        #region  メンバ関数定義(override...)

        /// <summary>
        /// Control.EnabledChanged イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnEnabledChanged(EventArgs e)
        {
            base.OnEnabledChanged(e);

            switch( this.ButtonState ) {
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownDisabled:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal;
                    break;

                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpDisabled:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal;
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
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot;
                    break;

                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot;
                    break;
            }
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
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal;
                    break;

                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal;
                    break;

            }
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
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed;
                    break;

                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
                    this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed;
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
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed:
                    if( base.RectangleToScreen(this.ClientRectangle).Contains(Cursor.Position) )
                        this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot;
                    else 
                        this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal;
                    break;

                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
                case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed:
                    if( base.RectangleToScreen(this.ClientRectangle).Contains(Cursor.Position) )
                        this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot;
                    else 
                        this.ButtonState = System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal;
                    break;
            }
            base.Invalidate();
        }

        /// <summary>
        /// Control.OnPaint イベントを発生させます。
        /// </summary>
        /// <param name="pevent"></param>
        protected override void OnPaint(PaintEventArgs pevent)
        {
            //base.OnPaint(pevent);

            base.SuspendLayout();

            var wTargetRect = base.ClientRectangle;

            // 矢印ボタンの領域を取得
            var wDropDownButtonSize = new System.Drawing.Rectangle(
                wTargetRect.Width - wTargetRect.Height + 1,
                wTargetRect.Top,
                wTargetRect.Height,
                wTargetRect.Height);
            wDropDownButtonSize.Inflate(-1, -1);

            var wTextBoxSize = new System.Drawing.Rectangle(
                wTargetRect.Left,
                wTargetRect.Top,
                wTargetRect.Width - wDropDownButtonSize.Width,
                wTargetRect.Height);
            wTextBoxSize.Inflate(-1, -1);

            // 背景を描画
            using( var wPen = new System.Drawing.SolidBrush(base.BackColor) )
                pevent.Graphics.FillRectangle(wPen, wTargetRect);

            // 文字列を描画
            using( var wPen = new System.Drawing.SolidBrush(base.ForeColor) )
                pevent.Graphics.DrawString(base.Text, base.Font, wPen, wTextBoxSize, this.GetStringFormat());
                
            // 矢印を描画
            ScrollBarRenderer.DrawArrowButton(pevent.Graphics, wDropDownButtonSize, this.ButtonState);

            // 外枠を描画
            ControlPaint.DrawBorder(pevent.Graphics, wTargetRect, System.Drawing.SystemColors.ButtonFace, ButtonBorderStyle.Solid);

            base.ResumeLayout();
        }

        #endregion

        #region  メンバ関数定義

        ///// <summary>
        ///// ボタンの状態を取得します。
        ///// </summary>
        ///// <returns></returns>
        //private System.Windows.Forms.VisualStyles.PushButtonState GetPushButtonState()
        //{
        //    System.Windows.Forms.VisualStyles.PushButtonState wRet = System.Windows.Forms.VisualStyles.PushButtonState.Default;

        //    switch( this.ButtonState ) {
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownDisabled:
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpDisabled:
        //            wRet = System.Windows.Forms.VisualStyles.PushButtonState.Disabled;
        //            break;

        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
        //            wRet = System.Windows.Forms.VisualStyles.PushButtonState.Hot;
        //            break;

        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
        //            wRet = System.Windows.Forms.VisualStyles.PushButtonState.Normal;
        //            break;

        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed:
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed:
        //            wRet = System.Windows.Forms.VisualStyles.PushButtonState.Pressed;
        //            break;
        //    }

        //    return wRet;
        //}

        //private System.Windows.Forms.VisualStyles.VisualStyleElement GetVisualStyleElement()
        //{
        //    switch( this.ButtonState ) {
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownDisabled:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.DownDisabled;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownHot:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.DownHot;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownNormal:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.DownNormal;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.DownPressed:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.DownPressed;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpDisabled:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.UpDisabled;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpHot:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.UpHot;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpNormal:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.UpNormal;
        //        case System.Windows.Forms.VisualStyles.ScrollBarArrowButtonState.UpPressed:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.UpPressed;
        //        default:
        //            return System.Windows.Forms.VisualStyles.VisualStyleElement.ScrollBar.ArrowButton.DownNormal;
        //    }
        //}

        /// <summary>
        /// テキストの表示方法を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Drawing.StringFormat GetStringFormat()
        {
            var wRet = new System.Drawing.StringFormat();

            switch( base.TextAlign ) {
                case System.Drawing.ContentAlignment.BottomCenter:
                    wRet.Alignment = System.Drawing.StringAlignment.Center;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Far;
                    break;

                case System.Drawing.ContentAlignment.BottomLeft:
                    wRet.Alignment = System.Drawing.StringAlignment.Near;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Far;
                    break;

                case System.Drawing.ContentAlignment.BottomRight:
                    wRet.Alignment = System.Drawing.StringAlignment.Far;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Far;
                    break;

                case System.Drawing.ContentAlignment.MiddleCenter:
                    wRet.Alignment = System.Drawing.StringAlignment.Center;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Center;
                    break;

                case System.Drawing.ContentAlignment.MiddleLeft:
                    wRet.Alignment = System.Drawing.StringAlignment.Near;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Center;
                    break;

                case System.Drawing.ContentAlignment.MiddleRight:
                    wRet.Alignment = System.Drawing.StringAlignment.Far;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Center;
                    break;

                case System.Drawing.ContentAlignment.TopCenter:
                    wRet.Alignment = System.Drawing.StringAlignment.Center;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Near;
                    break;

                case System.Drawing.ContentAlignment.TopLeft:
                    wRet.Alignment = System.Drawing.StringAlignment.Near;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Near;
                    break;

                case System.Drawing.ContentAlignment.TopRight:
                    wRet.Alignment = System.Drawing.StringAlignment.Far;
                    wRet.LineAlignment = System.Drawing.StringAlignment.Near;
                    break;
            }

            return wRet;
        }

        //private TextFormatFlags GetTextFormatFlags()
        //{
        //    TextFormatFlags wRet = TextFormatFlags.Default;

        //    switch( base.TextAlign ) {
        //        case System.Drawing.ContentAlignment.BottomCenter:
        //            wRet = TextFormatFlags.Bottom | TextFormatFlags.HorizontalCenter;
        //            break;
        //        case System.Drawing.ContentAlignment.BottomLeft:
        //            wRet = TextFormatFlags.Bottom | TextFormatFlags.Left;
        //            break;
        //        case System.Drawing.ContentAlignment.BottomRight:
        //            wRet = TextFormatFlags.Bottom | TextFormatFlags.Right;
        //            break;
        //        case System.Drawing.ContentAlignment.MiddleCenter:
        //            wRet = TextFormatFlags.VerticalCenter | TextFormatFlags.HorizontalCenter;
        //            break;
        //        case System.Drawing.ContentAlignment.MiddleLeft:
        //            wRet = TextFormatFlags.VerticalCenter | TextFormatFlags.Left;
        //            break;
        //        case System.Drawing.ContentAlignment.MiddleRight:
        //            wRet = TextFormatFlags.VerticalCenter | TextFormatFlags.Right;
        //            break;
        //        case System.Drawing.ContentAlignment.TopCenter:
        //            wRet = TextFormatFlags.Top | TextFormatFlags.HorizontalCenter;
        //            break;
        //        case System.Drawing.ContentAlignment.TopLeft:
        //            wRet = TextFormatFlags.Top | TextFormatFlags.Left;
        //            break;
        //        case System.Drawing.ContentAlignment.TopRight:
        //            wRet = TextFormatFlags.Top | TextFormatFlags.Right;
        //            break;
        //    }

        //    return wRet;
        //}

        #endregion
    }
}
