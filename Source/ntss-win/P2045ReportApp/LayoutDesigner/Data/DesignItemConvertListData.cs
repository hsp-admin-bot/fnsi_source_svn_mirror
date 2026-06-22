using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// コンバート用データ項目リスト用アイテムデータクラス
    /// </summary>
    public class DesignItemConvertListData
    {
        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// 項目名
            /// </summary>
            DataName,
            /// <summary>
            /// 新項目名
            /// </summary>
            NewDataName
        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// 項目名の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DataName)]
        public String DataName { get; set; } = String.Empty;

        /// <summary>
        /// 項目名の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.NewDataName)]
        public String NewDataName { get; set; } = String.Empty;
        #endregion
    }
}
