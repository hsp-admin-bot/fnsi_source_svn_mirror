using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class DistributeProtocolInfo
  {
    [JsonProperty("file")]
    public Dictionary<string, string> File { get; set; }

    [JsonProperty("socket")]
    public Dictionary<string, string> Socket { get; set; }

    [JsonProperty("ftp")]
    public Dictionary<string, string> FTP { get; set; }
  }

  public class DistributeSettingProtocol
  {
    [JsonProperty("protocolInfo")]
    public DistributeProtocolInfo ProtocolInfo { get; set; }
  }

  public class MstCoopDistributeEntity : BaseEntity
  {
    [JsonProperty("regDate")]
    public DateTime RegDate { get; set; }

    [JsonProperty("upDate")]
    public DateTime UpDate { get; set; }

    [JsonProperty("ctlNo")]
    public long CtlNo { get; set; }

    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("coopCd")]
    public string CoopCd { get; set; }

    [JsonProperty("coopCdIndex")]
    public string CoopCdIndex { get; set; }

    [JsonProperty("direction")]
    public string Direction { get; set; }

    [JsonProperty("coopVender")]
    public string CoopVender { get; set; }

    [JsonProperty("description")]
    public string Description { get; set; }

    [JsonProperty("isEditable")]
    public string IsEditable { get; set; }

    [JsonProperty("distributeSetting")]
    public string DistributeSetting { get; set; }

    public void SetDistributeSetting(DistributeSettingProtocol distributeSettingProtocol)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      DistributeSetting = JsonConvert.SerializeObject(distributeSettingProtocol, settings);
    }

    [JsonProperty("isDisp")]
    public string IsDisp { get; set; }

    [JsonProperty("isDel")]
    public string IsDel { get; set; }

    [JsonProperty("userId")]
    public long UserId { get; set; }

    [JsonIgnore]
    public DistributeSettingProtocol DistributeSettingProtocol
    {
      get
      {
        DistributeSettingProtocol item = new DistributeSettingProtocol();
        if (DistributeSetting != null)
        {
          var settings = new JsonSerializerSettings
          {
            NullValueHandling = NullValueHandling.Ignore,
            MissingMemberHandling = MissingMemberHandling.Ignore
          };
          item = JsonConvert.DeserializeObject<DistributeSettingProtocol>(DistributeSetting, settings);
          if (item.ProtocolInfo is null)
          {
            item.ProtocolInfo = new DistributeProtocolInfo()
            {
              File = new Dictionary<string, string>(),
              Socket = new Dictionary<string, string>(),
              FTP = new Dictionary<string, string>()
            };
          }
          item.ProtocolInfo.File = item.ProtocolInfo.File ?? new Dictionary<string, string>();
          item.ProtocolInfo.FTP = item.ProtocolInfo.FTP ?? new Dictionary<string, string>();
          item.ProtocolInfo.Socket = item.ProtocolInfo.Socket ?? new Dictionary<string, string>();
        }
        return item;
      }
    }
  }
}
