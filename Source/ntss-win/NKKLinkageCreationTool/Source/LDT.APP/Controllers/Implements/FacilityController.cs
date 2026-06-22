using LDT.APP.Controllers.Interfaces;
using LDT.APP.DI;
using LDT.APP.Models.Interfaces;
using LDT.APP.Properties;
using LDT.APP.Views.Implements;
using LDT.APP.Views.Interfaces;
using LDT.LOG;
using LDT.SERVICE.Configuration;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models;
using LDT.SERVICE.Models.Requests;
using System.Net;
using System.Threading.Tasks;

namespace LDT.APP.Controllers.Implements
{
  public class FacilityController : BaseController<MstFacilityEntity, IFacilityView, IFacilityModel, IMstFacilityService>, IFacilityController
  {
    private IMstCoopLayoutService _mstCoopLayoutService;

    public FacilityController(IFacilityView view, IFacilityModel model, IMstFacilityService service, IMstCoopLayoutService mstCoopLayoutService) : base(view, model, service)
    {
      _mstCoopLayoutService = mstCoopLayoutService;
    }

    public void OnCancel()
    {
      this.Tview.IsCancel = true;
      this.Tview.CloseView();
    }

    public void LoadCoopLayoutByFacilityInfo(MstFacilityEntity coopLayoutEntity)
    {
      this.Tview.RunLoading();
      var param = new SERVICE.Models.Requests.GetAllByFilterAsyncRequest()
      {
        CoopCdSub = AppSettingConfig.ApplicationConfigJSON.CONSTANT.COOP_SUB_CD_QUERIES,
        FacilityCd = coopLayoutEntity?.FacilityCd
      };
      var res = Task.Run(async () => await _mstCoopLayoutService.GetAllByFilterAsync(param).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (res != null && res.StatusCode == HttpStatusCode.OK)
      {
        this.Tview.LoadDataCoopLayout(res.Data);
      }
      this.Tview.StopLoading();
    }

    public void LoadFacilityData()
    {
      this.Tview.RunLoading();
      var param = new GetAllFacilityRequest();
      var res = Task.Run(async () => await Tservice.GetAllFacility(param).ConfigureAwait(false)).GetAwaiter().GetResult();
      if (res != null && res.StatusCode == HttpStatusCode.OK)
      {
        this.Tview.InitDataInCombobox(res.Data);
      }
      else
      {
        this.Tview.ShowMessage(Resources.GET_FACILITY_LIST_FAILED, Resources.ERROR, Enums.MessageTypeEnum.ERROR);
      }
      this.Tview.StopLoading();
    }

    public void OnUpdate()
    {
      LogHelper.LogInfo(nameof(OnUpdate));
      this.Tview.RunLoading();
      var settingView = CompositionRoot.Resolve<ISettingView>() as SettingView;
      settingView.MstCoopLayoutEntity = this.Tmodel.MstCoopLayoutSelected?.Asssign<MstCoopLayoutEntity, MstCoopLayoutEntity>();
      settingView.MstCoopLayoutEntityBackup = this.Tmodel.MstCoopLayoutSelected?.Asssign<MstCoopLayoutEntity, MstCoopLayoutEntity>();
      settingView.SetMstCoopLayoutEntityRoot(this.Tmodel.MstCoopLayoutSelected?.Asssign<MstCoopLayoutEntity, MstCoopLayoutEntity>());
      this.Tview.StopLoading();
      this.Tview.HideView();
      var settingViewFrom = settingView.ShowView();
      this.Tview.HandleNextView(settingViewFrom);
      this.Tview.StopLoading();
    }

    public void OnAddNew()
    {
      LogHelper.LogInfo(nameof(OnAddNew));
      this.OnUpdate();
    }

    public void OnCopy()
    {
      LogHelper.LogInfo(nameof(OnCopy));
      this.OnUpdate();
    }
  }
}
