using Newtonsoft.Json;
using System.IO;

namespace LDT.SERVICE.Configuration
{
  public class ConfigConstant
  {
    [JsonProperty("COOP_SUB_CD_QUERIES")]
    public string COOP_SUB_CD_QUERIES { get; set; }
  }

  public class ConfigApi
  {
    [JsonProperty("BASE_DOMAIN")]
    public string BASE_DOMAIN { get; set; }

    [JsonProperty("BASE_URL")]
    public string BASE_URL { get; set; }

    [JsonProperty("LOGIN_URL")]
    public string LOGIN_URL { get; set; }

    [JsonProperty("GET_ALL_MST_COOP_LAYOUT")]
    public string GET_ALL_MST_COOP_LAYOUT { get; set; }

    [JsonProperty("CREATE_OR_UPDATE_MST_COOP_LAYOUT")]
    public string CREATE_OR_UPDATE_MST_COOP_LAYOUT { get; set; }

    [JsonProperty("CREATE_OR_UPDATE_MST_COOP_LAYOUT_DETAIL")]
    public string CREATE_OR_UPDATE_MST_COOP_LAYOUT_DETAIL { get; set; }

    [JsonProperty("FACILITY_CD")]
    public string FACILITY_CD { get; set; }

    [JsonProperty("GET_ALL_DATA_SET")]
    public string GET_ALL_DATA_SET { get; set; }

    [JsonProperty("GET_BY_MST_COOP_DISTRIBUTE")]
    public string GET_BY_MST_COOP_DISTRIBUTE { get; set; }

    [JsonProperty("GET_BY_MST_COOP_FACILITY")]
    public string GET_BY_MST_COOP_FACILITY { get; set; }

    [JsonProperty("GET_ALL_FACILITY")]
    public string GET_ALL_FACILITY { get; set; }

    [JsonProperty("GET_BY_MST_COOP_LAYOUT_DETAIL")]
    public string GET_BY_MST_COOP_LAYOUT_DETAIL { get; set; }
  }

  public class ApplicationConfigJSON
  {
    [JsonProperty("API")]
    public ConfigApi API { get; set; }

    [JsonProperty("CONSTANT")]
    public ConfigConstant CONSTANT { get; set; }
  }

  public static class AppSettingConfig
  {
    private static ApplicationConfigJSON _ApplicationConfigJSON;

    public static ApplicationConfigJSON ApplicationConfigJSON
    {
      set
      {
        _ApplicationConfigJSON = value;
      }

      get
      {
        return _ApplicationConfigJSON;
      }
    }

    public static ApplicationConfigJSON LoadConfig()
    {
      if (ApplicationConfigJSON == default(ApplicationConfigJSON))
      {
        LoadJsonConfig();
      }
      return ApplicationConfigJSON;
    }

    private static void LoadJsonConfig()
    {
      string apiConfigFilePath = "ApplicationConfig.json";
      using (StreamReader reader = new StreamReader(apiConfigFilePath))
      {
        string jsonValue = reader.ReadToEnd();
        ApplicationConfigJSON = JsonConvert.DeserializeObject<ApplicationConfigJSON>(jsonValue);
      }
    }
  }
}
