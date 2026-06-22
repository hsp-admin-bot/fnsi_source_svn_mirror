using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class CreateOrUpdateCoopLayoutRequest : BaseRequest
  {
    [JsonProperty("mst_coop_layout")]
    public string MstCoopLayoutAfter { get; set; }

    [JsonProperty("mst_coop_layout_before")]
    public string MstCoopLayoutBefore { get; set; }

    [JsonProperty("mst_coop_distribute")]
    public string MstCoopDistributeAfter { get; set; }

    [JsonProperty("mst_coop_facility")]
    public string MstCoopFacilityAfter { get; set; }
  }
}
