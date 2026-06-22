using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewColumn 表示プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCAppearanceAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCAppearanceAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 列の既定のセル スタイルです。
        /// このプロパティはサポートされていません。
        /// </summary>
        [Obsolete("RldGridRCAppearanceDefaultCellStyleAttribute カスタム属性を使用して設定します。", true)]
        public DataGridViewCellStyle DefaultCellStyle
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                throw new System.NotSupportedException();
            }
        }

        /// <summary>
        /// 列のヘッダー セルのキャプション テキストです。
        /// </summary>
        public String HeaderText { get; set; } = String.Empty;

        /// <summary>
        /// ツールヒントに使用されるテキストです。
        /// </summary>
        public String ToolTipText { get; set; } = String.Empty;

        /// <summary>
        /// 列を表示するかどうかを示します。
        /// </summary>
        public Boolean Visible { get; set; } = true;

        /// <summary>
        /// 現在表示されている列を基準とした列の表示順序を示します。
        /// </summary>
        public Int32 DisplayIndex { get; set; } = -1;

        #endregion
    }
}
