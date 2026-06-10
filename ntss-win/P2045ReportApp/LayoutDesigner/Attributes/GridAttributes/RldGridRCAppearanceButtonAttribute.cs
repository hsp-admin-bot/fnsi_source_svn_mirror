using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewButtonColumn 表示プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCAppearanceButtonAttribute : RldGridRCAppearanceAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewButtonColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCAppearanceButtonAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 列のボタンセルのフラットスタイルの外観です。
        /// </summary>
        public System.Windows.Forms.FlatStyle FlatStyle { get; set; } = System.Windows.Forms.FlatStyle.Standard;

        /// <summary>
        /// ボタンセルに表示される既定のテキストです。
        /// </summary>
        public String Text { get; set; } = String.Empty;

        /// <summary>
        /// DataGridViewButtonColumn.Text プロパティの値が、この列のセルのボタンテキストとして表示されるかどうかを示します。
        /// </summary>
        public Boolean UseColumnTextForButtonValue { get; set; } = false;

        #endregion
    }
}
