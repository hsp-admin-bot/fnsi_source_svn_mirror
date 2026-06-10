using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewCheckBoxColumn 表示プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCAppearanceCheckBoxAttribute : RldGridRCAppearanceAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewCheckBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCAppearanceCheckBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// チェックボックスセルのフラットスタイルの外観です。
        /// </summary>
        public System.Windows.Forms.FlatStyle FlatStyle { get; set; } = System.Windows.Forms.FlatStyle.Standard;

        #endregion

    }
}
