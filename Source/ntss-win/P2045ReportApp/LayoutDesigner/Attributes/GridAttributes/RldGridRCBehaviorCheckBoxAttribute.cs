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
    public class RldGridRCBehaviorCheckBoxAttribute : RldGridRCBehaviorAttribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewCheckBoxColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCBehaviorCheckBoxAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// ホストされているチェックボックスのセルが、２つではなく３つのチェックボックスの状態を許可するかどうかを示します。
        /// </summary>
        public Boolean ThreeState { get; set; } = false;
        
        #endregion
    }
}
