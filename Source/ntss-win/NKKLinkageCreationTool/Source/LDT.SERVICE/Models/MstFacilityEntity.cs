using Newtonsoft.Json;
using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class MstFacilityEntity : BaseEntity
  {
    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("facilityName")]
    public string FacilityName { get; set; }

    [JsonIgnore]
    public string ValueMember => FacilityCd;

    [JsonIgnore]
    public string DisplayMember => string.Join(" - ", new List<string>() { FacilityCd, FacilityName });
  }
}
