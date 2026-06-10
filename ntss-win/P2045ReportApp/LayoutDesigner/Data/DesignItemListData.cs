using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Windows.Forms;

namespace LayoutDesigner
{
    /// <summary>
    /// データ項目リスト用アイテムデータクラス
    /// </summary>
    public class DesignItemListData
    {

        /// <summary>
        /// 分類別情報のカテゴリ
        /// </summary>
        public const string dcLabel = "ラベル";

        /// <summary>
        /// 分類別情報のクラス
        /// </summary>
        public const string dcMaterialInfo = "物品情報";

        /// <summary>
        /// 分類別情報の項目名
        /// </summary>
        public const string dcClassificationInfo = "分類別情報";

        #region メンバ列挙体定義

        public enum EnumDataIndex
        {
            /// <summary>
            /// カテゴリ
            /// </summary>
            DataCategory = 0,
            /// <summary>
            /// クラス
            /// </summary>
            DataClass,
            /// <summary>
            /// 項目名
            /// </summary>
            DataName,
            /// <summary>
            /// SQLコード
            /// </summary>
            SqlCode,
            /// <summary>
            /// データ項目コード
            /// </summary>
            DataCode,
            /// <summary>
            /// データ種別
            /// </summary>
            DataType,
            /// <summary>
            /// 表示フォーマット
            /// </summary>
            DisplayFormat,
            /// <summary>
            /// 変換リスト
            /// </summary>
            ConvertList,
            /// <summary>
            /// フィルタ種別
            /// </summary>
            FilterType,
            /// <summary>
            /// 繰返し可否フラグ
            /// </summary>
            CanRepeat,
            /// <summary>
            /// 計算可否フラグ
            /// </summary>
            CanCalc,
            /// <summary>
            /// プレビューデータ
            /// </summary>
            PreviewData,
            /// <summary>
            /// データパス
            /// </summary>
            DataPath,
            /// <summary>
            /// グループ名
            /// </summary>
            GroupName
            // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
            /// <summary>
            /// データ整列化
            /// </summary>
            ,DataSort
            // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end
            // add 2021-08-30 6009画像 李 start
            /// 画像
            , IsImage
            // add 2021-08-30 6009画像 李 end

        }

        #endregion

        #region メンバプロパティ定義

        /// <summary>
        /// データを一意に特定するためのフルパスの取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataPath)]
        public String DataPath => LayoutDataSet.MakeDataPath(this.DataCategory, this.DataClass, this.DataName);

        /// <summary>
        /// カテゴリの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(Width = 80)]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataCategory, HeaderText = "カテゴリ")]
        public String DataCategory { get; set; } = String.Empty;

        /// <summary>
        /// クラスの取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataClass, HeaderText = "クラス")]
        public String DataClass { get; set; } = String.Empty;

        /// <summary>
        /// 項目名の取得及び設定を行います。
        /// </summary>
        [RldGridRCDesign(typeof(DataGridViewTextBoxColumn))]
        [RldGridRCBehavior()]
        [RldGridRCLayout(AutoSizeMode = System.Windows.Forms.DataGridViewAutoSizeColumnMode.Fill)]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataName, HeaderText = "項目名")]
        public String DataName { get; set; } = String.Empty;

        /// <summary>
        /// SQLコードの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.SqlCode)]
        public String SqlCode { get; set; } = String.Empty;

        /// <summary>
        /// データ項目コードの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataCode)]
        public String DataCode { get; set; } = String.Empty;

        /// <summary>
        /// データ種別の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataType)]
        public String DataType { get; set; } = String.Empty;

        /// <summary>
        /// 表示フォーマットの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DisplayFormat)]
        public String DisplayFormat { get; set; } = String.Empty;

        /// <summary>
        /// 変換リストの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.ConvertList)]
        public DesignConvertList ConvertList { get; set; } = new DesignConvertList();

        /// <summary>
        /// フィルタ種別の取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.FilterType)]
        public String FilterType { get; set; } = String.Empty;

        /// <summary>
        /// 繰返し可能項目かどうかの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.CanRepeat)]
        public Boolean CanRepeat { get; set; } = false;

        /// <summary>
        /// 計算可能項目かどうかの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.CanCalc)]
        public Boolean CanCalc { get; set; } = false;

        /// <summary>
        /// プレビューデータの取得及び設定を行います。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.PreviewData)]
        public String PreviewData { get; set; } = String.Empty;

        /// <summary>
        /// 既定のグループ名の取得を行います。
        /// 値の取得のみ可能です。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.GroupName)]
        public String GroupName
        {
            [System.Diagnostics.DebuggerStepThrough()]
            get {
                String wRet = String.Empty;

                if( this.CanRepeat )
                    wRet = String.Format("{0}{1}{2}", this.DataCategory, RldConst.PATH_SPLIT, this.DataClass);

                return wRet;
            }
        }

        // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
        /// <summary>
        /// データ整列化。
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.DataSort)]
        public string DataSort { get; set; }
        // add 2020-09-27 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end

        // add  李 start
        /// <summary>
        /// 
        /// </summary>
        [RldGridRCBehavior()]
        [RldGridRCLayout()]
        [RldGridRCAppearanceAttribute(DisplayIndex = (Int32)EnumDataIndex.IsImage)]
        public String IsImage { get; set; } = String.Empty;
        // add  李 end

        /// <summary>
        /// 特別な用途に使用する情報の取得を行います
        /// </summary>
        public string ParticularInfo
        {
            get
            {
                return (this.DataCategory == dcLabel) && (this.DataClass == dcMaterialInfo) && (this.DataName == dcClassificationInfo) && (this.DataPath == $"##{dcLabel}.{dcMaterialInfo}.{dcClassificationInfo}") ? "label" : string.Empty;
            }
        }

        #endregion
    }
}
