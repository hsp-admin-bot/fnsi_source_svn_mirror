using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 点検フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterDistributionData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 薬剤分類コードの取得及び設定を行います。
        /// </summary>
        // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
        //[System.Runtime.Serialization.DataMember(Name = "dialyzerCd")]
        [System.Runtime.Serialization.DataMember(Name = "code")]
        // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
        public Int64 dialyzerCd { get; set; } = 0;

        /// <summary>
        /// 薬剤分類名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "functionClass")]
        public String functionClass { get; set; } = String.Empty;

        /// <summary>
        /// 薬剤種別(通常薬剤/調製薬剤)コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dialyzerType")]
        public Int32 dialyzerType { get; set; } = 0;

        /// <summary>
        /// 薬剤名の取得及び設定を行います。
        /// </summary>
        // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe start
        //[System.Runtime.Serialization.DataMember(Name = "modelNumber")]
        [System.Runtime.Serialization.DataMember(Name = "name")]
        // mod #11789 【因島】準備リストを医材と薬剤と分けて出力することができない limingzhe end
        public String modelNumber { get; set; } = String.Empty;
        #endregion
    }
}
