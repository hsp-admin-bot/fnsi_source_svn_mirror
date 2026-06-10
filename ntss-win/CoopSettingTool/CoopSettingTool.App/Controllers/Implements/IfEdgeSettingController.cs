// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-25-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-27-2021
// ***********************************************************************
// <copyright file="IfEdgeSettingController.cs" company="">
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
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class IfEdgeSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IIfEdgeSettingView, CoopSettingTool.App.Models.IIfEdgeSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IIfEdgeSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IIfEdgeSettingView, CoopSettingTool.App.Models.IIfEdgeSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.IIfEdgeSettingController" />
    public class IfEdgeSettingController : BaseController<IIfEdgeSettingView, IIfEdgeSettingModel>, IIfEdgeSettingController
    {
        /// <summary>
        /// The MST if edge service
        /// </summary>
        IMstIfEdgeService mstIfEdgeService;

        /// <summary>
        /// The MST coop facility service
        /// </summary>
        IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="IfEdgeSettingController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public IfEdgeSettingController(IIfEdgeSettingView view, IIfEdgeSettingModel model) : base(view, model)
        {
            mstIfEdgeService = CompositionRoot.Resolve<IMstIfEdgeService>();
            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
        }

        /// <summary>
        /// Add a new IfEdge
        /// </summary>
        public void AddNewIfEdge()
        {
            this.Model.AddNewIfEdge();
        }

        /// <summary>
        /// Loads if edge list.
        /// </summary>
        public async void LoadIfEdgeList()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                List<MstIfEdgeEntity> lsIfEge = new List<MstIfEdgeEntity>();
                var res = mstIfEdgeService.GetMstIfEdge(this.Model.Facility.FacilityCd).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    lsIfEge = res.Data;
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                if (lsIfEge.Count == 0)
                {
                    lsIfEge.Add(new MstIfEdgeEntity(this.Model.Facility.FacilityCd));
                }

                this.Model.IfEdgeList = lsIfEge;

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
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
                #region MstIfEdgeにコミットする

                foreach (var ifEdge in this.Model.IfEdgeList)
                {
                    if (ifEdge.IsModified && !string.IsNullOrEmpty(ifEdge.SerialNo))
                    {
                        ifEdge.SettingDate = DateTime.Now;
                        var res = mstIfEdgeService.SubmitMstIfEdge(ifEdge).Result;
                        if (res == null || res.StatusCode != HttpStatusCode.OK)
                        {
                            return false;
                        }
                    }
                }

                #endregion

                #region MstCoopFacilityにコミットする

                //MstCoopFacilityEntity coopFacility = null;
                //MstCoopLayoutEntity mstCoopLayoutEntity = null;

                //// リクェストを初期化する
                //var param = new GetMstCoopFacilityRequest()
                //{
                //    FacilityCd = this.Model.Facility.FacilityCd,
                //};

                //// APIでMstCoopFacilityを取得する
                //var res1 = mstCoopFacilityService.GetMstCoopFacility(param).Result;
                //if (res1 != null && res1.StatusCode == HttpStatusCode.OK)
                //{
                //    coopFacility = res1.Data.Content.FirstOrDefault();
                //}
                //else
                //{
                //    return false;
                //}

                //if (coopFacility == null)
                //{
                //    this.View.ShowMessage(Resources.WARNING_COOP_NOT_INSTALLED, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                //}
                //else
                //{
                //    // MstCoopFacilityを変更する
                //    var ifEgdeSetting = coopFacility.GetIfEdgeSetting();
                //    ifEgdeSetting.SerialNo = this.Model.IfEdgeList[0].SerialNo;
                //    ifEgdeSetting.FacilityCd = this.Model.Facility.FacilityCd;
                //    coopFacility.SetIfEdgeSetting(ifEgdeSetting);

                //    // MstCoopFacilityを保存する
                //    var res = mstCoopFacilityService.SubmitMstCoopFacility(coopFacility).Result;
                //    if (res == null || res.StatusCode != HttpStatusCode.OK)
                //    {
                //        return false;
                //    }
                //}

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
        /// Gets the MST coop layout parameter.
        /// </summary>
        /// <param name="mstCoopLayoutEntity">The MST coop layout entity.</param>
        /// <returns>System.String.</returns>
        private string GetMstCoopLayoutParam(MstCoopLayoutEntity mstCoopLayoutEntity)
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            //mstCoopLayoutEntity.CoopSetting = null;
            var s = JsonConvert.SerializeObject(mstCoopLayoutEntity, settings);

            return s;
        }

        /// <summary>
        /// Clears the data.
        /// </summary>
        public override void ClearData()
        {
            this.Model.ClearData();
        }
    }
}
