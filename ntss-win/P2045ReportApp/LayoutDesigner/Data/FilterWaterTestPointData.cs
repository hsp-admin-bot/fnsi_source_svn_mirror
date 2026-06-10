using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 水質調査箇所フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterWaterTestPointData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 対象装置の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "machine_no")]
        public String WaterSurveyMachineNo { get; set; } = String.Empty;

        /// <summary>
        /// 対象装置名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "machine_name")]
        public String WaterSurveyMachineName { get; set; } = String.Empty;

        /// <summary>
        /// 水質検査種別コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "survey_type_cd")]
        public Int32 WaterSurveyTypeCd { get; set; } = 0;

        /// <summary>
        /// 水質検査種別名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "survey_type_name")]
        public String WaterSurveyTypeName { get; set; } = String.Empty;

        /// <summary>
        /// 水質検査箇所コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "survey_point_cd")]
        public Int32 WaterSurveyPointCd { get; set; } = 0;

        /// <summary>
        /// 水質検査箇所名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "point_name")]
        public String WaterSurveyPointName { get; set; } = String.Empty;

        #endregion
    }
}
