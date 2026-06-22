// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-13-2022
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-13-2022
// ***********************************************************************
// <copyright file="CoopLayoutSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************

using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Models;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Dynamic;
using System.Net;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{

    /// <summary>
    /// Class CoopLayoutSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopLayoutSettingView, CoopSettingTool.App.Models.ICoopLayoutSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopLayoutSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopLayoutSettingView, CoopSettingTool.App.Models.ICoopLayoutSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopLayoutSettingController" />
    public class CoopLayoutSettingController : BaseController<ICoopLayoutSettingView, ICoopLayoutSettingModel>, ICoopLayoutSettingController
    {
        /// <summary>
        /// The MST coop layout service
        /// </summary>
        IMstCoopLayoutService mstCoopLayoutService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopLayoutSettingController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopLayoutSettingController(ICoopLayoutSettingView view, ICoopLayoutSettingModel model) : base(view, model)
        {
            mstCoopLayoutService = CompositionRoot.Resolve<IMstCoopLayoutService>();
        }

        /// <summary>
        /// Loads the coop layouts.
        /// </summary>
        public async void LoadCoopLayouts()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                bool ret = true;
                // APIでMstCoopDistributeを取得する
                var res = mstCoopLayoutService.GetNewestMstCoopLayoutCtlNoList(this.Model.Facility.FacilityCd).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    List<MstCoopLayoutEntity> mstCoopLayoutEntities = new List<MstCoopLayoutEntity>();
                    StringBuilder sb = new StringBuilder();
                    foreach (string ctlNo in res.Data)
                    {
                        var res1 = mstCoopLayoutService.GetMstCoopLayoutByCtlNo(ctlNo).Result;
                        if (res1 != null && res1.StatusCode == HttpStatusCode.OK)
                        {
                            mstCoopLayoutEntities.Add(res1.Data);
                        }
                        else
                        {
                            sb.Append(ctlNo + " ");
                        }
                    }

                    if(sb.Length > 0)
                    {
                        this.View.ShowMessage(Resources.WARNING_SOME_DATA_CANNOT_GET + sb.ToString(), Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                    }

                    this.Model.CoopLayouts = mstCoopLayoutEntities;
                }
                else
                {
                    ret = false;
                }

                return ret;
            });

            this.View.HideLoading();

            if (!result)
            {
                if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                {
                    this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
                }
            }
        }

        /// <summary>
        /// Saves this instance.
        /// </summary>
        public async void Save()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                #region MstCoopFacilityにコミットする

                // MstCoopLayoutを保存する
                foreach (MstCoopLayoutEntity layout in this.Model.CoopLayouts)
                {
                    if (layout.IsModified)
                    {
                        var res = mstCoopLayoutService.CreateOrUpdateMstCoopLayout(layout).Result;
                        if (res == null || res.StatusCode != HttpStatusCode.OK)
                        {
                            return false;
                        }
                    }
                }
                #endregion

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                if (this.View.ShowAskMessage(Resources.ERROR_DATA_SAVE + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                {
                    this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
                }
            }
            else
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.OK);
            }
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            this.Model.ClearData();
        }

        /// <summary>
        /// Sorts by the specified sort field.
        /// </summary>
        /// <param name="sortField">The sort field.</param>
        /// <param name="isReverse">if set to <c>true</c> [is reverse].</param>
        public void Sort(string sortField, bool isReverse)
        {
            // ソートする
            if (!isReverse)
                this.Model.CoopLayouts = this.Model.CoopLayouts.OrderBy(sortField).ToList();
            else
                this.Model.CoopLayouts = this.Model.CoopLayouts.OrderBy(sortField).Reverse().ToList();
        }
    }
}
