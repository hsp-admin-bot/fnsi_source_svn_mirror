using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 観察記録種別フィルタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterObsKindData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 管理番号の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "kindNo")]
        public Int64 KindNo { get; set; } = 0;

        /// <summary>
        /// 種別名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "kindName")]
        public String KindName { get; set; } = String.Empty;

        /// <summary>
        /// 種別区分の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "kindClass")]
        public String KindClass { get; set; } = String.Empty;

        #endregion
    }
}
