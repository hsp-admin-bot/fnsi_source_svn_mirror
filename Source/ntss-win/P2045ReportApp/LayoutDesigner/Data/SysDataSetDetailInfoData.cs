using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetDetailInfoData
    {

        /// <summary>
        /// detail配列の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "details")]
        public List<SysDataSetDetailData> Details { get; set; } = new List<SysDataSetDetailData>();

    }
}
