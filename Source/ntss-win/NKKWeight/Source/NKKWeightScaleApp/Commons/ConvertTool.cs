using Newtonsoft.Json;
using NKKWeightScaleApp.Models;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;

namespace NKKWeightScaleApp.Commons
{
    public class ConvertTool
    {
        public DataTable ConvertListToDataTable<T>(IList<T> data)
        {
            try
            {
                PropertyDescriptorCollection properties = TypeDescriptor.GetProperties(typeof(T));
                DataTable table = new DataTable();
                foreach (PropertyDescriptor prop in properties)
                    table.Columns.Add(prop.Name, Nullable.GetUnderlyingType(prop.PropertyType) ?? prop.PropertyType);
                foreach (T item in data)
                {
                    DataRow row = table.NewRow();
                    foreach (PropertyDescriptor prop in properties)
                        row[prop.Name] = prop.GetValue(item) ?? DBNull.Value;
                    table.Rows.Add(row);
                }
                return table;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public List<CommonEx> ConvertToCommonEx(List<Common> commonList)
        {
            try
            {
                List<CommonEx> commonExList = commonList.Select(item => new CommonEx()
                {
                    Name = item.Name,
                    Value = item.Value
                }).ToList();
                return commonExList;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public List<Common> ConvertToCommonList(string data, string status)
        {
            try
            {
                List<Common> commonList = new List<Common>();
                Dictionary<string, string> result = JsonConvert.DeserializeObject<Dictionary<string, string>>(data);
                for (int i = 0; i < ConfigValue.COUNT_COMMON; i++)
                {
                    KeyValuePair<string, string> itemKey = result.FirstOrDefault(t => t.Key.ToLower() == "name_" + (i + 1).ToString());
                    KeyValuePair<string, string> itemValue = result.FirstOrDefault(t => t.Key.ToLower() == "weight_" + (i + 1).ToString());
                    decimal.TryParse(itemValue.Value, out decimal value);
                    commonList.Add(new Common
                    {
                        Unit = ConfigValue.UNIT_G,
                        Status = status,
                        Name = itemKey.Value,
                        Value = value
                    });
                }
                return commonList;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public string ConvertToCommonString(List<CommonEx> commons)
        {
            try
            {
                Dictionary<string, string> result = new Dictionary<string, string>();
                for (int index = 0; index < commons.Count; index++)
                {
                    CommonEx item = commons[index];
                    result.Add("name_" + (index + 1), item.Name);
                    result.Add("weight_" + (index + 1), item.Value.ToString());
                }
                string json = JsonConvert.SerializeObject(result);
                return json;
            }
            catch (Exception)
            {
                return null;
            }
        }

        public string FormatValue(decimal value)
        {
            return string.Format(ConfigValue.FORMAT, value);
        }

        public string ReplaceValue(string value)
        {
            return value.Replace(ConfigValue.UNIT_KG, string.Empty);
        }
    }
}