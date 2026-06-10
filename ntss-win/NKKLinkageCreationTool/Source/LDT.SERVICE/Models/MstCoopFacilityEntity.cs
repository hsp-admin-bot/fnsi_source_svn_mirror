using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class IfEdgeSettingProtocolInfo
  {
    [JsonProperty("protocol")]
    public Dictionary<string, string> Protocol { get; set; }

    [JsonProperty("file")]
    public Dictionary<string, string> File { get; set; }

    [JsonProperty("socket")]
    public Dictionary<string, string> Socket { get; set; }
  }

  public class IfEdgeSettingProtocol
  {
    [JsonProperty("protocolInfo")]
    public IfEdgeSettingProtocolInfo ProtocolInfo { get; set; }
  }

  public class MstCoopFacilityEntity : BaseEntity
  {
    [JsonProperty("regDate")]
    public DateTime RegDate { get; set; }

    [JsonProperty("upDate")]
    public DateTime UpDate { get; set; }

    [JsonProperty("ctlNo")]
    public string CtlNo { get; set; }

    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("description")]
    public string Description { get; set; }

    [JsonProperty("isDisp")]
    public string IsDisp { get; set; }

    [JsonProperty("isDel")]
    public string IsDel { get; set; }

    [JsonProperty("ifEdgeSetting")]
    public string IfEdgeSetting { get; set; }

    public void SetIfEdgeSetting(IfEdgeSettingProtocol ifEdgeSettingProtocolInfo)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      IfEdgeSetting = JsonConvert.SerializeObject(ifEdgeSettingProtocolInfo, settings);
    }

    [JsonProperty("commonSetting")]
    public string CommonSetting { get; set; }

    [JsonProperty("userId")]
    public string UserId { get; set; }

    [JsonIgnore]
    public IfEdgeSettingProtocol IfEdgeSettingProtocol
    {
      get
      {
        IfEdgeSettingProtocol item = new IfEdgeSettingProtocol();
        if (IfEdgeSetting != null)
        {
          var settings = new JsonSerializerSettings
          {
            NullValueHandling = NullValueHandling.Ignore,
            MissingMemberHandling = MissingMemberHandling.Ignore
          };
          item = JsonConvert.DeserializeObject<IfEdgeSettingProtocol>(IfEdgeSetting, settings);
        }
        if (item.ProtocolInfo is null)
        {
          item.ProtocolInfo = new IfEdgeSettingProtocolInfo()
          {
            Socket = new Dictionary<string, string>(),
            File = new Dictionary<string, string>(),
            Protocol = new Dictionary<string, string>()
          };
        }
        item.ProtocolInfo.File = item.ProtocolInfo.File ?? new Dictionary<string, string>();
        item.ProtocolInfo.Protocol = item.ProtocolInfo.Protocol ?? new Dictionary<string, string>();
        item.ProtocolInfo.Socket = item.ProtocolInfo.Socket ?? new Dictionary<string, string>();
        return item;
      }
    }
  }
}
