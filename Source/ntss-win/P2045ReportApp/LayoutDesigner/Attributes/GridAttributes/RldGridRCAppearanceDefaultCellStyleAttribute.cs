using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewColumn 表示プロパティ内 DefaultCellStyle プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCAppearanceDefaultCellStyleAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewColumn 表示プロパティ内 DefaultCellStyle プロパティ設定用カスタム属性クラスの新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCAppearanceDefaultCellStyleAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// セルの null 値を示すために使用するオブジェクト。 既定値は、System.String.Empty です。
        /// </summary>
        public Object DataNullValue { get; set; } = String.Empty;

        /// <summary>
        /// セルの値の書式を示す文字列。 既定値は、System.String.Empty です。
        /// </summary>
        public String BehaviorFormat { get; set; } = String.Empty;

        /// <summary>
        /// System.Windows.Forms.DataGridViewContentAlignment 値のいずれか。 
        /// 既定値は、System.Windows.Forms.DataGridViewContentAlignment.NotSet です。
        /// </summary>
        public System.Windows.Forms.DataGridViewContentAlignment LayoutAlignment { get; set; } = System.Windows.Forms.DataGridViewContentAlignment.NotSet;

        /// <summary>
        /// System.Windows.Forms.Padding の間の空白を表す、 System.Windows.Forms.DataGridViewCell とそのコンテンツです。
        /// </summary>
        public System.Windows.Forms.Padding LayoutPadding { get; set; } = new System.Windows.Forms.Padding(0);

        /// <summary>
        /// System.Windows.Forms.DataGridViewTriState 値のいずれか。 
        /// 既定値は、System.Windows.Forms.DataGridViewTriState.NotSet です。
        /// </summary>
        public System.Windows.Forms.DataGridViewTriState LayoutWrapMode { get; set; } = System.Windows.Forms.DataGridViewTriState.NotSet;

        /// <summary>
        /// System.Drawing.Color セルの背景色を表します。 
        /// 既定値は、System.Drawing.Color.Empty です。
        /// </summary>
        public System.Drawing.Color AppearanceBackColor { get; set; } = System.Drawing.Color.Empty;

        /// <summary>
        /// System.Drawing.Font セルのテキストに適用します。 
        /// 既定値は、null です。
        /// </summary>
        public System.Drawing.Font AppearanceFont { get; set; } = null;

        /// <summary>
        /// System.Drawing.Color セルの前景色を表します。 
        /// 既定値は、System.Drawing.Color.Empty です。
        /// </summary>
        public System.Drawing.Color AppearanceForeColor { get; set; } = System.Drawing.Color.Empty;

        /// <summary>
        /// System.Drawing.Color 選択したセルの背景色を表します。 
        /// 既定値は、System.Drawing.Color.Empty です。
        /// </summary>
        public System.Drawing.Color AppearanceSelectionBackColor { get; set; } = System.Drawing.Color.Empty;

        /// <summary>
        /// System.Drawing.Color 選択したセルの前景色を表します。 
        /// 既定値は、System.Drawing.Color.Empty です。
        /// </summary>
        public System.Drawing.Color AppearanceSelectionForeColor { get; set; } = System.Drawing.Color.Empty;

        #endregion
    }
}
