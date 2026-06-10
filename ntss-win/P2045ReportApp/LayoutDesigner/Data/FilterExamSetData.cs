using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 検査セットフィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterExamSetData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 検査セットコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "code")]
        public Int64 ExamSetCode { get; set; } = 0L;

        /// <summary>
        /// 検査セット名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "name")]
        public String ExamSetName { get; set; } = String.Empty;

        #endregion
    }
}
