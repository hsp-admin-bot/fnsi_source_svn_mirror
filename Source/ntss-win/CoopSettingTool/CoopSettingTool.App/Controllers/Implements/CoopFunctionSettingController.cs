// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="CoopFunctionSettingController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Log;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopFunctionSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFunctionSettingView, CoopSettingTool.App.Models.ICoopFunctionSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopFunctionSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopFunctionSettingView, CoopSettingTool.App.Models.ICoopFunctionSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopFunctionSettingController" />
    public class CoopFunctionSettingController : BaseController<ICoopFunctionSettingView, ICoopFunctionSettingModel>, ICoopFunctionSettingController
    {
        /// <summary>
        /// The MST coop layout service
        /// </summary>
        IMstCoopLayoutService mstCoopLayoutService;

        /// <summary>
        /// The MST coop distribute service
        /// </summary>
        IMstCoopDistributeService mstCoopDistributeService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopFunctionSettingController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopFunctionSettingController(ICoopFunctionSettingView view, ICoopFunctionSettingModel model) : base(view, model)
        {
            mstCoopLayoutService = CompositionRoot.Resolve<IMstCoopLayoutService>();
            mstCoopDistributeService = CompositionRoot.Resolve<IMstCoopDistributeService>();
        }

        /// <summary>
        /// Loads the coop distribute.
        /// </summary>
        public async void LoadCoopDistribute()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                // リクェストを初期化する
                var param = new GetMstCoopDistributeRequest()
                {
                    FacilityCd = this.Model.CoopFacility.FacilityCd,
                    CoopCd = this.Model.CoopFacility.CommonSetting.CoopOrdCds[this.Model.CoopFunctionIndex].CoopCd,

                };

                // APIでMstCoopDistributeを取得する
                var res = mstCoopDistributeService.GetMstCoopDistribute(param).Result;

                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.CoopDistributeList = res.Data.Content.FindAll(x => x.CoopCdIndex == this.Model.CoopFacility.CommonSetting.CoopOrdCds[this.Model.CoopFunctionIndex].CoopCdIndex);
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                // 送信プロトコルを取得する
                if (this.Model.CoopDistributeList == null || this.Model.CoopDistributeList.Count == 0)
                {
                    this.Model.SendProtocol = null;
                }
                else
                {
                    this.Model.SendProtocol = this.Model.CoopDistributeList[0].GetDistributeSetting().ProtocolInfo;
                }

                return true;
            });

            this.View.HideLoading();

            if (!result)
            {
                this.View.CloseView(System.Windows.Forms.DialogResult.Abort);
            }
        }

        /// <summary>
        /// Submits this instance.
        /// </summary>
        public async void Submit()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                OrdCd selectedItem = this.Model.CoopFacility.CommonSetting.CoopOrdCds[this.Model.CoopFunctionIndex];

                // On/Offフラグ
                string isDisp = selectedItem.Enable ? "1" : "0";

                // MstCoopLayoutを取得する
                var param = new GetMstCoopLayoutRequest()
                {
                    FacilityCd = this.Model.CoopFacility.FacilityCd,
                    CoopCd = selectedItem.CoopCd,
                    Direction = selectedItem.Direction
                };

                var res = mstCoopLayoutService.GetMstCoopLayout(param).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    this.Model.CoopLayoutList = res.Data.FindAll(x => x.CoopCdIndex == selectedItem.CoopCdIndex);
                }
                else
                {
                    return false;
                }

                // レイアウトがない場合、終わる
                if(this.Model.CoopLayoutList.Count == 0)
                {
                    this.View.ShowMessage(Resources.WARNING_NO_LAYOUT + "\r\n" + "CoopCdIndex = " + selectedItem.CoopCdIndex, Resources.WARNING, Enums.MessageTypeEnum.WARNING);
                    return true;
                }

                // 受信の場合
                if (selectedItem.Direction == "R")
                {
                    // 受信設定
                    if (selectedItem.Enable && this.Model.WatchInfo != null)
                    {
                        this.Model.IfEgdeSetting.Receive.WatchInfos.RemoveAll(x => x.CoopCdIndex == selectedItem.CoopCdIndex);
                        this.Model.IfEgdeSetting.Receive.WatchInfos.Add(this.Model.WatchInfo);

                        this.Model.CoopFacility.SetIfEdgeSetting(this.Model.IfEgdeSetting);
                    }

                    // リクェストを初期化する
                    MstCoopFacilityEntity mstCoopFacilityEntity = this.Model.CoopFacility;
                    MstCoopDistributeEntity mstCoopDistributeEntity = new MstCoopDistributeEntity();
                    MstCoopLayoutEntity mstCoopLayoutEntityBefore = null;
                    MstCoopLayoutEntity mstCoopLayoutEntityAfter = null;
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        MissingMemberHandling = MissingMemberHandling.Ignore
                    };
                    var request = new SubmitCoopLayoutRequest()
                    {
                        MstCoopDistributeAfter = JsonConvert.SerializeObject(mstCoopDistributeEntity, settings),
                        MstCoopFacilityAfter = JsonConvert.SerializeObject(mstCoopFacilityEntity, settings),
                    };

                    // MstCoopLayoutごと保存する
                    foreach (MstCoopLayoutEntity mstCoopLayout in this.Model.CoopLayoutList)
                    {
                        mstCoopLayoutEntityBefore = mstCoopLayout;
                        mstCoopLayoutEntityAfter = mstCoopLayout.JsonClone();
                        mstCoopLayoutEntityAfter.IsDisp = isDisp;

                        request.MstCoopLayoutBefore = GetMstCoopLayoutParam(mstCoopLayoutEntityBefore);
                        request.MstCoopLayoutAfter = GetMstCoopLayoutParam(mstCoopLayoutEntityAfter);

                        var saveRes = mstCoopLayoutService.CreateOrUpdateMstCoopLayout(request).Result;
                        if (saveRes != null && saveRes.StatusCode == HttpStatusCode.OK)
                        {
                        }
                        else
                        {
                            return false ;
                        }
                    }

                }
                // 送信の場合
                else if (selectedItem.Direction == "S")
                {
                    // 送信設定
                    if (selectedItem.Enable)
                    {
                        if (this.Model.CoopDistributeList.Count > 0)
                        {
                            var distibuteSetting = this.Model.CoopDistributeList[0].GetDistributeSetting();
                            distibuteSetting.ProtocolInfo = this.Model.SendProtocol;
                            this.Model.CoopDistributeList[0].SetDistributeSetting(distibuteSetting);
                        }
                    }

                    // リクェストを初期化する
                    MstCoopFacilityEntity mstCoopFacilityEntity = this.Model.CoopFacility;
                    MstCoopDistributeEntity mstCoopDistributeEntity = new MstCoopDistributeEntity();
                    if (this.Model.CoopDistributeList.Count > 0)
                    {
                        mstCoopDistributeEntity = this.Model.CoopDistributeList[0];
                    }
                    MstCoopLayoutEntity mstCoopLayoutEntityBefore = null;
                    MstCoopLayoutEntity mstCoopLayoutEntityAfter = null;
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        MissingMemberHandling = MissingMemberHandling.Ignore
                    };
                    var request = new SubmitCoopLayoutRequest()
                    {
                        MstCoopDistributeAfter = JsonConvert.SerializeObject(mstCoopDistributeEntity, settings),
                        MstCoopFacilityAfter = JsonConvert.SerializeObject(mstCoopFacilityEntity, settings),
                    };

                    // MstCoopLayoutごと保存する
                    foreach (MstCoopLayoutEntity mstCoopLayout in this.Model.CoopLayoutList)
                    {
                        mstCoopLayoutEntityBefore = mstCoopLayout;
                        mstCoopLayoutEntityAfter = mstCoopLayout.JsonClone();
                        mstCoopLayoutEntityAfter.IsDisp = isDisp;

                        request.MstCoopLayoutBefore = GetMstCoopLayoutParam(mstCoopLayoutEntityBefore);
                        request.MstCoopLayoutAfter = GetMstCoopLayoutParam(mstCoopLayoutEntityAfter);

                        var saveRes = mstCoopLayoutService.CreateOrUpdateMstCoopLayout(request).Result;
                        if (saveRes != null && saveRes.StatusCode == HttpStatusCode.OK)
                        {
                        }
                        else
                        {
                            return false;
                        }
                    }
                }

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
        /// Turns the off coop function.
        /// </summary>
        public void TurnOffCoopFunction()
        {
            this.Model.CoopFacility.CommonSetting.CoopOrdCds[this.Model.CoopFunctionIndex].Enable = false;
        }

        /// <summary>
        /// Turns the on coop function.
        /// </summary>
        public void TurnOnCoopFunction()
        {
            this.Model.CoopFacility.CommonSetting.CoopOrdCds[this.Model.CoopFunctionIndex].Enable = true;
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
            mstCoopLayoutEntity.CoopSetting = null;
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
