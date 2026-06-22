using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 医材フィルタデータクラス
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class FilterEquipData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 医材分類の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "classType")]
        public Int64 ClassType { get; set; } = 0;

        /// <summary>
        /// 医材分類名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "className")]
        public String ClassName { get; set; } = String.Empty;

        /// <summary>
        /// 医材コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "equipmentCd")]
        public Int64 EquipCode { get; set; } = 0;

        /// <summary>
        /// 医材名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "equipmentName")]
        public String EquipName { get; set; } = String.Empty;

        #endregion
    }
}
