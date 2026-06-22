using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class MovingInCountResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<MovingInCountDataType> Data { get; set; } = new List<MovingInCountDataType>();
    }

    public class MovingInCountDataType
    {
        [JsonProperty("count")]
        public int COUNT { get; set; }

        public MovingInCountDataType() { }

        public MovingInCountDataType(int count)
        {
            COUNT = count;
        }
    }
}
