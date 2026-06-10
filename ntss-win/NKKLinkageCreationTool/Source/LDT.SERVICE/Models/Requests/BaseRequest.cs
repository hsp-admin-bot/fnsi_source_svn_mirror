using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class BaseRequest
  {
    [JsonProperty("page")]
    public int? Page { get; set; }

    [JsonProperty("per_page")]
    public int? PerPage { get; set; }
  }
}
