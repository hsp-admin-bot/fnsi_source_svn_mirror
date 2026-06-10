// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="ApplicationModule.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.Controllers;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using Ninject.Modules;

namespace CoopSettingTool.App.Module
{
    /// <summary>
    /// Class ApplicationModule.
    /// Implements the <see cref="Ninject.Modules.NinjectModule" />
    /// </summary>
    /// <seealso cref="Ninject.Modules.NinjectModule" />
    public class ApplicationModule : NinjectModule
    {
        /// <summary>
        /// Loads the module into the kernel.
        /// </summary>
        public override void Load()
        {
            this.BindService();
            this.BindModel();
            this.BindView();
            //Bind(typeof(ILoginController)).To(typeof(LoginController));
        }

        /// <summary>
        /// Binds the service.
        /// </summary>
        private void BindService()
        {
            Bind(typeof(IBaseService<>)).To(typeof(BaseService<>));
            Bind(typeof(IMstFacilityService)).To(typeof(MstFacilityService));
            Bind(typeof(IMstCoopFacilityService)).To(typeof(MstCoopFacilityService));
            Bind(typeof(IMstCoopLayoutService)).To(typeof(MstCoopLayoutService));
            Bind(typeof(IMstCoopDistributeService)).To(typeof(MstCoopDistributeService));
            Bind(typeof(ISysCoopNoService)).To(typeof(SysCoopNoService));
            Bind(typeof(IMstIfEdgeService)).To(typeof(MstIfEdgeService));
            Bind(typeof(IMstCoopIniService)).To(typeof(MstCoopIniService));
            Bind(typeof(ISysReleaseInfoService)).To(typeof(SysReleaseInfoService));
            Bind(typeof(IMstCoopApilinkService)).To(typeof(MstCoopApilinkService));
            Bind(typeof(IMstCoopFilenameService)).To(typeof(MstCoopFilenameService));
        }

        /// <summary>
        /// Binds the view.
        /// </summary>
        private void BindView()
        {
            Bind(typeof(IBaseView)).To(typeof(BaseView));
            Bind(typeof(ILoginView)).To(typeof(LoginView));
            Bind(typeof(IMainMenuView)).To(typeof(MainMenuView));
            Bind(typeof(ISelectFacilityView)).To(typeof(SelectFacilityView));
            Bind(typeof(ICoopInstallView)).To(typeof(CoopInstallView));
            Bind(typeof(ICoopFacilitySettingView)).To(typeof(CoopFacilitySettingView));
            Bind(typeof(ICoopDistributeSettingView)).To(typeof(CoopDistributeSettingView));
            Bind(typeof(ICoopLayoutSettingView)).To(typeof(CoopLayoutSettingView));
            Bind(typeof(ICoopLayoutDetailSettingView)).To(typeof(CoopLayoutDetailSettingView));
            //Bind(typeof(ICoopFunctionListView)).To(typeof(CoopFunctionListView));
            //Bind(typeof(ICoopFunctionSettingView)).To(typeof(CoopFunctionSettingView));
            Bind(typeof(IOrderNumberSettingView)).To(typeof(OrderNumberSettingView));
            Bind(typeof(IIfEdgeSettingView)).To(typeof(IfEdgeSettingView));
            Bind(typeof(ICoopSettingView)).To(typeof(CoopSettingView));
            Bind(typeof(IReleaseInfoView)).To(typeof(ReleaseInfoView));
        }

        /// <summary>
        /// Binds the model.
        /// </summary>
        private void BindModel()
        {
            Bind(typeof(IBaseModel)).To(typeof(BaseModel));
            Bind(typeof(ILoginModel)).To(typeof(LoginModel));
            Bind(typeof(IMainMenuModel)).To(typeof(MainMenuModel));
            Bind(typeof(ISelectFacilityModel)).To(typeof(SelectFacilityModel));
            Bind(typeof(ICoopInstallModel)).To(typeof(CoopInstallModel));
            Bind(typeof(ICoopFacilitySettingModel)).To(typeof(CoopFacilitySettingModel));
            Bind(typeof(ICoopDistributeSettingModel)).To(typeof(CoopDistributeSettingModel));
            Bind(typeof(ICoopLayoutSettingModel)).To(typeof(CoopLayoutSettingModel));
            Bind(typeof(ICoopLayoutDetailSettingModel)).To(typeof(CoopLayoutDetailSettingModel));
            //Bind(typeof(ICoopFunctionListModel)).To(typeof(CoopFunctionListModel));
            //Bind(typeof(ICoopFunctionSettingModel)).To(typeof(CoopFunctionSettingModel));
            Bind(typeof(IOrderNumberSettingModel)).To(typeof(OrderNumberSettingModel));
            Bind(typeof(IIfEdgeSettingModel)).To(typeof(IfEdgeSettingModel));
            Bind(typeof(ICoopSettingModel)).To(typeof(CoopSettingModel));
            Bind(typeof(IReleaseInfoModel)).To(typeof(ReleaseInfoModel));
        }
    }
}
