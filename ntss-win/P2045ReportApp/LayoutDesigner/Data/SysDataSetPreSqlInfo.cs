using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetPreSqlInfo
    {
        /// <summary>
        /// items配列の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "items")]
        public List<SysDataSetPreSqlInfoData> PreSqlInfoItems { get; set; } = new List<SysDataSetPreSqlInfoData>();
    }
}
