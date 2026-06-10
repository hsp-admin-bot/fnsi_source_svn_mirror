using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Drawing;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// フォームのタイトル用ラベルコントロール
    /// </summary>
    public class WindowTitleLabel : System.Windows.Forms.Label
    {
        #region 生成と破棄

        /// <summary>
        /// フォームのタイトル用ラベルコントロールの新しいインスタンスを初期化します。
        /// </summary>
        public WindowTitleLabel() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 最後に MouseDown イベントが発生した位置の取得及び設定を行います。
        /// </summary>
        private System.Drawing.Point LastMouseDownLocation { get; set; } = System.Drawing.Point.Empty;

        #endregion

        #region メンバ関数定義(override...)

        /// <summary>
        /// Control.MouseDoubleClick イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseDoubleClick(MouseEventArgs e)
        {
            base.OnMouseDoubleClick(e);

            var wForm = base.FindForm();
            if( wForm == null ) return;
            if( !wForm.MaximizeBox ) return;

            wForm.WindowState = wForm.WindowState == FormWindowState.Normal ? FormWindowState.Maximized : FormWindowState.Normal;
        }

        /// <summary>
        /// Control.MouseDown イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseDown(MouseEventArgs e)
        {
            base.OnMouseDown(e);

            if( e.Button == MouseButtons.Left )
                this.LastMouseDownLocation = new Point((Size)e.Location);
        }

        /// <summary>
        /// Control.MouseMove イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseMove(MouseEventArgs e)
        {
            base.OnMouseMove(e);

            // MouseDown が発生していない場合は抜ける
            if( this.LastMouseDownLocation == Point.Empty ) return;

            // フォームを移動する
            var wForm = base.FindForm();
            wForm.Location = Point.Add(wForm.Location, (Size)Point.Subtract(e.Location, (Size)this.LastMouseDownLocation));
        }

        /// <summary>
        /// Control.MouseUp イベントを発生させます。
        /// </summary>
        /// <param name="e"></param>
        protected override void OnMouseUp(MouseEventArgs e)
        {
            base.OnMouseUp(e);
            this.LastMouseDownLocation = Point.Empty;
        }

        #endregion
    }
}
