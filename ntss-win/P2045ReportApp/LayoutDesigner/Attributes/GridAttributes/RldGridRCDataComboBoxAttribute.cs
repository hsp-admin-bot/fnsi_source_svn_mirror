using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewComboBoxColumn データプロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCDataComboBoxAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewComboBoxColumn データプロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCDataComboBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        public Object DataSource { get; set; } = null;

        public String DisplayMember { get; set; } = String.Empty;

        public String ValueMemmber { get; set; } = String.Empty;

        public Object Items { get; set; } = null;

        #endregion
    }
}
