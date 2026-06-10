using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewComboBoxColumn データプロパティ内 Items プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCDataComboBoxItemsAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewComboBoxColumn データプロパティ内 Items プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCDataComboBoxItemsAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 
        /// </summary>
        public String PropertyName { get; set; } = String.Empty;

        #endregion

    }
}
