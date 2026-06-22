using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewTextBoxColumn 動作プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCBehaviorTextBoxAttribute : RldGridRCBehaviorAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewTextBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCBehaviorTextBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// テキストボックスに入力できる最大文字数を指定します。
        /// </summary>
        public Int32 MaxInputLength { get; set; } = 32767;

        #endregion
    }
}
