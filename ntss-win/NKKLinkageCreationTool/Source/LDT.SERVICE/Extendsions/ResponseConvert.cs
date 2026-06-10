using LDT.SERVICE.Models.Responses;
using Newtonsoft.Json;

namespace LDT.SERVICE.Extendsions
{
  public static class ResponseConvert
  {
    public static TResult ToClass<TEntity, TResult>(this BaseResponse<TEntity> obj) where TEntity : class
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var json = JsonConvert.SerializeObject(obj, settings);
      var outData = JsonConvert.DeserializeObject<TResult>(json, settings);
      return outData;
    }

    public static TResult Asssign<TEntity, TResult>(this TEntity obj) where TEntity : class
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var json = JsonConvert.SerializeObject(obj, settings);
      var outData = JsonConvert.DeserializeObject<TResult>(json, settings);
      return outData;
    }
  }
}
