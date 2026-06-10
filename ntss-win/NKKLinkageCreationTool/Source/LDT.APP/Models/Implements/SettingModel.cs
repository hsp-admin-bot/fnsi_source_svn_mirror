using LDT.APP.Models.Interfaces;
using LDT.SERVICE.Models;
using System.Collections.Generic;

namespace LDT.APP.Models.Implements
{
  public class SettingModel : BaseModel, ISettingModel
  {
    private List<CoopCdTypeModel> _coopCdTypeList;
    public List<CoopCdTypeModel> CoopCdTypeList { get => _coopCdTypeList ?? new List<CoopCdTypeModel>(); set => _coopCdTypeList = value; }
    private MstCoopLayoutEntity _itemInfo;
    public MstCoopLayoutEntity ItemInfo { get => _itemInfo; set => _itemInfo = value; }
    private List<SysDataSetEntity> _listDataSet;
    public List<SysDataSetEntity> ListDataSet { get => _listDataSet; set => _listDataSet = value; }
    private SettingModeReceiveModel _settingModeReceiveModel;
    public SettingModeReceiveModel SettingModeReceiveModel { get => _settingModeReceiveModel; set => _settingModeReceiveModel = value; }
    private SettingModeSendModel _settingModeSendModel;
    public SettingModeSendModel SettingModeSendModel { get => _settingModeSendModel; set => _settingModeSendModel = value; }
    private MstCoopLayoutEntity _itemListBackup;
    public MstCoopLayoutEntity ItemInfoBackup { get => _itemListBackup; set => _itemListBackup = value; }
    private List<SysDataSetEntity> _istDataSetBackup;
    public List<SysDataSetEntity> ListDataSetBackup { get => _istDataSetBackup; set => _istDataSetBackup = value; }
    private List<ElementGrid> _elementGrids;
    public List<ElementGrid> ElementGrids { get => _elementGrids ?? new List<ElementGrid>(); set => _elementGrids = value; }
    private List<SubKeyModel> _keyModels;
    public List<SubKeyModel> KeyModels { get => _keyModels; set => _keyModels = value; }
    private MstCoopFacilityEntity _mstCoopFacilityEntityBefore;
    public MstCoopFacilityEntity MstCoopFacilityEntityBefore { get => _mstCoopFacilityEntityBefore; set => _mstCoopFacilityEntityBefore = value; }
    private MstCoopDistributeEntity _mstCoopDistributeEntityBefore;
    public MstCoopDistributeEntity MstCoopDistributeEntityBefore { get => _mstCoopDistributeEntityBefore; set => _mstCoopDistributeEntityBefore = value; }
    private MstCoopFacilityEntity _mstCoopFacilityEntityAfter;

    public MstCoopFacilityEntity MstCoopFacilityEntityAfter
    {
      get => _mstCoopFacilityEntityAfter; set => _mstCoopFacilityEntityAfter
= value;
    }

    private MstCoopDistributeEntity _mstCoopDistributeEntityAfter;
    public MstCoopDistributeEntity MstCoopDistributeEntityAfter { get => _mstCoopDistributeEntityAfter; set => _mstCoopDistributeEntityAfter = value; }
    private MstCoopLayoutEntity _mstCoopLayoutEntityRoot;
    public MstCoopLayoutEntity MstCoopLayoutEntityRoot { get => _mstCoopLayoutEntityRoot; set => _mstCoopLayoutEntityRoot = value; }
    private MstCoopLayoutDetailEntity _mstCoopLayoutDetailEntityAfter;
    public MstCoopLayoutDetailEntity MstCoopLayoutDetailEntityAfter { get => _mstCoopLayoutDetailEntityAfter; set => _mstCoopLayoutDetailEntityAfter = value; }
    private MstCoopLayoutDetailEntity _mstCoopLayoutDetailEntityBefore;
    public MstCoopLayoutDetailEntity MstCoopLayoutDetailEntityBefore { get => _mstCoopLayoutDetailEntityBefore; set => _mstCoopLayoutDetailEntityBefore = value; }
  }
}
