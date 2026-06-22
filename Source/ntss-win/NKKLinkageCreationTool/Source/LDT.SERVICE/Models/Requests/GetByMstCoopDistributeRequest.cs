using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class GetByMstCoopDistributeRequest : BaseRequest
    {
        [JsonProperty("ctlNo")]
        public string CtlNo { get; set; }

        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }

        [JsonProperty("coopCd")]
        public string CoopCd { get; set; }
    }
}
