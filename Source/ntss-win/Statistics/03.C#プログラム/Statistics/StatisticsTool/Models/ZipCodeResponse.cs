using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class ZipCodeResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<ZipCodeDataType> Data { get; set; } = new List<ZipCodeDataType>();
    }

    public class ZipCodeDataType
    {
        [JsonProperty("address")]
        public string ADDRESS { get; set; }

        public ZipCodeDataType() { }

        public ZipCodeDataType(string  address)
        {
            ADDRESS = address;
        }
    }
}
