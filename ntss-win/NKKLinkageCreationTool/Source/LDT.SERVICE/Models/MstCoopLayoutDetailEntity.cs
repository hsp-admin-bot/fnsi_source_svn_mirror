using Newtonsoft.Json;
using System;

namespace LDT.SERVICE.Models
{
  public class MstCoopLayoutDetailEntity
  {
    [JsonProperty("coopCdDetail")]
    public string CoopCdDetail { get; set; }

    [JsonProperty("coopCdDetailSub")]
    public string CoopCdDetailSub { get; set; }

    [JsonProperty("regDate")]
    public DateTime? RegDate { get; set; }

    [JsonProperty("upDate")]
    public DateTime? UpDate { get; set; }

    [JsonProperty("ctlNo")]
    public string CtlNo { get; set; }

    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("coopCd")]
    public string CoopCd { get; set; }

    [JsonProperty("direction")]
    public string Direction { get; set; }

    [JsonProperty("coopName")]
    public string CoopName { get; set; }

    [JsonProperty("description")]
    public string Description { get; set; }

    [JsonProperty("isEditable")]
    public string IsEditable { get; set; }

    [JsonProperty("coopSetting")]
    public string CoopSettingString { get; set; }

    [JsonProperty("coopSettingRoot")]
    public CoopSetting CoopSetting { get; set; }

    [JsonProperty("coopExtSetting")]
    public CoopExtSetting CoopExtSetting { get; set; }

    [JsonProperty("isDisp")]
    public string IsDisp { get; set; }

    [JsonProperty("isDel")]
    public string IsDel { get; set; }

    [JsonProperty("userId")]
    public string UserId { get; set; }
  }
}
