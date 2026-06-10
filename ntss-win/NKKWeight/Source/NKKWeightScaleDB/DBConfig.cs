using System;
using System.Collections.Specialized;
using System.Configuration;
using System.IO;
using TdcLib;

namespace NKKWeightScaleDB
{
    public class DBConfig
    {
        public string GetCSVURL()
        {
            SystemSettingInfo sys = SystemSettingInfo.GetInstance();
            string value = sys.GetSingleLineValue(@"Settings\CSV", "Path", "").Trim();
            return value;
        }
    }
}