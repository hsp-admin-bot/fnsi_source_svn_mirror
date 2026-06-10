using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewColumn デザインプロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCDesignAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewColumn 表示プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        /// <param name="aColumnType">列の型を指定します。</param>
        public RldGridRCDesignAttribute(System.Type aColumnType) : base()
        {
            if( aColumnType == null )
                throw new System.ArgumentNullException("aColumnType");

            if( !aColumnType.IsSubclassOf(typeof(System.Windows.Forms.DataGridViewColumn)) )
                throw new System.ArgumentException("引数は DataGridViewColumn 派生型である必要があります。", "aColumnType");

            this.ColumnType = aColumnType;
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 列の型です。
        /// </summary>
        public System.Type ColumnType { get; } = null;

        /// <summary>
        /// データバインドを行うかどうかの取得及び設定を行います。
        /// 既定値は True(行う) です。
        /// </summary>
        public Boolean IsDataBind { get; set; } = true;

        #endregion
    }
}
