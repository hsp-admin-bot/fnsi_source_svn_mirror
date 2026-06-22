using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewCheckBoxColumn データプロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCDataCheckBoxAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewCheckBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCDataCheckBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// オフになっているチェックボックスとして表示される、セルの値 false と対応する元の値です。
        /// </summary>
        public Object FalseValue { get; set; } = null;

        /// <summary>
        /// 無効になっているチェックボックスとして表示される、セルの値 null または中間に対応する元の値です。
        /// </summary>
        public Object IndeterminateValue { get; set; } = null;

        /// <summary>
        /// オンになっているチェックボックスとして表示される、セルの値 true と対応する元の値です。
        /// </summary>
        public Object TrueValue { get; set; } = null;

        #endregion
        
    }
}
