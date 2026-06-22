using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewColumn 動作プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCBehaviorAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewColumn 動作プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCBehaviorAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 列のショートカット メニューです。
        /// </summary>
        public ContextMenuStrip ContextMenuStrip { get; set; } = null;

        /// <summary>
        /// ユーザーが列のセルを編集できるかどうかを示します。
        /// </summary>
        public Boolean ReadOnly { get; set; } = false;

        /// <summary>
        /// 列のサイズが変更可能であるかどうかを示します。
        /// </summary>
        public DataGridViewTriState Resizable { get; set; } = DataGridViewTriState.True;

        /// <summary>
        /// 列に対する並べ替えモードです。
        /// </summary>
        public DataGridViewColumnSortMode SortMode { get; set; } = DataGridViewColumnSortMode.Automatic;
        
        #endregion
    }
}
