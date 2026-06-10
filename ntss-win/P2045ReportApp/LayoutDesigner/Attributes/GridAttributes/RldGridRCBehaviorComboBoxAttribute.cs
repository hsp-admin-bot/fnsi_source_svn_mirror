using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewComboBoxColumn 表示プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCBehaviorComboBoxAttribute : RldGridRCBehaviorAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewComboBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCBehaviorComboBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 列のセルで、セルに入力されている文字を可能な選択肢からの１つと一致させるかどうかを示します。
        /// </summary>
        public Boolean AutoComplete { get; set; } = true;

        /// <summary>
        /// コンボボックスのドロップダウンリストの幅です。
        /// </summary>
        public Int32 DropDownWidth { get; set; } = 1;

        /// <summary>
        /// 列のセルのドロップダウンリストの最大項目数です。
        /// </summary>
        public Int32 MaxDropDownItems { get; set; } = 8;

        #endregion
    }
}
