using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Requests
{
  public class LoginRequest : BaseRequest
    {
        [JsonProperty("userId")]
        public string UserId { get; set; }

        [JsonProperty("password")]
        public string Password { get; set; }

        [JsonProperty("facilityCd")]
        public string FacilityCd { get; set; }
    }
}
