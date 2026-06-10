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
    public class RldGridRCAppearanceComboBoxAttribute : RldGridRCAppearanceAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewComboBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCAppearanceComboBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 編集中以外の時のコンボボックスの表示方法を決定します。
        /// </summary>
        public System.Windows.Forms.DataGridViewComboBoxDisplayStyle DisplayStyle { get; set; } = System.Windows.Forms.DataGridViewComboBoxDisplayStyle.DropDownButton;

        /// <summary>
        /// 表示スタイルを現在のセルのみに適用するかどうかを示します。
        /// </summary>
        public Boolean DisplayStyleForCurrentCellOnly { get; set; } = false;

        /// <summary>
        /// 列のセルのフラットスタイルの外観です。
        /// </summary>
        public System.Windows.Forms.FlatStyle FlatStyle { get; set; } = System.Windows.Forms.FlatStyle.Standard;

        #endregion
    }
}
