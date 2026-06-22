using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// DataGridViewColumn 配置プロパティ設定用カスタム属性
    /// </summary>
    [System.AttributeUsage(AttributeTargets.Property, AllowMultiple = true)]
    public class RldGridRCLayoutAttribute : System.Attribute
    {
        #region 生成と破棄

        /// <summary>
        /// DataGridViewColumn 配置プロパティ設定用カスタム属性の新しいインスタンスを初期化します。
        /// </summary>
        public RldGridRCLayoutAttribute() : base() { }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// この列の自動サイズ調整モードを決定します。
        /// </summary>
        public DataGridViewAutoSizeColumnMode AutoSizeMode { get; set; } = DataGridViewAutoSizeColumnMode.NotSet;

        /// <summary>
        /// 列の分割線の幅(ピクセル)です。
        /// </summary>
        public Int32 DividerWidth { get; set; } = 0;

        /// <summary>
        /// この列のサイズを Fill 自動サイズ調整モードで変更するときに使用する太さです。
        /// </summary>
        public Single FillWeight { get; set; } = 100f;

        /// <summary>
        /// ユーザーが DataGridView コントロールを水平にスクロールするときに列が移動するかどうかを示します。
        /// </summary>
        public Boolean Frozen { get; set; } = false;

        /// <summary>
        /// 列の幅の最小値(ピクセル)です。
        /// </summary>
        public Int32 MinimumWidth { get; set; } = 5;

        /// <summary>
        /// 列の現在の幅です。
        /// </summary>
        public Int32 Width { get; set; } = 100;

        #endregion
    }
}
