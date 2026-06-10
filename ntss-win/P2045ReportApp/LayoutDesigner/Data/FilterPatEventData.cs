using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 患者イベントフィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterPatEventData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// カテゴリコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "categoryCd")]
        public Int64 CategoryCode { get; set; } = 0;

        /// <summary>
        /// カテゴリ名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "categoryName")]
        public String CategoryName { get; set; } = String.Empty;

        /// <summary>
        /// サブカテゴリコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "subCategoryCd")]
        public Int64 SubCategoryCode { get; set; } = 0;

        /// <summary>
        /// サブカテゴリ名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "subCategoryName")]
        public String SubCategoryName { get; set; } = String.Empty;

        #endregion
    }
}
