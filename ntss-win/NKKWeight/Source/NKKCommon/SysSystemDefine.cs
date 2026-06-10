using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace NKKCommon
{
    [System.Runtime.Serialization.DataContract]
    internal class SysSystemDefine
    {

        /// <summary>
        /// 施設コード
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "facilityCd")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// 管理番号
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "ctlNo")]
        public int CtlNo { get; set; }

        /// <summary>
        /// サービスコード
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "serviceCd")]
        public string ServiceCd { get; set; }

        /// <summary>
        /// 名称
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "name")]
        public string Name { get; set; }

        /// <summary>
        /// 値
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "value")]
        public string Value { get; set; }

        /// <summary>
        /// 説明
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "description")]
        public string Description { get; set; }

        /// <summary>
        /// 編集可否
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "isEnable")]
        public string IsEnable { get; set; }

        /// <summary>
        /// 更新日時
        /// </summary>
        [System.Runtime.Serialization.DataMember(Name = "upDate")]
        public string UpDate { get; set; }

    }
}
