using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class GetByMstCoopFacilityRequest : BaseRequest
    {
        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }

        [JsonProperty("ctlNo")]
        public string CtlNo { get; set; }
    }
}
