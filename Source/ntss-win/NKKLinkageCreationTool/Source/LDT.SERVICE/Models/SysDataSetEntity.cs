using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class SysDataSetDetailInfo
  {
    [JsonProperty("details")]
    public List<Dictionary<string, object>> Details { get; set; }
  }

  public class SysDataSetEntity : BaseEntity
  {
    [JsonProperty("regDate")]
    public DateTime RegDate { get; set; }

    [JsonProperty("upDate")]
    public DateTime UpDate { get; set; }

    [JsonProperty("sqlCd")]
    public int SqlCd { get; set; }

    [JsonProperty("sql")]
    public string Sql { get; set; }

    [JsonProperty("dbClass")]
    public int DbClass { get; set; }

    [JsonProperty("detailInfo")]
    public SysDataSetDetailInfo DetailInfo { get; set; }

    [JsonProperty("canRepeat")]
    public string CanRepeat { get; set; }

    [JsonProperty("useApplication")]
    public string UseApplication { get; set; }

    //[JsonProperty("reportClass")]
    //public string ReportClass { get; set; }

    [JsonProperty("memo")]
    public string Memo { get; set; }

    public string TextDisplay => string.Format("{0} - {1}", SqlCd, Memo);
  }
}
