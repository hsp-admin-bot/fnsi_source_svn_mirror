using CsvHelper;
using LDT.LOG;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace LDT.SERVICE.Implements
{
  public class MasterService : IMasterService
    {
        public List<CoopCdTypeModel> LoadCoopCdType()
        {
            var pathFile = @"Assets\CSV\coop_cd_type.csv";
            List<CoopCdTypeModel> result = new List<CoopCdTypeModel>();
            try
            {
                using (var stream = File.Open(pathFile, FileMode.Open, FileAccess.Read, FileShare.Read))
                {
                    using (StreamReader streamReader = new StreamReader(stream, Encoding.GetEncoding("shift-jis")))
                    using (CsvReader csvReader = new CsvReader(streamReader, CultureInfo.InvariantCulture))
                    {
                        csvReader.Configuration.HasHeaderRecord = false;
                        result = csvReader.GetRecords<CoopCdTypeModel>().ToList();
                    }
                }
            }
            catch (Exception ex)
            {
                LogHelper.LogError(ex);
            }
            return result;
        }
    }
}
