using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// グループデータクラス
    /// </summary>
    public class DesignGroupFromOldReportData
    {
        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// グループパス
            /// </summary>
            GroupPath = 0,
            /// <summary>
            /// カテゴリ
            /// </summary>
            DataCategory,
            /// <summary>
            /// クラス
            /// </summary>
            DataClass,
            /// <summary>
            /// グループ名
            /// </summary>
            GroupName,
            /// <summary>
            /// 改ページ有無
            /// </summary>
            IsNewPage,
            /// <summary>
            /// フィルタデータ
            /// </summary>
            FilterData,
            /// <summary>
            /// フィルタ状態
            /// </summary>
            FilterState,
            /// <summary>
            /// フィルタ種別
            /// </summary>
            FilterType,
            /// <summary>
            /// 繰返し回数
            /// </summary>
            RepeatCount,
            /// <summary>
            /// テンプレート内外
            /// </summary>
            IsInTemplete
        }
        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// グループを一意に特定するためのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.GroupPath)]
        public String GroupPath { get; set; } = String.Empty;

        /// <summary>
        /// カテゴリの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataCategory)]
        public String DataCategory { get; set; } = String.Empty;

        /// <summary>
        /// クラスの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataClass)]
        public String DataClass { get; set; } = String.Empty;

        /// <summary>
        /// グループ名の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.GroupName)]
        public String GroupName { get; set; } = String.Empty;

        /// <summary>
        /// 改ページ有無変更用チェックボックス列を表します。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.IsNewPage)]
        public string IsNewPage { get; set; } = RldConst.ParamData.VAL_ISNEWPAGE_FALSE;

        /// <summary>
        /// フィルタデータの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterData)]
        public String FilterData { get; set; } = String.Empty;

        /// <summary>
        /// フィルタ状態の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterState)]
        public String FilterState { get; set; } = String.Empty;

        /// <summary>
        /// フィルタ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterType)]
        public String FilterType { get; set; } = String.Empty;

        /// <summary>
        /// 繰返し回数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.RepeatCount)]
        public String RepeatCount { get; set; } = String.Empty;

        /// <summary>
        /// テンプレート内外の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.IsInTemplete)]
        public string IsInTemplete { get; set; } = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
        #endregion
    }
}