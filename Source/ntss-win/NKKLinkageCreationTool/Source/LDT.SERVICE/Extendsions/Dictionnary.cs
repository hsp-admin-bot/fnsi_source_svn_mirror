using Newtonsoft.Json;
using System.Collections.Generic;

namespace LDT.SERVICE.Extendsions
{
  public static class Dictionnary
  {
    public static Dictionary<string, TValue> ToDictionary<TValue>(this object obj)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var json = JsonConvert.SerializeObject(obj, settings);
      var dictionary = JsonConvert.DeserializeObject<Dictionary<string, TValue>>(json, settings);
      return dictionary;
    }
  }
}
