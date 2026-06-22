using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class GetAllByFilterAsyncRequest : BaseRequest
  {
    [JsonProperty("coopCdSub")]
    public string CoopCdSub { get; set; }

    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("coopCd")]
    public string CoopCd { get; set; }

    [JsonProperty("direction")]
    public string Direction { get; set; }
  }
}
