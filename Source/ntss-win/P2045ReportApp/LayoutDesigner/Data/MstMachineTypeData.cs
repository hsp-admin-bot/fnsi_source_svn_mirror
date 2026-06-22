using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner
{
    /// <summary>
    /// 装置型式マスタデータ
    /// </summary>
    [System.Runtime.Serialization.DataContract()]
    public class MstMachineTypeData
    {
        #region メンバプロパティ定義

        /// <summary>
        /// 型式コードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "machineTypeCd")]
        public String MachineTypeCd { get; set; } = String.Empty;

        /// <summary>
        /// 型式名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "machineType")]
        public String MachineTypeName { get; set; } = String.Empty;

        #endregion
    }
}
