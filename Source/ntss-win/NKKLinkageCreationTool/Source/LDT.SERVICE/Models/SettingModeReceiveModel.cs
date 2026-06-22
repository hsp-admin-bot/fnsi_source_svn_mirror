using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class ProtocolFileModeReceive
  {
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }

  public class ProtocolSocketModeReceive
  {
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }

  public class SettingModeReceiveModel
  {
    public ProtocolFileModeReceive File { get; set; }
    public ProtocolSocketModeReceive Socket { get; set; }
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }
}
