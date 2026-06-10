using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace LayoutDesigner.Data
{

    [System.Runtime.Serialization.DataContract()]
    public class SysDataSetPreSqlInfoData
    {
        /// <summary>
        /// 対象SQLコードの取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "sql_cd")]
        public string SqlCd { get; set; } = string.Empty;

        /// <summary>
        /// 置換変数の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "replace_var")]
        public string ReplaceVar { get; set; } = string.Empty;

        /// <summary>
        /// フィールド名の取得及び設定を行います。
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "field_name")]
        public string FieldName { get; set; } = string.Empty;

    }
}
