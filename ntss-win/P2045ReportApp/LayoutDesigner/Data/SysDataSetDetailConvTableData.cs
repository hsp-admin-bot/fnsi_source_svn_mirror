using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetDetailConvTableData
    {
        /// <summary>
        /// 値の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "code")]
        public string Code { get; set; } = string.Empty;

        /// <summary>
        /// 候補の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "item")]
        public string Item { get; set; } = string.Empty;

        /// <summary>
        /// 出力文字列の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "disp")]
        public string Disp { get; set; } = string.Empty;

    }
}
