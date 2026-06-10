using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Fnw.StatisticsTool.Data
{
    public interface ISysDataSetResponse
    {
        bool Success { get; set; }
        string Message { get; set; }
    }
}
