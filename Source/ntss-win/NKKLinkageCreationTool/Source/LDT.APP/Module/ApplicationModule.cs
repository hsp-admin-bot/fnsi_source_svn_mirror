using LDT.APP.Models;
using LDT.APP.Models.Implements;
using LDT.APP.Models.Interfaces;
using LDT.APP.Views;
using LDT.APP.Views.implements;
using LDT.APP.Views.Implements;
using LDT.APP.Views.interfaces;
using LDT.APP.Views.Interfaces;
using LDT.SERVICE.Implements;
using LDT.SERVICE.Interfaces;
using Ninject.Modules;

namespace LDT.APP.Module
{
  public class ApplicationModule : NinjectModule
  {
    public override void Load()
    {
      this.BindService();
      this.BindModel();
      this.BindView();
    }

    private void BindService()
    {
      Bind(typeof(IBaseService<>)).To(typeof(BaseService<>));
      Bind(typeof(IUserService)).To(typeof(UserService));
      Bind(typeof(IMstCoopLayoutService)).To(typeof(MstCoopLayoutService));
      Bind(typeof(ISettingService)).To(typeof(SettingService));
      Bind(typeof(IMasterService)).To(typeof(MasterService));
      Bind(typeof(ISysDataSetService)).To(typeof(SysDataSetService));
      Bind(typeof(IMstCoopDistributeService)).To(typeof(MstCoopDistributeService));
      Bind(typeof(IMstCoopFacilityService)).To(typeof(MstCoopFacilityService));
      Bind(typeof(IMstCoopLayoutDetailService)).To(typeof(MstCoopLayoutDetailService));
      Bind(typeof(IMstFacilityService)).To(typeof(MstFacilityService));
    }

    private void BindView()
    {
      Bind(typeof(IBaseView)).To(typeof(BaseView));
      Bind(typeof(ILoginView)).To(typeof(LoginView));
      Bind(typeof(ISettingView)).To(typeof(SettingView));
      Bind(typeof(IFacilityView)).To(typeof(FacilityView));
    }

    private void BindModel()
    {
      Bind(typeof(IBaseModel)).To(typeof(BaseModel));
      Bind(typeof(ILoginModel)).To(typeof(LoginModel));
      Bind(typeof(ISettingModel)).To(typeof(SettingModel));
      Bind(typeof(IFacilityModel)).To(typeof(FacilityModel));
    }
  }
}
