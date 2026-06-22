using Fnw.StatisticsTool.Data;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Models
{
    public class HasDiabetesResponse : ISysDataSetResponse
    {
        public bool Success { get; set; }
        public string Message { get; set; }
        public List<HasDiabetesDataType> Data { get; set; } = new List<HasDiabetesDataType>();
    }

    public class HasDiabetesDataType
    {
        [JsonProperty("disease_cd")]
        public string DISEASE_CD { get; set; }

        public HasDiabetesDataType() { }

        public HasDiabetesDataType(string diseaseCd)
        {
            DISEASE_CD = diseaseCd;
        }
    }
}
