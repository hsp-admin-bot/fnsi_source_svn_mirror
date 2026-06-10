using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// ドロップダウンボタン
    /// </summary>
    public class RldDropDownButton : LayoutDesignerUtilityLib.Controls.NoFocusButton
    {
        #region メンバ定数定義

        /// <summary>
        /// プロパティウィンドウ 表示カテゴリ名
        /// </summary>
        private const string CATEGORY_TEXT = "Custom Property";

        #endregion

        #region メンバ変数定義

        /// <summary>
        /// ドロップダウン中かどうか
        /// </summary>
        private Boolean m_DroppedDown = false;

        /// <summary>
        /// マウスカーソルが範囲内に含まれているかどうか
        /// </summary>
        private Boolean m_IsContainCursor = false;

        /// <summary>
        /// タイマー
        /// </summary>
        private System.Windows.Forms.Timer m_Timer = null;

        #endregion

        #region メンバイベント定義

        /// <summary>
        /// ドロップダウンパネルが閉じられた後に発生します。
        /// </summary>
        public event EventHandler DropDownClosed;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// ドロップダウンボタンの新しいインスタンスを初期化します。
        /// </summary>
        public RldDropDownButton() : base()
        {
            // 100ms タイマー生成
            this.m_Timer = new Timer() { Interval = 100 };
            this.m_Timer.Tick += new EventHandler(this.OnTimerTick);
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// ドロップダウン対象を指定します。
        /// </summary>
        [System.ComponentModel.Category(CATEGORY_TEXT)]
        [System.ComponentModel.Description("ボタンのクリック時にドロップダウン表示するコントロールを指定します。")]
        [System.ComponentModel.DefaultValue(null)]
        [System.ComponentModel.DesignerSerializationVisibility(System.ComponentModel.DesignerSerializationVisibility.Visible)]
        public Panel DropDownClient { get; set; } = null;
        
        /// <summary>
        /// ドロップダウンパネルが開いているかどうかの取得及び設定を行います。
        /// </summary>
        [System.ComponentModel.EditorBrowsable(System.ComponentModel.EditorBrowsableState.Never)]
        public Boolean DroppedDown
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                return this.m_DroppedDown;
            }
            [System.Diagnostics.DebuggerStepThrough()]
            set {
                // 変更されていない場合は抜ける
                if( this.m_DroppedDown == value ) return;
                this.DropDownOrCloseUp();
            }
        }

        /// <summary>
        /// ボタンの状態の取得及び設定を行います。
        /// </summary>
        private System.Windows.Forms.VisualStyles.ComboBoxState ComboBoxState { get; set; } = System.Windows.Forms.VisualStyles.ComboBoxState.Normal;

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Control.Click イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnClick(EventArgs e)
        {
            base.OnClick(e);

            this.DropDownOrCloseUp();
        }

        /// <summary>
        /// Control.EnabledChanged イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnEnabledChanged(EventArgs e)
        {
            base.OnEnabledChanged(e);

            switch( this.ComboBoxState ) {
                case System.Windows.Forms.VisualStyles.ComboBoxState.Disabled:
                    this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Normal;
                    break;

                case System.Windows.Forms.VisualStyles.ComboBoxState.Normal:
                    this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Disabled;
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

            switch( this.ComboBoxState ) {
                case System.Windows.Forms.VisualStyles.ComboBoxState.Hot:
                case System.Windows.Forms.VisualStyles.ComboBoxState.Normal:
                    this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Hot;
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

            switch( this.ComboBoxState ) {
                case System.Windows.Forms.VisualStyles.ComboBoxState.Hot:
                case System.Windows.Forms.VisualStyles.ComboBoxState.Normal:
                case System.Windows.Forms.VisualStyles.ComboBoxState.Pressed:
                    this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Normal;
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

            switch( this.ComboBoxState ) {
                case System.Windows.Forms.VisualStyles.ComboBoxState.Hot:
                case System.Windows.Forms.VisualStyles.ComboBoxState.Normal:
                    this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Pressed;
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

            switch( this.ComboBoxState ) {
                case System.Windows.Forms.VisualStyles.ComboBoxState.Normal:
                case System.Windows.Forms.VisualStyles.ComboBoxState.Pressed:
                    if( base.RectangleToScreen(this.ClientRectangle).Contains(Cursor.Position) )
                        this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Hot;
                    else
                        this.ComboBoxState = System.Windows.Forms.VisualStyles.ComboBoxState.Normal;
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
            ComboBoxRenderer.DrawDropDownButton(pevent.Graphics, wDropDownButtonSize, this.ComboBoxState);

            // 外枠を描画
            ControlPaint.DrawBorder(pevent.Graphics, wTargetRect, System.Drawing.SystemColors.ButtonFace, ButtonBorderStyle.Solid);

            base.ResumeLayout();
        }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// ドロップダウンパネルを非表示に設定し、コントロールを初期化します。
        /// </summary>
        public void Init()
        {
            if( this.DropDownClient != null ) {
                this.DropDownClient.Visible = false;
                this.DropDownClient.VisibleChanged += new EventHandler(this.DropDownPanel_VisibleChanged);

                base.FindForm().KeyDown += new KeyEventHandler(this.OwnerForm_KeyDown);
            }
        }

        /// <summary>
        /// ドロップダウン処理及びクローズアップ処理を行います。
        /// </summary>
        protected virtual void DropDownOrCloseUp()
        {
            // パネルがない場合は抜ける
            if( this.DropDownClient == null ) return;

            // 開いている場合は閉じる
            if( this.DroppedDown ) {
                this.DropDownClient.Visible = false;
                // イベント通知
                this.DropDownClosed?.Invoke(this, System.EventArgs.Empty);
            }
            // 閉じている場合は開く
            else {
                this.DropDownClient.Left = this.Left;
                this.DropDownClient.Top = this.Top + this.Height;
                this.DropDownClient.Width = this.Width;

                this.DropDownClient.Visible = true;
            }

            this.m_DroppedDown = !this.m_DroppedDown;
        }

        /// <summary>
        /// テキストの表示方法を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Drawing.StringFormat GetStringFormat()
        {
            var wRet = new System.Drawing.StringFormat();
            wRet.FormatFlags |= System.Drawing.StringFormatFlags.NoWrap;
            wRet.Trimming = System.Drawing.StringTrimming.EllipsisCharacter;

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

        /// <summary>
        /// 監視対象領域を取得します。
        /// </summary>
        /// <returns></returns>
        private System.Drawing.Rectangle GetTargetArea()
        {
            return new System.Drawing.Rectangle(
                base.Location, new System.Drawing.Size(base.Width, this.DropDownClient.Bottom - base.Top));
        }

        #endregion

        #region カスタムイベントハンドラ定義

        /// <summary>
        /// 親フォームの KeyDown イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OwnerForm_KeyDown(object sender, KeyEventArgs e)
        {
            if( !this.DroppedDown ) return;
            if( e.KeyCode != Keys.Escape ) return;

            this.DroppedDown = false;
            e.Handled = true;
        }

        /// <summary>
        /// ドロップダウンパネルの VisibleChanged イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void DropDownPanel_VisibleChanged(object sender, EventArgs e)
        {
            if( this.DropDownClient.Visible )
                this.m_Timer.Start();
            else
                this.m_Timer.Stop();
        }

        /// <summary>
        /// タイマーの Tick イベント
        /// </summary>
        /// <param name="sender"></param>
        /// <param name="e"></param>
        private void OnTimerTick(object sender, EventArgs e)
        {
            if( this.GetTargetArea().Contains(base.PointToClient(Cursor.Position)) ) {
                if( !this.m_IsContainCursor ) {
                    this.m_IsContainCursor = true;
                }
            }
            else {
                if( this.m_IsContainCursor && !this.DropDownClient.ContainsFocus ) {
                    this.m_IsContainCursor = false;
                    this.DroppedDown = false;
                }
            }
        }

        #endregion
    }
}
