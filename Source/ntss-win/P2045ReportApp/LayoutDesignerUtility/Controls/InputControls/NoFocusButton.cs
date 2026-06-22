using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// 入力フォーカスを取得しない Windows のボタン コントロールを表します。
    /// </summary>
    public class NoFocusButton : System.Windows.Forms.Button
    {
        #region メンバ定数定義

        /// <summary>
        /// WM_MOUSEACTIVATE
        /// </summary>
        private const int WM_MOUSEACTIVATE = 0x0021;
        /// <summary>
        /// MA_NOACTIVATE
        /// </summary>
        private const int MA_NOACTIVATE = 0x0003;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// NoFocusButton の新しいインスタンスを生成します。
        /// </summary>
        public NoFocusButton() : base()
        {
            this.SetSelectable(false);
            base.TabStop = false;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// ユーザーが Tab キーで、このコントロールにフォーカスを移すことができるかどうかを示す値を取得します。
        /// 値の取得のみ可能です。
        /// </summary>
        [System.ComponentModel.Browsable(false)]
        [System.ComponentModel.ReadOnly(true)]
        public new bool TabStop { get; }

        #endregion

        #region メンバ関数定義

        /// <summary>
        /// コントロールの System.Windows.Forms.Control.Click イベントを生成して、ユーザによるクリックをシミュレートします。
        /// </summary>
        public new void PerformClick()
        {
            // スタイルを変更
            this.SetSelectable(true);

            base.PerformClick();

            // スタイルを戻す
            this.SetSelectable(false);
        }

        /// <summary>
        /// Windows メッセージを処理します。
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            if( m.Msg == WM_MOUSEACTIVATE ) {
                m.Result = new IntPtr(WM_MOUSEACTIVATE);
                return;
            }

            base.WndProc(ref m);
        }

        /// <summary>
        /// コントロールのフォーカス取得可否状態を設定します。
        /// </summary>
        /// <param name="aIsEnabled"></param>
        private void SetSelectable(bool aIsEnabled)
        {
            base.SetStyle(System.Windows.Forms.ControlStyles.Selectable, aIsEnabled);
        }

        #endregion

    }
}
