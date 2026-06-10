using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetDetailData
    {
        /// <summary>
        /// データカテゴリの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_category")]
        public string DataCategory { get; set; } = string.Empty;

        /// <summary>
        /// データクラスの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_class")]
        public string DataClass { get; set; } = string.Empty;

        /// <summary>
        /// データ項目コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_code")]
        public string DataCode { get; set; } = string.Empty;

        /// <summary>
        /// データ項目名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_name")]
        public string DataName { get; set; } = string.Empty;

        /// <summary>
        /// フィールド名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "field_name")]
        public string FieldName { get; set; } = string.Empty;

        /// <summary>
        /// 変換リストの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "conv_table")]
        public List<SysDataSetDetailConvTableData> ConvTable { get; set; } = new List<SysDataSetDetailConvTableData>();

        /// <summary>
        /// データ型の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_type")]
        public string DataType { get; set; } = string.Empty;

        /// <summary>
        /// プレビューデータの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "preview")]
        public string Preview { get; set; } = string.Empty;

        /// <summary>
        /// 既定の書式の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "disp_format")]
        public string DispFormat { get; set; } = string.Empty;

        /// <summary>
        /// 計算式内使用可否の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "can_calc")]
        public string CanCalc { get; set; } = string.Empty;

        /// <summary>
        /// 使用する施設指定/使用しない施設指定 の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "facility_filter_type")]
        public string FacilityFilterType { get; set; } = string.Empty;

        /// <summary>
        /// 施設コード配列の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "facility_table")]
        public string FacilityTable { get; set; } = string.Empty;

        /// <summary>
        /// 値置換用SQL情報の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "conv_sql")]
        public SysDataSetDetailConvSqlData ConvSql { get; set; } = null;

        /// <summary>
        /// この項目が印刷できるラベル分類識別子の配列情報の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "label_classes")]
        public int[] LabelClasses { get; set; } = null;

        /// <summary>
        /// この項目が印刷できるラベル分類識別子の配列情報の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "filter_type")]
        public string FilterType { get; set; } = string.Empty;

        // add 2020-09-28 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 start
        /// <summary>
        /// データ整列化。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "data_sort")]
        public string DataSort { get; set; } = string.Empty;
        // add 2020-09-28 FNSI-仕様追加 DataListデータリストにソート機能を追加 李 end

        // add 2021-08-30 6009画像 李 start
        /// <summary>
        /// 画像
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "is_image")]
        public string IsImage { get; set; } = string.Empty;
        // add 2021-08-30 6009画像 李 start
    }
}
