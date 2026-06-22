using Newtonsoft.Json;
using System;
using System.Collections.Generic;

namespace LDT.SERVICE.Models
{
  public class CoopSettingItemList
  {
    [JsonProperty("name")]
    public string Name { get; set; }

    [JsonProperty("len")]
    public string Len { get; set; }

    [JsonProperty("col")]
    public string Col { get; set; }

    [JsonProperty("key")]
    public string Key { get; set; }

    [JsonProperty("term")]
    public string Term { get; set; }

    [JsonProperty("type")]
    public string Type { get; set; }

    [JsonProperty("value")]
    public string Value { get; set; }

    [JsonProperty("append")]
    public string Append { get; set; }

    [JsonProperty("detail")]
    public string Detail { get; set; }

    [JsonProperty("messageLen")]
    public string MessageLen { get; set; }

    [JsonProperty("paddingPosition")]
    public string PaddingPosition { get; set; }

    [JsonProperty("paddingFormat")]
    public string PaddingFormat { get; set; }

    [JsonProperty("itemType")]
    public string ItemType { get; set; }

    [JsonProperty("repeat")]
    public string Repeat { get; set; }

    private string _dataSet;

    [JsonProperty("dataSet")]
    public string DataSet
    {
      get
      {
        if (!string.IsNullOrEmpty(Value))
        {
          if (Occ)
          {
          }
          else
          {
            var items = Value.Split(':');
            if (items != null && items?.Length > 1)
            {
              var sqlcode = items[1].Split('.');
              if (sqlcode != null && sqlcode.Length > 1)
              {
                _dataSet = sqlcode[0];
              }
            }
          }
        }
        return _dataSet;
      }
      set => _dataSet = value;
    }

    private string _sqlParam;

    [JsonProperty("sqlParam")]
    public string SqlParam
    {
      get
      {
        if (!string.IsNullOrEmpty(Value))
        {
          if (Occ)
          {
          }
          else
          {
            var items = Value.Split(':');
            if (items != null && items?.Length > 1)
            {
              var sqlParam = items[1].Split('.');
              if (sqlParam != null && sqlParam.Length > 1)
              {
                _sqlParam = sqlParam[1];
              }
            }
          }
        }
        return _sqlParam;
      }
      set => _sqlParam = value;
    }

    [JsonProperty("occ")]
    public bool Occ { get; set; }
  }

  public class DatasetKey
  {
    [JsonProperty("dataKey")]
    public Dictionary<string, string> Datakey { get; set; }
    [JsonProperty("sqlCode")]
    public string SqlCode { get; set; }
  }

  public class CoopExtSetting
  {
    [JsonProperty("key")]
    public Dictionary<string, Dictionary<string, string>> Key { get; set; }
    [JsonProperty("dataset")]
    public List<DatasetKey> Dataset { get; set; }
  }

  public class CoopSetting
  {
    [JsonProperty("name")]
    public string Name { get; set; }

    [JsonProperty("itemList")]
    public List<CoopSettingItemList> ItemList { get; set; }
  }

  public class MstCoopLayoutEntity
  {
    [JsonProperty("regDate")]
    public DateTime? RegDate { get; set; }

    [JsonProperty("upDate")]
    public DateTime? UpDate { get; set; }

    [JsonProperty("ctlNo")]
    public string CtlNo { get; set; }

    [JsonProperty("facilityCd")]
    public string FacilityCd { get; set; }

    [JsonProperty("coopCd")]
    public string CoopCd { get; set; }

    [JsonProperty("direction")]
    public string Direction { get; set; }

    [JsonProperty("coopCdSub")]
    public string CoopCdSub { get; set; }

    [JsonProperty("coopFormat")]
    public string CoopFormat { get; set; }

    [JsonProperty("coopName")]
    public string CoopName { get; set; }

    [JsonProperty("coopVender")]
    public string CoopVender { get; set; }

    [JsonProperty("description")]
    public string Description { get; set; }

    [JsonProperty("isEditable")]
    public string IsEditable { get; set; }

    [JsonProperty("coopSetting")]
    public string CoopSettingString { get; set; }

    [JsonProperty("coopSettingRoot")]
    public CoopSetting CoopSetting { get; set; }

    [JsonProperty("coopExtSetting")]
    public CoopExtSetting CoopExtSetting { get; set; }

    [JsonProperty("isDisp")]
    public string IsDisp { get; set; }

    [JsonProperty("isDel")]
    public string IsDel { get; set; }

    [JsonProperty("userId")]
    public string UserId { get; set; }

    [JsonIgnore]
    public string ValueMember => CtlNo;

    [JsonIgnore]
    public string DisplayMember => string.Join(" - ", new List<string>() { CoopName, CoopCd, CoopCdSub });
  }
}
