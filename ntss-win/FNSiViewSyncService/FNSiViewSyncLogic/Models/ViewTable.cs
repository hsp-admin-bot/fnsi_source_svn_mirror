using System.Collections.Generic;
using Newtonsoft.Json;


namespace FNSiViewSyncLogicLib.Models
{
    public class ViewTable

    {
        [JsonProperty("tblName")]
        public string tableName { get; set; }

        [JsonProperty("keyName")]
        public string keyName { get; set; }

        [JsonProperty("jobKeyName")]
        public string jobKeyName { get; set; }

        [JsonProperty("sqlCds")]
        public List<string> sqlCodes { get; set; }

        public int isFirst { get; set; }

        [JsonProperty("dataKey")]
        public DataKey dataKey { get; set; }
    }

}
