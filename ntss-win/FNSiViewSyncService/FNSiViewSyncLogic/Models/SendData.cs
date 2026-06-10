using System.Collections.Generic;

namespace FNSiViewSyncLogicLib.Models
{
    public class SendData
    {
        public string host { get; set; }
        public int port { get; set; }
        public int SyncMode { get; set; }
        public string RegDate { get; set; }
        public List<ViewTable> tables { get; set; }
    }
}
