using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    public class DesignParamFromOldReportData
    {
        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// データパス
            /// </summary>
            DataPath = 0,
            /// <summary>
            /// 書式
            /// </summary>
            DisplayFormat,
            /// <summary>
            /// 繰返し可否
            /// </summary>
            CanRepeat,
            /// <summary>
            /// 繰返し場所
            /// </summary>
            RepeatAddress,
            /// <summary>
            /// 縮小して全体を表示
            /// </summary>
            IsShrink,
            /// <summary>
            /// 表示桁数(半角)
            /// </summary>
            Length,
            /// <summary>
            /// 改ページ有無
            /// </summary>
            IsNewPage,
            // mod 2023-03-16 #8335 FNW帳票取込みの動作に問題あり 鵬 start
            /// <summary>
            /// 配置場所
            /// </summary>
            CellAddress,
            // mod 2023-03-16 #8335 鵬 end
            // add 2023-03-16 #8335 FNW帳票取込みの動作に問題あり 鵬 start
            /// <summary>
            /// テンプレート内外の取得及び設定を行います。
            /// </summary>
            IsInTemplete,
            // add 2023-03-16 #8335 鵬 end

            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
            /// <summary>
            /// グループ名
            /// </summary>
            GroupName,
            /// <summary>
            /// データ種別
            /// </summary>
            DataType,
            /// <summary>
            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
            // <summary>
            /// 変換リスト
            /// </summary>
            ConvertList,
            /// <summary>
            // <summary>
            /// フィルタデータ
            /// </summary>
            FilterData,
            /// <summary>
            // <summary>
            /// ラベル項目
            /// </summary>
            LabelItem,
            /// <summary>
            // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
            /// <summary>
            /// フィルタ種別
            /// </summary>
            FilterType
            // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
        }
        #endregion

        #region メンバプロパティ定義
        /// <summary>
        /// データパスの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DataPath)]
        public string DataPath { get; set; } = string.Empty;

        /// <summary>
        /// 書式の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.DisplayFormat)]
        public string DisplayFormat { get; set; } = string.Empty;

        /// <summary>
        /// 繰返し可能項目かどうかの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.CanRepeat)]
        public bool CanRepeat { get; set; } = false;

        /// <summary>
        /// 繰返範囲の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.RepeatAddress)]
        public string RepeatAddress { get; set; } = string.Empty;

        /// <summary>
        /// 該当セルが縮小して全体を表示するように設定されているかどうかの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.IsShrink)]
        public string IsShrink { get; set; } = RldConst.ParamData.VAL_ISSHRINK_NONE;

        /// <summary>
        /// 表示桁数の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.Length)]
        public string Length { get; set; } = string.Empty;

        /// <summary>
        /// 改ページの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.IsNewPage)]
        public string IsNewPage { get; set; } = RldConst.ParamData.VAL_ISNEWPAGE_FALSE;

        /// <summary>
        /// 配置場所の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.CellAddress)]
        public string CellAddress { get; set; } = string.Empty;


        // add 2023-03-16 #8335 FNW帳票取込みの動作に問題あり 鵬 start
        /// <summary>
        /// テンプレート内外の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (Int32)EnumDataIndex.IsInTemplete)]
        public string IsInTemplete { get; set; } = RldConst.ParamData.VAL_IS_IN_TEMPLETE_NONE;
        // add 2023-03-16 #8335 鵬 end

        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
        /// <summary>
        /// グループ名
        /// </summary>
        public string GroupName { get; set; } = string.Empty;
        /// <summary>
        /// データ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.DataType)]
        public string DataType { get; set; } = string.Empty;
        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
        // add #12050 FNW帳票コンバートで維持されない設定がある 高 start
        /// <summary>
        /// 変換リストの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ConvertList)]
        public DesignConvertList ConvertList { get; set; } = new DesignConvertList();
        /// <summary>
        /// フィルタデータ
        /// </summary>
        public string FilterData { get; set; } = string.Empty;
        /// <summary>
        /// ラベル項目
        /// </summary>
        public string LabelItem { get; set; } = string.Empty;
        // add #12050 FNW帳票コンバートで維持されない設定がある 高 end
        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 start
        /// <summary>
        /// フィルタ種別の取得及び設定を行います。
        /// </summary>
        //[RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearance(DisplayIndex = (int)EnumDataIndex.FilterType)]
        public string FilterType { get; set; } = string.Empty;
        // add #6066 FNW帳票移行時にグループ名が移行されていない。 董 end
        #endregion
    }
}
