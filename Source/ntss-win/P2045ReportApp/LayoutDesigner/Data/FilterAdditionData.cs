using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 加算フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterAdditionData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 加算コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "code")]
        public Int64 AdditionCode { get; set; } = 0;

        /// <summary>
        /// 加算名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "name")]
        public String AdditionName { get; set; } = String.Empty;

        #endregion
    }
}
