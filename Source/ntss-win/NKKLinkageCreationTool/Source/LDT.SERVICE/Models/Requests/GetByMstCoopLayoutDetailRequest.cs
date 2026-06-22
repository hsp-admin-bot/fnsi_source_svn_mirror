using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class GetByMstCoopLayoutDetailRequest : BaseRequest
  {
    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("coopCd")]
    public string CoopCd { get; set; }

    [JsonProperty("direction")]
    public string Direction { get; set; }

    [JsonProperty("coopCdDetail")]
    public string CoopCdDetail { get; set; }

    [JsonProperty("coopDetailSub")]
    public string CoopDetailSub { get; set; }
  }
}
