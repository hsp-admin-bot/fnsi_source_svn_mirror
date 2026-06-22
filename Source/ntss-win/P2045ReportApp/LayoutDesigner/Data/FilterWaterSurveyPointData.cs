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
    public class FilterWaterSurveyPointData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 水質調査箇所コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "code")]
        public Int32 WaterSurveyPointCode { get; set; } = 0;

        /// <summary>
        /// 水質調査箇所名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "name")]
        public String WaterSurveyPointName { get; set; } = String.Empty;

        #endregion
    }
}
