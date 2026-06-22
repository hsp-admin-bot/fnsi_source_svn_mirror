using System;
using System.Windows.Forms;

namespace LayoutDesignerUtilityLib.Controls
{
    /// <summary>
    /// 入力フォーカスを取得しない Windows のチェック ボックス コントロールを表します。
    /// </summary>
    public class NoFocusCheckBox : CheckBox
    {
        #region メンバ定数定義

        private const int WM_MOUSEACTIVATE = 0x0021;
        private const int MA_NOACTIVATE = 0x0003;

        #endregion

        #region 生成と破棄

        /// <summary>
        /// NoFocusCheckBox の新しいインスタンスを生成します。
        /// </summary>
        public NoFocusCheckBox() : base()
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
        /// Windows メッセージを処理します。
        /// </summary>
        /// <param name="m"></param>
        protected override void WndProc(ref Message m)
        {
            if (m.Msg == WM_MOUSEACTIVATE)
            {
                m.Result = (IntPtr)MA_NOACTIVATE;
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
            base.SetStyle(ControlStyles.Selectable, aIsEnabled);
        }

        #endregion
    }
}
