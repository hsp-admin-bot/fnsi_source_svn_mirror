using LDT.APP.Controllers.Interfaces;
using LDT.APP.Models.Interfaces;
using LDT.APP.Properties;
using LDT.APP.Views.Interfaces;
using LDT.LOG;
using LDT.SERVICE.Enums;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Text;
using System.Threading.Tasks;

namespace LDT.APP.Controllers.Implements
{
  public class SettingController : BaseController<SettingEntity, ISettingView, ISettingModel, ISettingService>, ISettingController
  {
    private IMasterService _masterService;
    private ISysDataSetService _sysDataSetService;
    private IMstCoopDistributeService _mstCoopDistributeService;
    private IMstCoopFacilityService _mstCoopFacilityService;
    private IMstCoopLayoutService _mstCoopLayoutService;
    private IMstCoopLayoutDetailService _mstCoopLayoutDetailService;

    public SettingController(ISettingView view, ISettingModel model, ISettingService service, IMasterService masterService, ISysDataSetService sysDataSetService, IMstCoopDistributeService mstCoopDistributeService, IMstCoopFacilityService mstCoopFacilityService, IMstCoopLayoutService mstCoopLayoutService, IMstCoopLayoutDetailService mstCoopLayoutDetailService) : base(view, model, service)
    {
      _masterService = masterService;
      _sysDataSetService = sysDataSetService;
      _mstCoopDistributeService = mstCoopDistributeService;
      _mstCoopFacilityService = mstCoopFacilityService;
      _mstCoopLayoutService = mstCoopLayoutService;
      _mstCoopLayoutDetailService = mstCoopLayoutDetailService;
    }

    public void LoadProtocolInfo(string direction)
    {
      this.Tview.RunLoading();
      if (direction != null)
      {
        if (DIRECTION.SEND == direction)
        {
          this.Tmodel.ItemInfo.Direction = DIRECTION.SEND;
          var param = new GetByMstCoopDistributeRequest()
          {
            CoopCd = Tmodel.ItemInfo.CoopCd,
            FacilityCd = Tmodel.ItemInfo.FacilityCd
          };
          var res = Task.Run(async () => await _mstCoopDistributeService.GetBy(param).ConfigureAwait(false)).GetAwaiter().GetResult();
          this.Tmodel.SettingModeSendModel = new SettingModeSendModel();
          if (res.StatusCode == System.Net.HttpStatusCode.OK)
          {
            var item = res.Data.Content.FirstOrDefault();
            if (item != default(MstCoopDistributeEntity))
            {
              this.Tmodel.MstCoopDistributeEntityAfter = item.Asssign<MstCoopDistributeEntity, MstCoopDistributeEntity>();
              this.Tmodel.MstCoopDistributeEntityBefore = item.Asssign<MstCoopDistributeEntity, MstCoopDistributeEntity>();
              this.Tview.BindValueProtocolSend(item);
            }
          }
        }
        else
        {
          this.Tmodel.ItemInfo.Direction = DIRECTION.RECEIVE;
          var param = new GetByMstCoopFacilityRequest()
          {
            FacilityCd = Tmodel.ItemInfo.FacilityCd
          };
          var res = Task.Run(async () => await _mstCoopFacilityService.GetBy(param).ConfigureAwait(false)).GetAwaiter().GetResult();
          this.Tmodel.SettingModeReceiveModel = new SettingModeReceiveModel();
          if (res.StatusCode == System.Net.HttpStatusCode.OK)
          {
            var item = res.Data.Content.FirstOrDefault();
            if (item != default(MstCoopFacilityEntity))
            {
              this.Tmodel.MstCoopFacilityEntityAfter = item.Asssign<MstCoopFacilityEntity, MstCoopFacilityEntity>();
              this.Tmodel.MstCoopFacilityEntityBefore = item.Asssign<MstCoopFacilityEntity, MstCoopFacilityEntity>();
              this.Tview.BindValueProtocolReceive(item);
            }
          }
        }
      }
      this.Tview.StopLoading();
    }

    public void LoadCoopCdType()
    {
      this.Tview.RunLoading();
      if (this.Tmodel.CoopCdTypeList.Count == 0)
      {
        var res = this._masterService.LoadCoopCdType();
        this.Tmodel.CoopCdTypeList = res;
      }
      this.Tview.StopLoading();
    }

    public async Task LoadDataSet(bool IsReaload = false)
    {
      var param = new SERVICE.Models.Requests.GetAllSysDataSetRequest();
      var res = await _sysDataSetService.GetAllAsync(param).ConfigureAwait(false);
      List<SysDataSetEntity> Content;
      if (res.StatusCode == System.Net.HttpStatusCode.OK)
      {
        this.Tmodel.ListDataSet = res.Data;
      }
      else
      {
        this.Tmodel.ListDataSet = new List<SysDataSetEntity>();
      }
      Content = this.Tmodel.ListDataSet.Asssign<List<SysDataSetEntity>, List<SysDataSetEntity>>();
      if (IsReaload)
      {
        this.Tview.BindDataDataSet(Content);
      }
      else
      {
        this.Tmodel.ItemInfo.CoopSetting = this.Tmodel.ItemInfo.CoopSetting ?? new CoopSetting();
        this.Tmodel.ListDataSetBackup = Content;
        this.Tview.BindValueGridViewSettingElement(this.Tmodel.ItemInfo.CoopSetting.ItemList, Content);
        this.Tview.HandleEnableAllRowCell();
      }
    }

    public void LoadInfoDataForPage()
    {
      this.Tview.RunLoading();
      this.Tview.InitView();
      this.Tview.StopLoading();
    }

    public void OnCancel()
    {
      this.Tview.IsCancel = true;
      this.Tview.CloseView();
    }

    private void SubmitItem()
    {
      MstCoopLayoutEntity mstCoopLayoutEntityBefore = this.Tmodel.ItemInfoBackup;
      MstCoopLayoutEntity mstCoopLayoutEntityAfter = this.Tmodel.ItemInfo;
      mstCoopLayoutEntityAfter.CoopExtSetting = GetCoopExtSetting();
      mstCoopLayoutEntityAfter.CoopSettingString = GetCoopSetting();
      MstCoopDistributeEntity mstCoopDistributeEntityBefore = this.Tmodel.MstCoopDistributeEntityBefore ?? new MstCoopDistributeEntity();
      MstCoopDistributeEntity mstCoopDistributeEntityAfter = this.Tmodel.MstCoopDistributeEntityAfter ?? new MstCoopDistributeEntity()
      {
      };
      MstCoopFacilityEntity mstCoopFacilityEntityBefore = this.Tmodel.MstCoopFacilityEntityBefore ?? new MstCoopFacilityEntity();
      MstCoopFacilityEntity mstCoopFacilityEntityAfter = this.Tmodel.MstCoopFacilityEntityAfter ?? new MstCoopFacilityEntity();
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var resultSave = Task.Run(
        async () =>
        await this._mstCoopLayoutService.CreateOrUpdateAsync(new CreateOrUpdateCoopLayoutRequest()
        {
          MstCoopDistributeAfter = JsonConvert.SerializeObject(mstCoopDistributeEntityAfter, settings),
          MstCoopFacilityAfter = JsonConvert.SerializeObject(mstCoopFacilityEntityAfter, settings),
          MstCoopLayoutAfter = GetMstCoopLayoutAfterParam(mstCoopLayoutEntityAfter),
          MstCoopLayoutBefore = GetMstCoopLayoutBeforeParam(mstCoopLayoutEntityBefore)
        }).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (resultSave.Data)
      {
        this.Tview.ShowMessage(Resources.DATA_SAVED_SUCCESSFULLY, Resources.INFORMATION, Enums.MessageTypeEnum.INFORMATION);
        this.Tview.OnSubmit(true);
      }
      else
      {
        this.Tview.ShowMessage(Resources.DATA_SAVED_FAILED, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
      }
    }

    private void SubmitOcc()
    {
      MstCoopLayoutDetailEntity mstCoopLayoutDetailEntityBefore = this.Tmodel.MstCoopLayoutDetailEntityBefore; ;
      MstCoopLayoutDetailEntity mstCoopLayoutDetailEntityAfter = new MstCoopLayoutDetailEntity()
      {
        CoopCd = this.Tmodel.ItemInfo.CoopCd,
        CoopName = this.Tmodel.ItemInfo.CoopName,
        Direction = this.Tmodel.ItemInfo.Direction,
        FacilityCd = this.Tmodel.ItemInfo.FacilityCd,
        Description = this.Tmodel.ItemInfo.Description,
        CoopExtSetting = GetCoopExtSetting(),
        CoopSettingString = GetCoopSetting(),
        CoopCdDetail = mstCoopLayoutDetailEntityBefore.CoopCdDetail,
        CoopCdDetailSub = this.Tmodel.MstCoopLayoutEntityRoot.CoopCdSub,
        CtlNo = this.Tmodel.ItemInfo.CtlNo,
        IsDel = this.Tmodel.ItemInfo.IsDel,
        IsDisp = this.Tmodel.ItemInfo.IsDisp,
        IsEditable = this.Tmodel.ItemInfo.IsEditable,
        RegDate = this.Tmodel.ItemInfo.RegDate,
        UpDate = this.Tmodel.ItemInfo.UpDate,
        UserId = this.Tmodel.ItemInfo.UserId
      };
      MstCoopLayoutEntity mstCoopLayoutEntityBefore = this.Tmodel.MstCoopLayoutEntityRoot;
      MstCoopDistributeEntity mstCoopDistributeEntityBefore = this.Tmodel.MstCoopDistributeEntityBefore ?? new MstCoopDistributeEntity();
      MstCoopDistributeEntity mstCoopDistributeEntityAfter = this.Tmodel.MstCoopDistributeEntityAfter ?? new MstCoopDistributeEntity()
      {
      };
      MstCoopFacilityEntity mstCoopFacilityEntityBefore = this.Tmodel.MstCoopFacilityEntityBefore ?? new MstCoopFacilityEntity();
      MstCoopFacilityEntity mstCoopFacilityEntityAfter = this.Tmodel.MstCoopFacilityEntityAfter ?? new MstCoopFacilityEntity();
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var resultSave = Task.Run(
        async () =>
        await this._mstCoopLayoutDetailService.CreateOrUpdateAsync(new CreateOrUpdateMstCoopLayoutDetailRequest()
        {
          MstCoopDistribute = JsonConvert.SerializeObject(mstCoopDistributeEntityAfter, settings),
          MstCoopFacility = JsonConvert.SerializeObject(mstCoopFacilityEntityAfter, settings),
          MstCoopLayoutDetailAfter = GetMstCoopLayoutDetailAfterParam(mstCoopLayoutDetailEntityAfter),
          MstCoopLayoutDetailBefore = GetMstCoopLayoutDetailBeforeParam(mstCoopLayoutDetailEntityBefore),
          MstCoopLayoutBefore = GetMstCoopLayoutBeforeParam(mstCoopLayoutEntityBefore)
        }).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (resultSave.Data)
      {
        this.Tview.ShowMessage(Resources.DATA_SAVED_SUCCESSFULLY, Resources.INFORMATION, Enums.MessageTypeEnum.INFORMATION);
        this.Tview.OnSubmit(true);
      }
      else
      {
        this.Tview.ShowMessage(Resources.DATA_SAVED_FAILED, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
      }
    }

    public void OnSubmit(bool isOcc = false)
    {
      this.Tview.RunLoading();
      LogHelper.LogInfo(nameof(OnSubmit));
      if (isOcc)
      {
        this.SubmitOcc();
      }
      else
      {
        this.SubmitItem();
      }
      this.Tview.StopLoading();
    }

    private string GetMstCoopLayoutDetailAfterParam(MstCoopLayoutDetailEntity mstCoopLayoutDetailEntityAfter)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var mstCoopLayoutAfterString = JsonConvert.SerializeObject(mstCoopLayoutDetailEntityAfter, settings);
      var array = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(mstCoopLayoutAfterString, settings);
      array.Property("coopSettingRoot", System.StringComparison.OrdinalIgnoreCase)?.Remove();
      return array.ToString();
    }

    private string GetMstCoopLayoutDetailBeforeParam(MstCoopLayoutDetailEntity mstCoopLayoutDetailEntityBefore)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var s = JsonConvert.SerializeObject(mstCoopLayoutDetailEntityBefore, settings);
      var array = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(s, settings);
      array.Property("coopSettingRoot", System.StringComparison.OrdinalIgnoreCase)?.Remove();
      return array.ToString();
    }

    private string GetMstCoopLayoutAfterParam(MstCoopLayoutEntity mstCoopLayoutEntityAfter)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var mstCoopLayoutAfterString = JsonConvert.SerializeObject(mstCoopLayoutEntityAfter, settings);
      var array = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(mstCoopLayoutAfterString, settings);
      array.Property("coopSettingRoot", System.StringComparison.OrdinalIgnoreCase)?.Remove();
      return array.ToString();
    }

    private string GetMstCoopLayoutBeforeParam(MstCoopLayoutEntity mstCoopLayoutEntityBefore)
    {
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var s = JsonConvert.SerializeObject(mstCoopLayoutEntityBefore, settings);
      var array = (Newtonsoft.Json.Linq.JObject)JsonConvert.DeserializeObject(s, settings);
      array.Property("coopSettingRoot", System.StringComparison.OrdinalIgnoreCase)?.Remove();
      return array.ToString();
    }

    private CoopExtSetting GetCoopExtSetting()
    {
      List<SubKeyModel> subKeyModels = this.Tmodel.KeyModels;
      subKeyModels = subKeyModels ?? new List<SubKeyModel>();
      CoopExtSetting result = new CoopExtSetting()
      {
        Key = new Dictionary<string, Dictionary<string, string>>(),
        Dataset = new List<DatasetKey>()
      };
      subKeyModels.ForEach(item =>
      {
        result.Key.Add(item.KeyName, item.ValueList.ToDictionary(i => i.KeyName, i => i.Value));
      });
      List<ElementGrid> elementGrids = this.Tmodel.ElementGrids ?? new List<ElementGrid>();
      elementGrids.ForEach(item =>
      {
          if (item.ValueFormat == item.Value)
          {
            result.Dataset.Add(new DatasetKey()
            {
              Datakey = new Dictionary<string, string>()
              {
                {
                  item.SqlParam,
                  item.DatasetValue
                }
              },
              SqlCode = item.DataSet
            }); ;
        }
      });
      return result;
    }

    private string GetCoopSetting()
    {
      List<ElementGrid> elementGrids = this.Tmodel.ElementGrids;
      string rootName = this.Tmodel.ItemInfo.CoopSetting.Name;
      elementGrids = elementGrids ?? new List<ElementGrid>();
      CoopSetting resultOb = new CoopSetting()
      {
        Name = rootName,
        ItemList = new List<CoopSettingItemList>()
      };
      resultOb.ItemList.AddRange(elementGrids.Select(item => new CoopSettingItemList()
      {
        Append = item.Append,
        Col = item.Col,
        DataSet = item.DataSet,
        Detail = item.Detail,
        ItemType = item.ItemType,
        Key = item.Key,
        Len = item.Len,
        MessageLen = item.MessageLen,
        Name = item.Name,
        PaddingFormat = item.PaddingFormat,
        PaddingPosition = item.PaddingPosition,
        Repeat = item.Repeat,
        SqlParam = item.SqlParam,
        Term = item.Term,
        Type = item.Type,
        Value = item.Value
      }));
      StringBuilder result = new StringBuilder();
      result.Append($"<root name=\"{resultOb.Name}\">\n");
      resultOb.ItemList.ForEach(
        item =>
        {
          result.Append($"<{item.ItemType}");
          if (!string.IsNullOrEmpty(item.Append))
          {
            result.Append($" append=\"{item.Append.ToLower()}\"");
          }
          if (!string.IsNullOrEmpty(item.Col))
          {
            result.Append($" col=\"{item.Col}\"");
          }
          if (!string.IsNullOrEmpty(item.Detail))
          {
            result.Append($" detail=\"{item.Detail}\"");
          }
          if (!string.IsNullOrEmpty(item.Key))
          {
            result.Append($" key=\"{item.Key}\"");
          }
          if (!string.IsNullOrEmpty(item.Len))
          {
            result.Append($" len=\"{item.Len}\"");
          }
          if (!string.IsNullOrEmpty(item.MessageLen))
          {
            result.Append($" messageLen=\"{item.MessageLen.ToLower()}\"");
          }
          if (!string.IsNullOrEmpty(item.Name))
          {
            result.Append($" name=\"{item.Name}\"");
          }
          if (!string.IsNullOrEmpty(item.PaddingFormat))
          {
            result.Append($" padding_format=\"{item.PaddingFormat}\"");
          }
          if (!string.IsNullOrEmpty(item.PaddingPosition))
          {
            result.Append($" padding_position=\"{item.PaddingPosition}\"");
          }
          if (!string.IsNullOrEmpty(item.Repeat))
          {
            result.Append($" repeat=\"{item.Repeat}\"");
          }
          if (!string.IsNullOrEmpty(item.SqlParam))
          {
            result.Append($" sqlParam=\"{item.SqlParam}\"");
          }
          if (!string.IsNullOrEmpty(item.Term))
          {
            result.Append($" term=\"{item.Term.ToLower()}\"");
          }
          if (!string.IsNullOrEmpty(item.Type))
          {
            result.Append($" type=\"{item.Type}\"");
          }
          if (!string.IsNullOrEmpty(item.Value))
          {
            result.Append($" value=\"{item.Value}\"");
          }
          result.Append($" />\n");
        }
        );
      result.Append("</root>");
      return result.ToString();
    }

    public void LoadMstCoopLayoutByItem(string coopCdSub)
    {
      this.Tview.RunLoading();
      var param = new GetAllByFilterAsyncRequest()
      {
        CoopCdSub = coopCdSub,
        FacilityCd = this.Tmodel.MstCoopLayoutEntityRoot.FacilityCd,
        CoopCd = this.Tmodel.MstCoopLayoutEntityRoot.CoopCd,
        Direction = this.Tmodel.MstCoopLayoutEntityRoot.Direction
      };
      var res = Task.Run(async () => await _mstCoopLayoutService.GetAllByFilterAsync(param).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (res != null && res.StatusCode == HttpStatusCode.OK)
      {
        MstCoopLayoutEntity entity = res.Data.FirstOrDefault();
        if (entity is default(MstCoopLayoutEntity))
        {
          this.Tview.ShowMessage(Resources.NOT_FOUND_BY_KEY, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
        }
        else
        {
          this.Tview.SetMstCoopLayoutEntity(entity);
        }
      }
      this.Tview.StopLoading();
    }

    public void LoadMstCoopLayoutByOcc(string name)
    {
      this.Tview.RunLoading();
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      var param = new GetByMstCoopLayoutDetailRequest()
      {
        CoopCd = this.Tmodel.MstCoopLayoutEntityRoot.CoopCd,
        CoopCdDetail = name,
        CoopDetailSub = this.Tmodel.MstCoopLayoutEntityRoot.CoopCdSub,
        Direction = this.Tmodel.MstCoopLayoutEntityRoot.Direction,
        FacilityCd = this.Tmodel.MstCoopLayoutEntityRoot.FacilityCd
      };
      var res = Task.Run(async () => await _mstCoopLayoutDetailService.GetBy(param).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (res != null && res.StatusCode == HttpStatusCode.OK)
      {
        if (res.Data is null || res.Data is default(MstCoopLayoutDetailEntity))
        {
          this.Tview.ShowMessage(Resources.NOT_FOUND_BY_KEY, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
        }
        else
        {
          this.Tmodel.MstCoopLayoutDetailEntityBefore = res.Data?.Asssign<MstCoopLayoutDetailEntity, MstCoopLayoutDetailEntity>();
          this.Tmodel.MstCoopLayoutDetailEntityAfter = res.Data?.Asssign<MstCoopLayoutDetailEntity, MstCoopLayoutDetailEntity>();
          this.Tview.SetMstCoopLayoutDetailEntity(res.Data);
        }
      }
      this.Tview.StopLoading();
    }

    public void LoadMstCoopLayoutByRoot()
    {
      this.Tview.SetMstCoopLayoutEntity(this.Tmodel.MstCoopLayoutEntityRoot);
    }

    public void RefreshDisplayData()
    {
    }
  }
}
