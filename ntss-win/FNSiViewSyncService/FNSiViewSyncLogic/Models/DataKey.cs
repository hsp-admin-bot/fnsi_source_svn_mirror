using System.Collections.Generic;
using Newtonsoft.Json;


namespace FNSiViewSyncLogicLib.Models
{
    public class DataKey
    {
        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string fromDate { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string toDate { get; set; }

        public string syncMode { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public string paramList1 { get; set; }
    }
}
