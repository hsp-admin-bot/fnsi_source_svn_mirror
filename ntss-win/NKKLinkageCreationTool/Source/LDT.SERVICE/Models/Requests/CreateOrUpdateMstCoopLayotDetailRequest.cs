using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class CreateOrUpdateMstCoopLayoutDetailRequest : BaseRequest
  {
    [JsonProperty("mst_coop_layout_detail_before")]
    public string MstCoopLayoutDetailBefore { get; set; }

    [JsonProperty("mst_coop_layout_detail")]
    public string MstCoopLayoutDetailAfter { get; set; }

    [JsonProperty("mst_coop_layout_before")]
    public string MstCoopLayoutBefore { get; set; }

    [JsonProperty("mst_coop_facility")]
    public string MstCoopFacility { get; set; }

    [JsonProperty("mst_coop_distribute")]
    public string MstCoopDistribute { get; set; }
  }
}
