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
    public class FilterInspectionData
    {
        #region メンバプロパティ定義

		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
        /// <summary>
        /// 点検グループコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "menteCategoryCd")]
        public Int64 CategoryCode { get; set; } = 0L;

        /// <summary>
        /// 点検グループ名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "categoryName")]
        public String CategoryName { get; set; } = String.Empty;
		// add #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end

        /// <summary>
        /// 点検コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "menteDetailCd")]
        public Int64 InspectionCode { get; set; } = 0L;

        /// <summary>
        /// 点検名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "menteContent1")]
        public String InspectionName { get; set; } = String.Empty;

        // add FNSI-4872 装置帳票の点検名表示内容改善 夏 start
        /// <summary>
        /// 点検名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "menteContent2")]
        public String InspectionName2 { get; set; } = String.Empty;
        // add FNSI-4872 装置帳票の点検名表示内容改善 夏 end

        #endregion
    }
}
