// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-24-2021
// ***********************************************************************
// <copyright file="CoopInstallController.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.App.DI;
using CoopSettingTool.App.Models;
using CoopSettingTool.App.Properties;
using CoopSettingTool.App.Views;
using CoopSettingTool.Service;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Threading.Tasks;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class CoopInstallController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopInstallView, CoopSettingTool.App.Models.ICoopInstallModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.ICoopInstallController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.ICoopInstallView, CoopSettingTool.App.Models.ICoopInstallModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.ICoopInstallController" />
    public class CoopInstallController : BaseController<ICoopInstallView, ICoopInstallModel>, ICoopInstallController
    {
        /// <summary>
        /// The MST coop facility service
        /// </summary>
        IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// The MST coop layout service
        /// </summary>
        IMstCoopLayoutService mstCoopLayoutService;

        /// <summary>
        /// The MST coop distribute service
        /// </summary>
        IMstCoopDistributeService mstCoopDistributeService;

        /// <summary>
        /// The MST coop filename service
        /// </summary>
        IMstCoopFilenameService mstCoopFilenameService;

        /// <summary>
        /// The MST coop apilink service
        /// </summary>
        IMstCoopApilinkService mstCoopApilinkService;

        /// <summary>
        /// The MST coop ini service
        /// </summary>
        IMstCoopIniService mstCoopIniService;

        /// <summary>
        /// The system coop no service
        /// </summary>
        ISysCoopNoService sysCoopNoService;

        /// <summary>
        /// Initializes a new instance of the <see cref="CoopInstallController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public CoopInstallController(ICoopInstallView view, ICoopInstallModel model) : base(view, model)
        {
            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
            mstCoopLayoutService = CompositionRoot.Resolve<IMstCoopLayoutService>();
            mstCoopDistributeService = CompositionRoot.Resolve<IMstCoopDistributeService>();
            mstCoopFilenameService = CompositionRoot.Resolve<IMstCoopFilenameService>();
            mstCoopApilinkService = CompositionRoot.Resolve<IMstCoopApilinkService>();
            mstCoopIniService = CompositionRoot.Resolve<IMstCoopIniService>();
            sysCoopNoService = CompositionRoot.Resolve<ISysCoopNoService>();
        }

        /// <summary>
        /// Loads the coop facility artifacts data.
        /// </summary>
        public async void LoadCoopFacilityArtifactsData(bool showOtherCopFac)
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                // APIで全てのMstCoopFacilityを取得する
                var res = mstCoopFacilityService.GetNewestMstCoopFacilityCtlNoList().Result;

                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    List<MstCoopFacilityEntity> lstMstCoopFacilityEntity = new List<MstCoopFacilityEntity>();
                    foreach (string ctlNo in res.Data)
                    {
                        if (showOtherCopFac || ctlNo[0] == '-')
                        {
                            var param = new GetMstCoopFacilityRequest()
                            {
                                CtlNo = ctlNo,
                            };

                            var res1 = mstCoopFacilityService.GetMstCoopFacility(param).Result;
                            if (res1 != null && res1.StatusCode == HttpStatusCode.OK && res1.Data.Content.Count > 0)
                            {
                                lstMstCoopFacilityEntity.Add(res1.Data.Content[0]);
                            }
                        }

                    }
                    // Description昇順でソート（画面表示の改善）
                    this.Model.CoopFacilityArtifacts = lstMstCoopFacilityEntity.OrderBy(x => x.Description).ToList();
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

        /// <summary>
        /// Saves the data.
        /// </summary>
        public async void SaveData()
        {
            this.View.ShowLoading();
            bool ret = await Task.Run(() =>
            {
                // 変数を初期化する
                MstCoopFacilityEntity mstCoopFacilityEntity = null;
                MstCoopIniEntity mstCoopIniEntity = null;
                List<CoopIniInfo> coopIniInfos = new List<CoopIniInfo>();

                List<MstCoopLayoutEntity> mstCoopLayoutEntities = new List<MstCoopLayoutEntity>();
                List<MstCoopLayoutDetailEntity> mstCoopLayoutDetailEntities = new List<MstCoopLayoutDetailEntity>();
                List<MstCoopDistributeEntity> mstCoopDistributeEntities = new List<MstCoopDistributeEntity>();
                List<MstCoopFilenameEntity> mstCoopFilenameEntities = new List<MstCoopFilenameEntity>();
                List<MstCoopApilinkEntity> mstCoopApilinkEntities = new List<MstCoopApilinkEntity>();
                List<SysCoopNoEntity> sysCoopNoEntities = new List<SysCoopNoEntity>();
                Dictionary<string, List<MstCoopDistributeEntity>> dicDistribute = new Dictionary<string, List<MstCoopDistributeEntity>>();

                //-----------------------------------------------------------------------------------
                // APIからデータを取得する
                //-----------------------------------------------------------------------------------

                #region 現在のMstCoopFacilityを取得する

                // MstCoopFacilityを取得する
                var getCoopFacilityRq = new GetMstCoopFacilityRequest()
                {
                    FacilityCd = this.Model.Facility.FacilityCd
                };
                var getCoopFacilityRs = mstCoopFacilityService.GetMstCoopFacility(getCoopFacilityRq).Result;
                if (getCoopFacilityRs != null && getCoopFacilityRs.StatusCode == HttpStatusCode.OK)
                {
                    mstCoopFacilityEntity = getCoopFacilityRs.Data.Content.FirstOrDefault();
                }
                else
                {
                    return false;
                }

                //  MstCoopFacilityが存在する場合、現在の設定を取得する
                if (mstCoopFacilityEntity != null)
                {
                    // MstCoopApilinkを取得する
                    var getApilinkRs = mstCoopApilinkService.GetMstCoopApilink(this.Model.Facility.FacilityCd).Result;
                    if (getApilinkRs != null && getApilinkRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var apilink in getApilinkRs.Data)
                        {
                            mstCoopApilinkEntities.Add(apilink);
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopIniを取得する
                    var getCoopIniRs = mstCoopIniService.GetMstCoopIni(this.Model.Facility.FacilityCd).Result;
                    if (getCoopIniRs != null && getCoopIniRs.StatusCode == HttpStatusCode.OK)
                    {
                        mstCoopIniEntity = getCoopIniRs.Data.FirstOrDefault();

                        if (mstCoopIniEntity != null)
                        {
                            coopIniInfos = mstCoopIniEntity.GetCoopIniInfos();
                        }
                    }
                    else
                    {
                        return false;
                    }
                }

                #endregion

                #region インストールする連携設定を取得する

                for (int i = 0; i < this.Model.SelectedArtifactIndices.Count; i++)
                {
                    // MstCoopFacility
                    if (i == 0 && mstCoopFacilityEntity == null)
                    {
                        // MstCoopFacilityを作成する
                        mstCoopFacilityEntity = this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].JsonClone();
                        mstCoopFacilityEntity.CtlNo = null;
                        mstCoopFacilityEntity.FacilityCd = this.Model.Facility.FacilityCd;
                        mstCoopFacilityEntity.Description = this.Model.Facility.FacilityCd;
                        mstCoopFacilityEntity.UserId = ServerAccess.GetInstance().UserNo.ToString();
                    }
                    else
                    {
                        mstCoopFacilityEntity.CommonSettingObject = this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].CommonSettingObject.JsonClone();
                        mstCoopFacilityEntity.IfEdgeSetting = this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].IfEdgeSetting;
                    }

                    // MstCoopDistributeを取得する
                    var getDistCtlRs = mstCoopDistributeService.GetNewestMstCoopDistributeCtlNoList(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getDistCtlRs != null && getDistCtlRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (string ctlNo in getDistCtlRs.Data)
                        {
                            var getDistRs = mstCoopDistributeService.GetMstCoopDistributeByCtlNo(ctlNo).Result;
                            if (getDistRs != null && getDistRs.StatusCode == HttpStatusCode.OK)
                            {
                                mstCoopDistributeEntities.Add(getDistRs.Data);
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopLayoutListを取得する
                    var getLayoutCtlRs = mstCoopLayoutService.GetNewestMstCoopLayoutCtlNoList(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getLayoutCtlRs != null && getLayoutCtlRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var ctlNo in getLayoutCtlRs.Data)
                        {
                            var getLayoutRs = mstCoopLayoutService.GetMstCoopLayoutByCtlNo(ctlNo).Result;
                            if (getLayoutRs != null && getLayoutRs.StatusCode == HttpStatusCode.OK)
                            {
                                mstCoopLayoutEntities.Add(getLayoutRs.Data);
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopLayoutDetailListを取得する
                    var getLayoutDetailCtlRs = mstCoopLayoutService.GetNewestMstCoopLayoutDetailCtlNoList(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getLayoutDetailCtlRs != null && getLayoutDetailCtlRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var ctlNo in getLayoutDetailCtlRs.Data)
                        {
                            var getLayoutDetailRs = mstCoopLayoutService.GetMstCoopLayoutDetailByCtlNo(ctlNo).Result;
                            if (getLayoutDetailRs != null && getLayoutDetailRs.StatusCode == HttpStatusCode.OK)
                            {
                                mstCoopLayoutDetailEntities.Add(getLayoutDetailRs.Data);
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopFilenameListを取得する
                    var getFilenameCtlRs = mstCoopFilenameService.GetNewestMstCoopFilenameCtlNoList(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getFilenameCtlRs != null && getFilenameCtlRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var ctlNo in getFilenameCtlRs.Data)
                        {
                            var getFilenameRs = mstCoopFilenameService.GetMstCoopFilenameByCtlNo(ctlNo).Result;
                            if (getFilenameRs != null && getFilenameRs.StatusCode == HttpStatusCode.OK)
                            {
                                mstCoopFilenameEntities.Add(getFilenameRs.Data);
                            }
                            else
                            {
                                return false;
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopApilinkを取得する
                    var getApilinkRs = mstCoopApilinkService.GetMstCoopApilink(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getApilinkRs != null && getApilinkRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var apilink in getApilinkRs.Data)
                        {
                            // 重複しないCoopApilinkだけ追加する
                            if (!mstCoopApilinkEntities.Exists(x => x.IsSimilar(apilink)))
                            {
                                apilink.CtlNo = null;
                                mstCoopApilinkEntities.Add(apilink);
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // MstCoopIniを取得する
                    var getCoopIniRs = mstCoopIniService.GetMstCoopIni(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getCoopIniRs != null && getCoopIniRs.StatusCode == HttpStatusCode.OK)
                    {
                        MstCoopIniEntity mstCoopIniEntity1 = getCoopIniRs.Data.FirstOrDefault();

                        if (mstCoopIniEntity1 != null)
                        {
                            if (mstCoopIniEntity == null)
                            {
                                mstCoopIniEntity = mstCoopIniEntity1;
                                mstCoopIniEntity.CoopIniCd = null;
                                coopIniInfos = mstCoopIniEntity.GetCoopIniInfos();
                            }
                            else
                            {
                                List<CoopIniInfo> coopIniInfos1 = mstCoopIniEntity1.GetCoopIniInfos();
                                foreach (CoopIniInfo coopIni in coopIniInfos1)
                                {
                                    if (!coopIniInfos.Exists(x => x.Key0.Equals(coopIni.Key0) && x.Key1.Equals(coopIni.Key1) && x.Key2.Equals(coopIni.Key2)))
                                    {
                                        coopIniInfos.Add(coopIni);
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        return false;
                    }

                    // SysCoopNoを取得する
                    var getSysCoopNoRs = sysCoopNoService.GetSysCoopNo(this.Model.CoopFacilityArtifacts[this.Model.SelectedArtifactIndices[i]].FacilityCd).Result;
                    if (getSysCoopNoRs != null && getSysCoopNoRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var sysCoopNo in getSysCoopNoRs.Data)
                        {
                            sysCoopNo.CtlNo = null;

                            sysCoopNoEntities.Add(sysCoopNo);
                        }
                    }
                    else
                    {
                        return false;
                    }
                }

                #endregion

                #region 保存する

                //-----------------------------------------------------------------------------------
                // APIで保存します
                //-----------------------------------------------------------------------------------
                // MstCoopFacilityEntityを保存する
                var saveCoopFacilityRs = mstCoopFacilityService.SubmitMstCoopFacility(mstCoopFacilityEntity).Result;
                if (saveCoopFacilityRs == null || saveCoopFacilityRs.StatusCode != HttpStatusCode.OK)
                {
                    return false;
                }

                // MstCoopLayoutごと保存する
                foreach (MstCoopLayoutEntity mstCoopLayout in mstCoopLayoutEntities)
                {
                    mstCoopLayout.CtlNo = null;
                    mstCoopLayout.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveLayoutRes = mstCoopLayoutService.CreateOrUpdateMstCoopLayout(mstCoopLayout).Result;
                    if (saveLayoutRes == null || saveLayoutRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // MstCoopLayoutDetailごと保存する
                foreach (MstCoopLayoutDetailEntity mstCoopLayoutDetail in mstCoopLayoutDetailEntities)
                {
                    mstCoopLayoutDetail.CtlNo = null;
                    mstCoopLayoutDetail.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveLayoutDetailRes = mstCoopLayoutService.CreateOrUpdateMstCoopLayoutDetail(mstCoopLayoutDetail).Result;
                    if (saveLayoutDetailRes == null || saveLayoutDetailRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // MstCoopDistributeごと保存する
                foreach (MstCoopDistributeEntity mstCooDistribute in mstCoopDistributeEntities)
                {
                    mstCooDistribute.CtlNo = null;
                    mstCooDistribute.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveDistributeRes = mstCoopDistributeService.CreateOrUpdateMstCoopDistribute(mstCooDistribute).Result;
                    if (saveDistributeRes == null || saveDistributeRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // MstCoopFilenameごと保存する
                foreach (MstCoopFilenameEntity mstCoopFilename in mstCoopFilenameEntities)
                {
                    mstCoopFilename.CtlNo = null;
                    mstCoopFilename.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveDistributeRes = mstCoopFilenameService.CreateOrUpdateMstCoopFilename(mstCoopFilename).Result;
                    if (saveDistributeRes == null || saveDistributeRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // MstCoopApilinkの登録
                foreach (MstCoopApilinkEntity apilink in mstCoopApilinkEntities)
                {
                    if (apilink.CtlNo != null)
                    {
                        continue;
                    }

                    apilink.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveApilinkRes = mstCoopApilinkService.SubmitMstCoopApilink(apilink).Result;
                    if (saveApilinkRes == null || saveApilinkRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // MstCoopIniの登録
                if (mstCoopIniEntity != null)
                {
                    mstCoopIniEntity.FacilityCd = this.Model.Facility.FacilityCd;
                    mstCoopIniEntity.SetCoopIniInfos(coopIniInfos);
                    var saveCoopIniRes = mstCoopIniService.SubmitMstCoopIni(mstCoopIniEntity).Result;
                    if (saveCoopIniRes == null || saveCoopIniRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                // SysCoopNoの登録
                foreach (SysCoopNoEntity sysCoopNo in sysCoopNoEntities)
                {
                    sysCoopNo.FacilityCd = this.Model.Facility.FacilityCd;
                    var saveCoopNoRes = sysCoopNoService.SubmitSysCoopNo(sysCoopNo).Result;
                    if (saveCoopNoRes == null || saveCoopNoRes.StatusCode != HttpStatusCode.OK)
                    {
                        return false;
                    }
                }

                #endregion

                return true;
            });

            this.View.HideLoading();

            if (!ret)
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
