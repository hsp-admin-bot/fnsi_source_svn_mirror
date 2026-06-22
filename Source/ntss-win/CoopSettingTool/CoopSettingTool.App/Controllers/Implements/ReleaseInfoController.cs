// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : han Hai Thach
// Created          : 06-14-2021
//
// Last Modified By : han Hai Thach
// Last Modified On : 06-14-2021
// ***********************************************************************
// <copyright file="ReleaseInfoController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class ReleaseInfoController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IReleaseInfoView, CoopSettingTool.App.Models.IReleaseInfoModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IReleaseInfoController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IReleaseInfoView, CoopSettingTool.App.Models.IReleaseInfoModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.IReleaseInfoController" />
    public class ReleaseInfoController : BaseController<IReleaseInfoView, IReleaseInfoModel>, IReleaseInfoController
    {
        /// <summary>
        /// The system release information service
        /// </summary>
        ISysReleaseInfoService sysReleaseInfoService;

        /// <summary>
        /// Initializes a new instance of the <see cref="ReleaseInfoController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public ReleaseInfoController(IReleaseInfoView view, IReleaseInfoModel model) : base(view, model)
        {
            this.sysReleaseInfoService = CompositionRoot.Resolve<ISysReleaseInfoService>();
        }

        /// <summary>
        /// Loads all release information.
        /// </summary>
        public async void LoadAllReleaseInfo()
        {
            this.View.ShowLoading();

            bool result =  await Task.Run(() =>
            {
                var res = sysReleaseInfoService.GetAllSysReleaseInfo().Result;

                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.ReleaseInfos = res.Data;
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }
    }
}
