using LDT.SERVICE.Models;
using System.Collections.Generic;

namespace LDT.APP.Models.Interfaces
{
  public class ElementGrid
  {
    public string Name { get; set; }
    public string Len { get; set; }
    public string Type { get; set; }
    public string ItemType { get; set; }
    public string Key { get; set; }
    public string Col { get; set; }
    public string Repeat { get; set; }
    public string Detail { get; set; }
    public string DataSet { get; set; }
    public string SqlParam { get; set; }
    public string Term { get; set; }
    public string Value { get; set; }
    public string Append { get; set; }
    public string MessageLen { get; set; }
    public string PaddingPosition { get; set; }
    public string PaddingFormat { get; set; }
    public string ValueFormat
    {
      get
      {
        return $"dataset:{DataSet}.{SqlParam}";
      }
    }
    public string DatasetValue
    {
      get
      {
        return $"{DataSet}.{SqlParam}";
      }
    }
  }

  public interface ISettingModel : IBaseModel
  {
    MstCoopLayoutEntity MstCoopLayoutEntityRoot { get; set; }
    List<CoopCdTypeModel> CoopCdTypeList { get; set; }
    MstCoopLayoutEntity ItemInfo { get; set; }
    List<SysDataSetEntity> ListDataSet { get; set; }
    SettingModeReceiveModel SettingModeReceiveModel { get; set; }
    SettingModeSendModel SettingModeSendModel { get; set; }
    MstCoopLayoutEntity ItemInfoBackup { get; set; }
    List<SysDataSetEntity> ListDataSetBackup { get; set; }
    List<ElementGrid> ElementGrids { get; set; }
    List<SubKeyModel> KeyModels { get; set; }
    MstCoopFacilityEntity MstCoopFacilityEntityBefore { get; set; }
    MstCoopDistributeEntity MstCoopDistributeEntityBefore { get; set; }
    MstCoopFacilityEntity MstCoopFacilityEntityAfter { get; set; }
    MstCoopDistributeEntity MstCoopDistributeEntityAfter { get; set; }
    MstCoopLayoutDetailEntity MstCoopLayoutDetailEntityAfter { get; set; }
    MstCoopLayoutDetailEntity MstCoopLayoutDetailEntityBefore { get; set; }
  }
}
