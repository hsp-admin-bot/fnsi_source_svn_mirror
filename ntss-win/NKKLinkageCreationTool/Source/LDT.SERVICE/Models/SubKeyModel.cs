using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class SubKeyModel
  {
    public string KeyName { get; set; }
    public List<KeyValue> ValueList { get; set; }
  }

  public class KeyValue
  {
    public string KeyName { get; set; }
    public string Value { get; set; }
  }
}
