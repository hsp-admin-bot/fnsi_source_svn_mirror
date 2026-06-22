using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 検査項目フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterExamItemData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 検査項目コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "code")]
        public Int64 ExamItemCode { get; set; } = 0L;

        /// <summary>
        /// 検査項目名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "name")]
        public String ExamItemName { get; set; } = String.Empty;

        #endregion

    }
}
