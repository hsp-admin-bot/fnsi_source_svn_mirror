using Newtonsoft.Json;

namespace LDT.SERVICE.Models.Responses
{
  public class LoginResponseEntity
  {
    [JsonProperty("facilityCd")]
    public string FacilityCode { get; set; }

    [JsonProperty("userId")]
    public long UserId { get; set; }

    [JsonProperty("userType")]
    public long UserType { get; set; }

    [JsonProperty("signInRestriction")]
    public bool SignInrestriction { get; set; }
  }

  public class LoginResponse : BaseResponse<LoginResponseEntity>
  {
  }
}
