using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class ProtocolFileModeSend
  {
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }

  public class ProtocolSocketModeSend
  {
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }

  public class ProtocolFTPModeSend
  {
    public Dictionary<string, string> KeyValuePairs { get; set; }
  }

  public class SettingModeSendModel
  {
    public ProtocolFileModeSend File { get; set; }
    public ProtocolSocketModeSend Socket { get; set; }
    public ProtocolFTPModeSend FTP { get; set; }
  }
}
