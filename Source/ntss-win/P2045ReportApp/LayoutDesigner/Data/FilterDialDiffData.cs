using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 透析困難フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterDialDiffData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 透析困難コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dialysisDifficultyCd")]
        public Int32 DialDiffCode { get; set; } = 0;

        /// <summary>
        /// 透析困難名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "dialysisDifficultyName")]
        public String DialDiffName { get; set; } = String.Empty;

        #endregion
    }
}
