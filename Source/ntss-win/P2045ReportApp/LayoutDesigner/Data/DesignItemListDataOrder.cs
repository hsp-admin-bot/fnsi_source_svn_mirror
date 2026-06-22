using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 帳票表示項目の並び順項目リスト用アイテムデータクラス
    /// </summary>
    public class DesignItemListDataOrder
    {
        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// カテゴリ
            /// </summary>
            DataCategory,
            /// <summary>
            /// クラス
            /// </summary>
            DataClass
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// カテゴリの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DataCategory)]
        public String DataCategory { get; set; } = String.Empty;

        /// <summary>
        /// クラスの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DataClass)]
        public String DataClass { get; set; } = String.Empty;
        #endregion
    }
}
