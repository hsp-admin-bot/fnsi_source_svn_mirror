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
using Newtonsoft.Json.Linq;
using System;
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
        /// The all coop facility code
        /// </summary>
        private const string AllCoopFacilityCd = "ALLCOP";

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
                // APIで全連携設定のMstCoopFacilityを取得する
                var param = new GetMstCoopFacilityRequest()
                {
                    FacilityCd = AllCoopFacilityCd
                };
                var res = mstCoopFacilityService.GetMstCoopFacility(param).Result;

                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    MstCoopFacilityEntity allCoopFacility = null;
                    if (res.Data != null && res.Data.Content != null)
                    {
                        allCoopFacility = res.Data.Content.FirstOrDefault();
                    }

                    MstCoopFacilityEntity currentCoopFacility = null;
                    if (this.Model.Facility != null && !string.IsNullOrWhiteSpace(this.Model.Facility.FacilityCd))
                    {
                        var currentParam = new GetMstCoopFacilityRequest()
                        {
                            FacilityCd = this.Model.Facility.FacilityCd
                        };
                        var currentRes = mstCoopFacilityService.GetMstCoopFacility(currentParam).Result;
                        if (currentRes != null && currentRes.StatusCode == HttpStatusCode.OK)
                        {
                            if (currentRes.Data != null && currentRes.Data.Content != null)
                            {
                                currentCoopFacility = currentRes.Data.Content.FirstOrDefault();
                            }
                        }
                        else
                        {
                            if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                            {
                                return false;
                            }
                        }
                    }

                    List<MstCoopFacilityEntity> coopFacilityArtifacts = CreateCoopFacilityArtifacts(allCoopFacility);
                    this.Model.SelectedArtifactIndices = GetInstalledCoopFacilityArtifactIndices(coopFacilityArtifacts, currentCoopFacility);
                    this.Model.CoopFacilityArtifacts = coopFacilityArtifacts;
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
                    if (!AddCurrentMstCoopDistributes(mstCoopDistributeEntities, this.Model.Facility.FacilityCd))
                    {
                        return false;
                    }

                    if (!AddCurrentMstCoopLayouts(mstCoopLayoutEntities, this.Model.Facility.FacilityCd))
                    {
                        return false;
                    }

                    if (!AddCurrentMstCoopLayoutDetails(mstCoopLayoutDetailEntities, this.Model.Facility.FacilityCd))
                    {
                        return false;
                    }

                    if (!AddCurrentMstCoopFilenames(mstCoopFilenameEntities, this.Model.Facility.FacilityCd))
                    {
                        return false;
                    }

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

                List<MstCoopFacilityEntity> selectedCoopFacilityArtifacts = GetSelectedCoopFacilityArtifacts();
                MstCoopFacilityEntity sourceCoopFacilityEntity = selectedCoopFacilityArtifacts.FirstOrDefault()
                    ?? this.Model.CoopFacilityArtifacts?.FirstOrDefault();
                if (sourceCoopFacilityEntity == null)
                {
                    return false;
                }

                List<OrdCd> selectedOrdCds = GetCoopOrdCds(selectedCoopFacilityArtifacts);
                UpdateUnselectedMstCoopDistributes(mstCoopDistributeEntities, selectedOrdCds);
                UpdateUnselectedMstCoopLayouts(mstCoopLayoutEntities, selectedOrdCds);
                UpdateUnselectedMstCoopLayoutDetails(mstCoopLayoutDetailEntities, selectedOrdCds);
                UpdateUnselectedMstCoopFilenames(mstCoopFilenameEntities, selectedOrdCds);
                UpdateUnselectedMstCoopApilinks(mstCoopApilinkEntities, selectedOrdCds);

                object selectedCommonSettingObject = CreateCommonSettingObject(sourceCoopFacilityEntity, selectedCoopFacilityArtifacts);

                // MstCoopFacility
                if (mstCoopFacilityEntity == null)
                {
                    // MstCoopFacilityを作成する
                    mstCoopFacilityEntity = sourceCoopFacilityEntity.JsonClone();
                    mstCoopFacilityEntity.CtlNo = null;
                    mstCoopFacilityEntity.FacilityCd = this.Model.Facility.FacilityCd;
                    mstCoopFacilityEntity.Description = this.Model.Facility.FacilityCd;
                    mstCoopFacilityEntity.UserId = ServerAccess.GetInstance().UserNo.ToString();
                }

                mstCoopFacilityEntity.CommonSettingObject = selectedCommonSettingObject;
                mstCoopFacilityEntity.IfEdgeSetting = CreateIfEdgeSetting(sourceCoopFacilityEntity, selectedOrdCds);

                string sourceFacilityCd = sourceCoopFacilityEntity.FacilityCd;

                // MstCoopDistributeを取得する
                if (!AddSourceMstCoopDistributes(mstCoopDistributeEntities, selectedOrdCds))
                {
                    return false;
                }

                // MstCoopLayoutListを取得する
                if (!AddSourceMstCoopLayouts(mstCoopLayoutEntities, selectedOrdCds))
                {
                    return false;
                }

                // MstCoopLayoutDetailListを取得する
                if (!AddSourceMstCoopLayoutDetails(mstCoopLayoutDetailEntities, selectedOrdCds))
                {
                    return false;
                }

                // MstCoopFilenameListを取得する
                if (!AddSourceMstCoopFilenames(mstCoopFilenameEntities, selectedOrdCds))
                {
                    return false;
                }

                // MstCoopApilinkを取得する
                HashSet<string> sourceApilinkKeys = new HashSet<string>(StringComparer.Ordinal);
                foreach (OrdCd selectedOrdCd in selectedOrdCds)
                {
                    if (selectedOrdCd == null || string.IsNullOrWhiteSpace(selectedOrdCd.CoopVersion))
                    {
                        continue;
                    }

                    string sourceApilinkKey = selectedOrdCd.CoopVersion.Trim() + "\t" + (selectedOrdCd.CoopCd ?? string.Empty).Trim();
                    if (!sourceApilinkKeys.Add(sourceApilinkKey))
                    {
                        continue;
                    }

                    var getSourceApilinkRs = mstCoopApilinkService.GetSourceMstCoopApilink(selectedOrdCd.CoopVersion, selectedOrdCd.CoopCd).Result;
                    if (getSourceApilinkRs != null && getSourceApilinkRs.StatusCode == HttpStatusCode.OK)
                    {
                        foreach (var apilink in getSourceApilinkRs.Data ?? new List<MstCoopApilinkEntity>())
                        {
                            if (!IsSourceMstCoopApilink(apilink))
                            {
                                continue;
                            }

                            if (!IsSelectedMstCoopApilink(apilink, selectedOrdCds))
                            {
                                continue;
                            }

                            // 重複しないCoopApilinkだけ追加する
                            if (!mstCoopApilinkEntities.Exists(x => IsActiveMstCoopApilink(x) && x.IsSimilar(apilink)))
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
                }

                // MstCoopIniを取得する
                var getSourceCoopIniRs = mstCoopIniService.GetMstCoopIni(sourceFacilityCd).Result;
                if (getSourceCoopIniRs != null && getSourceCoopIniRs.StatusCode == HttpStatusCode.OK)
                {
                    MstCoopIniEntity mstCoopIniEntity1 = getSourceCoopIniRs.Data.FirstOrDefault();

                    if (mstCoopIniEntity1 != null)
                    {
                        List<CoopIniInfo> coopIniInfos1 = mstCoopIniEntity1.GetCoopIniInfos();
                        coopIniInfos1 = coopIniInfos1.FindAll(x => IsSelectedCoopIniInfo(x, selectedOrdCds));

                        if (coopIniInfos1.Count > 0 && mstCoopIniEntity == null)
                        {
                            mstCoopIniEntity = mstCoopIniEntity1;
                            mstCoopIniEntity.CoopIniCd = null;
                            coopIniInfos = new List<CoopIniInfo>();
                        }

                        foreach (CoopIniInfo coopIni in coopIniInfos1)
                        {
                            if (!coopIniInfos.Exists(x => IsSameCoopIniInfo(x, coopIni)))
                            {
                                coopIniInfos.Add(coopIni);
                            }
                        }
                    }
                }
                else
                {
                    return false;
                }

                // SysCoopNoを取得する
                var getSysCoopNoRs = sysCoopNoService.GetSysCoopNo(sourceFacilityCd).Result;
                if (getSysCoopNoRs != null && getSysCoopNoRs.StatusCode == HttpStatusCode.OK)
                {
                    foreach (var sysCoopNo in getSysCoopNoRs.Data)
                    {
                        if (!IsSelectedCoopSetting(sysCoopNo.CoopCd, sysCoopNo.CoopCdIndex, null, sysCoopNo.CoopVersion, selectedOrdCds))
                        {
                            continue;
                        }

                        sysCoopNo.CtlNo = null;

                        sysCoopNoEntities.Add(sysCoopNo);
                    }
                }
                else
                {
                    return false;
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
                    if (mstCoopLayout.CtlNo != null && !IsDeletedMstCoopLayout(mstCoopLayout))
                    {
                        continue;
                    }

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
                    if (mstCoopLayoutDetail.CtlNo != null && !IsDeletedMstCoopLayoutDetail(mstCoopLayoutDetail))
                    {
                        continue;
                    }

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
                    if (mstCooDistribute.CtlNo != null && !IsDeletedMstCoopDistribute(mstCooDistribute))
                    {
                        continue;
                    }

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
                    if (mstCoopFilename.CtlNo != null && !IsDeletedMstCoopFilename(mstCoopFilename))
                    {
                        continue;
                    }

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
                    if (apilink.CtlNo != null && !IsDeletedMstCoopApilink(apilink))
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
        /// Creates the coop facility artifacts from all coop facility.
        /// </summary>
        /// <param name="allCoopFacility">The all coop facility.</param>
        /// <returns>The coop facility artifacts.</returns>
        private List<MstCoopFacilityEntity> CreateCoopFacilityArtifacts(MstCoopFacilityEntity allCoopFacility)
        {
            List<MstCoopFacilityEntity> result = new List<MstCoopFacilityEntity>();
            if (allCoopFacility == null || allCoopFacility.CommonSettingObject == null)
            {
                return result;
            }

            JObject commonSettingObject = GetCommonSettingJObject(allCoopFacility);
            JArray coopOrdCdTokens = commonSettingObject["coop_ord_cd"] as JArray;
            if (coopOrdCdTokens == null)
            {
                return result;
            }

            List<CoopOrdCdSource> coopOrdCdSources = new List<CoopOrdCdSource>();
            foreach (JToken coopOrdCdToken in coopOrdCdTokens)
            {
                OrdCd coopOrdCd = CreateCoopOrdCd(coopOrdCdToken);
                if (coopOrdCd == null)
                {
                    continue;
                }

                coopOrdCdSources.Add(new CoopOrdCdSource()
                {
                    CoopOrdCd = coopOrdCd,
                    SourceToken = coopOrdCdToken
                });
            }

            foreach (CoopOrdCdSource coopOrdCdSource in coopOrdCdSources
                .OrderBy(x => x.CoopOrdCd.CoopVender)
                .ThenBy(x => x.CoopOrdCd.CoopName))
            {
                result.Add(CreateCoopFacilityArtifact(allCoopFacility, coopOrdCdSource));
            }

            return result;
        }

        /// <summary>
        /// Creates a coop facility artifact.
        /// </summary>
        /// <param name="allCoopFacility">The all coop facility.</param>
        /// <param name="coopOrdCdSource">The coop order code source.</param>
        /// <returns>The coop facility artifact.</returns>
        private MstCoopFacilityEntity CreateCoopFacilityArtifact(MstCoopFacilityEntity allCoopFacility, CoopOrdCdSource coopOrdCdSource)
        {
            MstCoopFacilityEntity artifact = allCoopFacility.JsonClone();
            JObject commonSettingObject = GetCommonSettingJObject(allCoopFacility);
            commonSettingObject["coop_ord_cd"] = new JArray(coopOrdCdSource.SourceToken.DeepClone());

            artifact.CommonSettingObject = commonSettingObject;
            artifact.Description = coopOrdCdSource.CoopOrdCd.CoopName;

            return artifact;
        }

        /// <summary>
        /// Gets the installed coop facility artifact indices.
        /// </summary>
        /// <param name="coopFacilityArtifacts">The coop facility artifacts.</param>
        /// <param name="currentCoopFacility">The current coop facility.</param>
        /// <returns>The installed coop facility artifact indices.</returns>
        private List<int> GetInstalledCoopFacilityArtifactIndices(List<MstCoopFacilityEntity> coopFacilityArtifacts, MstCoopFacilityEntity currentCoopFacility)
        {
            List<int> result = new List<int>();
            if (coopFacilityArtifacts == null || currentCoopFacility == null)
            {
                return result;
            }

            CommonSetting currentCommonSetting = GetCommonSetting(currentCoopFacility);
            if (currentCommonSetting == null || currentCommonSetting.CoopOrdCds == null)
            {
                return result;
            }

            for (int i = 0; i < coopFacilityArtifacts.Count; i++)
            {
                OrdCd coopOrdCd = GetCoopOrdCd(coopFacilityArtifacts[i]);
                if (IsInstalledCoopOrdCd(coopOrdCd, currentCommonSetting.CoopOrdCds))
                {
                    result.Add(i);
                }
            }

            return result;
        }

        /// <summary>
        /// Determines whether the coop order code is installed.
        /// </summary>
        /// <param name="coopOrdCd">The coop order code.</param>
        /// <param name="installedCoopOrdCds">The installed coop order codes.</param>
        /// <returns><c>true</c> if the coop order code is installed; otherwise, <c>false</c>.</returns>
        private bool IsInstalledCoopOrdCd(OrdCd coopOrdCd, List<OrdCd> installedCoopOrdCds)
        {
            if (coopOrdCd == null || installedCoopOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd installedCoopOrdCd in installedCoopOrdCds)
            {
                if (IsInstalledCoopOrdCdMatched(coopOrdCd, installedCoopOrdCd))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Determines whether the coop order codes match.
        /// </summary>
        /// <param name="source">The source coop order code.</param>
        /// <param name="target">The target coop order code.</param>
        /// <returns><c>true</c> if the coop order codes match; otherwise, <c>false</c>.</returns>
        private bool IsInstalledCoopOrdCdMatched(OrdCd source, OrdCd target)
        {
            if (source == null || target == null)
            {
                return false;
            }

            return IsRequiredSettingFieldMatched(source.CtlNo, target.CtlNo)
                && IsCoopVendorMatched(source, target)
                && IsCoopFunctionMatched(source, target);
        }

        /// <summary>
        /// Determines whether the coop vendor matches.
        /// </summary>
        /// <param name="source">The source coop order code.</param>
        /// <param name="target">The target coop order code.</param>
        /// <returns><c>true</c> if the coop vendor matches; otherwise, <c>false</c>.</returns>
        private bool IsCoopVendorMatched(OrdCd source, OrdCd target)
        {
            if (!string.IsNullOrWhiteSpace(source.CoopVersion) || !string.IsNullOrWhiteSpace(target.CoopVersion))
            {
                return IsRequiredSettingFieldMatched(source.CoopVersion, target.CoopVersion);
            }

            return IsRequiredSettingFieldMatched(source.CoopVender, target.CoopVender);
        }

        /// <summary>
        /// Determines whether the coop function matches.
        /// </summary>
        /// <param name="source">The source coop order code.</param>
        /// <param name="target">The target coop order code.</param>
        /// <returns><c>true</c> if the coop function matches; otherwise, <c>false</c>.</returns>
        private bool IsCoopFunctionMatched(OrdCd source, OrdCd target)
        {
            return IsRequiredSettingFieldMatched(source.CoopCd, target.CoopCd)
                || IsRequiredSettingFieldMatched(source.CoopName, target.CoopName);
        }

        /// <summary>
        /// Determines whether the required setting field matches.
        /// </summary>
        /// <param name="source">The source value.</param>
        /// <param name="target">The target value.</param>
        /// <returns><c>true</c> if the field matches; otherwise, <c>false</c>.</returns>
        private bool IsRequiredSettingFieldMatched(string source, string target)
        {
            if (string.IsNullOrWhiteSpace(source) || string.IsNullOrWhiteSpace(target))
            {
                return false;
            }

            return string.Equals(source.Trim(), target.Trim(), StringComparison.Ordinal);
        }

        /// <summary>
        /// Gets the first coop order code.
        /// </summary>
        /// <param name="coopFacilityArtifact">The coop facility artifact.</param>
        /// <returns>The first coop order code.</returns>
        private OrdCd GetCoopOrdCd(MstCoopFacilityEntity coopFacilityArtifact)
        {
            if (coopFacilityArtifact == null || coopFacilityArtifact.CommonSettingObject == null)
            {
                return null;
            }

            JObject commonSettingObject = GetCommonSettingJObject(coopFacilityArtifact);
            JArray coopOrdCds = commonSettingObject["coop_ord_cd"] as JArray;
            if (coopOrdCds == null || coopOrdCds.Count == 0)
            {
                return null;
            }

            return CreateCoopOrdCd(coopOrdCds.FirstOrDefault());
        }

        /// <summary>
        /// Gets the selected coop facility artifacts.
        /// </summary>
        /// <returns>The selected coop facility artifacts.</returns>
        private List<MstCoopFacilityEntity> GetSelectedCoopFacilityArtifacts()
        {
            List<MstCoopFacilityEntity> result = new List<MstCoopFacilityEntity>();
            if (this.Model.SelectedArtifactIndices == null || this.Model.CoopFacilityArtifacts == null)
            {
                return result;
            }

            foreach (int selectedArtifactIndex in this.Model.SelectedArtifactIndices)
            {
                if (selectedArtifactIndex < 0 || selectedArtifactIndex >= this.Model.CoopFacilityArtifacts.Count)
                {
                    continue;
                }

                result.Add(this.Model.CoopFacilityArtifacts[selectedArtifactIndex]);
            }

            return result;
        }

        /// <summary>
        /// Gets the coop order codes.
        /// </summary>
        /// <param name="coopFacilityArtifacts">The coop facility artifacts.</param>
        /// <returns>The coop order codes.</returns>
        private List<OrdCd> GetCoopOrdCds(List<MstCoopFacilityEntity> coopFacilityArtifacts)
        {
            List<OrdCd> result = new List<OrdCd>();
            foreach (MstCoopFacilityEntity coopFacilityArtifact in coopFacilityArtifacts)
            {
                CommonSetting commonSetting = GetCommonSetting(coopFacilityArtifact);
                if (commonSetting == null || commonSetting.CoopOrdCds == null)
                {
                    continue;
                }

                result.AddRange(commonSetting.CoopOrdCds);
            }

            return result;
        }

        /// <summary>
        /// Gets the common setting.
        /// </summary>
        /// <param name="coopFacility">The coop facility.</param>
        /// <returns>The common setting.</returns>
        private CommonSetting GetCommonSetting(MstCoopFacilityEntity coopFacility)
        {
            JObject commonSettingObject = GetCommonSettingJObject(coopFacility);
            return commonSettingObject.ToObject<CommonSetting>();
        }

        /// <summary>
        /// Gets the common setting JSON object.
        /// </summary>
        /// <param name="coopFacility">The coop facility.</param>
        /// <returns>The common setting JSON object.</returns>
        private JObject GetCommonSettingJObject(MstCoopFacilityEntity coopFacility)
        {
            if (coopFacility == null || coopFacility.CommonSettingObject == null)
            {
                return new JObject();
            }

            JObject commonSettingObject = coopFacility.CommonSettingObject as JObject;
            if (commonSettingObject != null)
            {
                return (JObject)commonSettingObject.DeepClone();
            }

            string commonSetting = coopFacility.CommonSettingObject as string;
            if (string.IsNullOrWhiteSpace(commonSetting))
            {
                commonSetting = coopFacility.CommonSetting;
            }

            return ParseCommonSettingJObject(commonSetting);
        }

        /// <summary>
        /// Parses common setting JSON object.
        /// </summary>
        /// <param name="commonSetting">The common setting.</param>
        /// <returns>The common setting JSON object.</returns>
        private JObject ParseCommonSettingJObject(string commonSetting)
        {
            if (string.IsNullOrWhiteSpace(commonSetting) || commonSetting == "null")
            {
                return new JObject();
            }

            try
            {
                JToken commonSettingToken = JToken.Parse(commonSetting);
                if (commonSettingToken.Type == JTokenType.String)
                {
                    string commonSettingString = commonSettingToken.ToObject<string>();
                    if (string.IsNullOrWhiteSpace(commonSettingString))
                    {
                        return new JObject();
                    }

                    commonSettingToken = JToken.Parse(commonSettingString);
                }

                return commonSettingToken as JObject ?? new JObject();
            }
            catch (JsonReaderException)
            {
                return new JObject();
            }
        }

        /// <summary>
        /// Creates the coop order code from JSON token.
        /// </summary>
        /// <param name="coopOrdCdToken">The coop order code token.</param>
        /// <returns>The coop order code.</returns>
        private OrdCd CreateCoopOrdCd(JToken coopOrdCdToken)
        {
            if (coopOrdCdToken == null)
            {
                return null;
            }

            OrdCd coopOrdCd = coopOrdCdToken.ToObject<OrdCd>();
            if (coopOrdCd == null)
            {
                return null;
            }

            if (string.IsNullOrWhiteSpace(coopOrdCd.CoopVender))
            {
                coopOrdCd.CoopVender = GetJsonString(coopOrdCdToken, "coop_vender");
            }

            if (string.IsNullOrWhiteSpace(coopOrdCd.CoopName))
            {
                coopOrdCd.CoopName = GetJsonString(coopOrdCdToken, "coop_name");
            }

            return coopOrdCd;
        }

        /// <summary>
        /// Gets the JSON string value.
        /// </summary>
        /// <param name="token">The token.</param>
        /// <param name="propertyName">Name of the property.</param>
        /// <returns>The JSON string value.</returns>
        private string GetJsonString(JToken token, string propertyName)
        {
            if (token == null)
            {
                return null;
            }

            JToken valueToken = token[propertyName];
            if (valueToken == null || valueToken.Type == JTokenType.Null)
            {
                return null;
            }

            return valueToken.ToString();
        }

        private bool AddCurrentMstCoopDistributes(List<MstCoopDistributeEntity> mstCoopDistributeEntities, string facilityCd)
        {
            var getDistRs = mstCoopDistributeService.GetCurrentMstCoopDistributeList(facilityCd).Result;
            if (getDistRs == null || getDistRs.StatusCode != HttpStatusCode.OK)
            {
                return false;
            }

            mstCoopDistributeEntities.AddRange(getDistRs.Data ?? new List<MstCoopDistributeEntity>());

            return true;
        }

        private bool AddCurrentMstCoopLayouts(List<MstCoopLayoutEntity> mstCoopLayoutEntities, string facilityCd)
        {
            var getLayoutRs = mstCoopLayoutService.GetCurrentMstCoopLayoutList(facilityCd).Result;
            if (getLayoutRs == null || getLayoutRs.StatusCode != HttpStatusCode.OK)
            {
                return false;
            }

            mstCoopLayoutEntities.AddRange(getLayoutRs.Data ?? new List<MstCoopLayoutEntity>());

            return true;
        }

        private bool AddCurrentMstCoopLayoutDetails(List<MstCoopLayoutDetailEntity> mstCoopLayoutDetailEntities, string facilityCd)
        {
            var getLayoutDetailRs = mstCoopLayoutService.GetCurrentMstCoopLayoutDetailList(facilityCd).Result;
            if (getLayoutDetailRs == null || getLayoutDetailRs.StatusCode != HttpStatusCode.OK)
            {
                return false;
            }

            mstCoopLayoutDetailEntities.AddRange(getLayoutDetailRs.Data ?? new List<MstCoopLayoutDetailEntity>());

            return true;
        }

        private bool AddCurrentMstCoopFilenames(List<MstCoopFilenameEntity> mstCoopFilenameEntities, string facilityCd)
        {
            var getFilenameRs = mstCoopFilenameService.GetCurrentMstCoopFilenameList(facilityCd).Result;
            if (getFilenameRs == null || getFilenameRs.StatusCode != HttpStatusCode.OK)
            {
                return false;
            }

            mstCoopFilenameEntities.AddRange(getFilenameRs.Data ?? new List<MstCoopFilenameEntity>());

            return true;
        }

        private bool AddSourceMstCoopDistributes(List<MstCoopDistributeEntity> mstCoopDistributeEntities, List<OrdCd> selectedOrdCds)
        {
            HashSet<string> sourceKeys = new HashSet<string>(StringComparer.Ordinal);
            foreach (OrdCd selectedOrdCd in selectedOrdCds ?? new List<OrdCd>())
            {
                if (selectedOrdCd == null || string.IsNullOrWhiteSpace(selectedOrdCd.CoopVersion))
                {
                    continue;
                }

                string sourceKey = GetSourceKey(selectedOrdCd.CoopVersion, selectedOrdCd.CoopCd, selectedOrdCd.Direction);
                if (!sourceKeys.Add(sourceKey))
                {
                    continue;
                }

                MstCoopDistributeEntity condition = new MstCoopDistributeEntity()
                {
                    CoopVersion = selectedOrdCd.CoopVersion,
                    CoopCd = selectedOrdCd.CoopCd,
                    Direction = selectedOrdCd.Direction
                };

                var getSourceRs = mstCoopDistributeService.GetSourceMstCoopDistribute(condition).Result;
                if (getSourceRs == null || getSourceRs.StatusCode != HttpStatusCode.OK)
                {
                    return false;
                }

                foreach (MstCoopDistributeEntity distribute in getSourceRs.Data ?? new List<MstCoopDistributeEntity>())
                {
                    if (!IsSourceMstCoopDistribute(distribute) || !IsSelectedMstCoopDistribute(distribute, selectedOrdCds))
                    {
                        continue;
                    }

                    if (!mstCoopDistributeEntities.Exists(x => x.IsSimilar(distribute)))
                    {
                        distribute.CtlNo = null;
                        mstCoopDistributeEntities.Add(distribute);
                    }
                }
            }

            return true;
        }

        private bool AddSourceMstCoopLayouts(List<MstCoopLayoutEntity> mstCoopLayoutEntities, List<OrdCd> selectedOrdCds)
        {
            HashSet<string> sourceKeys = new HashSet<string>(StringComparer.Ordinal);
            foreach (OrdCd selectedOrdCd in selectedOrdCds ?? new List<OrdCd>())
            {
                if (selectedOrdCd == null || string.IsNullOrWhiteSpace(selectedOrdCd.CoopVersion))
                {
                    continue;
                }

                string sourceKey = GetSourceKey(selectedOrdCd.CoopVersion, selectedOrdCd.CoopCd, selectedOrdCd.Direction);
                if (!sourceKeys.Add(sourceKey))
                {
                    continue;
                }

                MstCoopLayoutEntity condition = new MstCoopLayoutEntity()
                {
                    CoopVersion = selectedOrdCd.CoopVersion,
                    CoopCd = selectedOrdCd.CoopCd,
                    Direction = selectedOrdCd.Direction
                };

                var getSourceRs = mstCoopLayoutService.GetSourceMstCoopLayout(condition).Result;
                if (getSourceRs == null || getSourceRs.StatusCode != HttpStatusCode.OK)
                {
                    return false;
                }

                foreach (MstCoopLayoutEntity layout in getSourceRs.Data ?? new List<MstCoopLayoutEntity>())
                {
                    if (!IsSourceMstCoopLayout(layout) || !IsSelectedMstCoopLayout(layout, selectedOrdCds))
                    {
                        continue;
                    }

                    if (!mstCoopLayoutEntities.Exists(x => x.IsSimilar(layout)))
                    {
                        layout.CtlNo = null;
                        mstCoopLayoutEntities.Add(layout);
                    }
                }
            }

            return true;
        }

        private bool AddSourceMstCoopLayoutDetails(List<MstCoopLayoutDetailEntity> mstCoopLayoutDetailEntities, List<OrdCd> selectedOrdCds)
        {
            HashSet<string> sourceKeys = new HashSet<string>(StringComparer.Ordinal);
            foreach (OrdCd selectedOrdCd in selectedOrdCds ?? new List<OrdCd>())
            {
                if (selectedOrdCd == null || string.IsNullOrWhiteSpace(selectedOrdCd.CoopVersion))
                {
                    continue;
                }

                string sourceKey = GetSourceKey(selectedOrdCd.CoopVersion, selectedOrdCd.CoopCd, selectedOrdCd.Direction);
                if (!sourceKeys.Add(sourceKey))
                {
                    continue;
                }

                MstCoopLayoutDetailEntity condition = new MstCoopLayoutDetailEntity()
                {
                    CoopVersion = selectedOrdCd.CoopVersion,
                    CoopCd = selectedOrdCd.CoopCd,
                    Direction = selectedOrdCd.Direction
                };

                var getSourceRs = mstCoopLayoutService.GetSourceMstCoopLayoutDetail(condition).Result;
                if (getSourceRs == null || getSourceRs.StatusCode != HttpStatusCode.OK)
                {
                    return false;
                }

                foreach (MstCoopLayoutDetailEntity layoutDetail in getSourceRs.Data ?? new List<MstCoopLayoutDetailEntity>())
                {
                    if (!IsSourceMstCoopLayoutDetail(layoutDetail) || !IsSelectedMstCoopLayoutDetail(layoutDetail, selectedOrdCds))
                    {
                        continue;
                    }

                    if (!mstCoopLayoutDetailEntities.Exists(x => x.IsSimilar(layoutDetail)))
                    {
                        layoutDetail.CtlNo = null;
                        mstCoopLayoutDetailEntities.Add(layoutDetail);
                    }
                }
            }

            return true;
        }

        private bool AddSourceMstCoopFilenames(List<MstCoopFilenameEntity> mstCoopFilenameEntities, List<OrdCd> selectedOrdCds)
        {
            HashSet<string> sourceKeys = new HashSet<string>(StringComparer.Ordinal);
            foreach (OrdCd selectedOrdCd in selectedOrdCds ?? new List<OrdCd>())
            {
                if (selectedOrdCd == null || string.IsNullOrWhiteSpace(selectedOrdCd.CoopVersion))
                {
                    continue;
                }

                string sourceKey = GetSourceKey(selectedOrdCd.CoopVersion, selectedOrdCd.CoopCd);
                if (!sourceKeys.Add(sourceKey))
                {
                    continue;
                }

                MstCoopFilenameEntity condition = new MstCoopFilenameEntity()
                {
                    CoopVersion = selectedOrdCd.CoopVersion,
                    CoopCd = selectedOrdCd.CoopCd
                };

                var getSourceRs = mstCoopFilenameService.GetSourceMstCoopFilename(condition).Result;
                if (getSourceRs == null || getSourceRs.StatusCode != HttpStatusCode.OK)
                {
                    return false;
                }

                foreach (MstCoopFilenameEntity filename in getSourceRs.Data ?? new List<MstCoopFilenameEntity>())
                {
                    if (!IsSourceMstCoopFilename(filename) || !IsSelectedMstCoopFilename(filename, selectedOrdCds))
                    {
                        continue;
                    }

                    if (!mstCoopFilenameEntities.Exists(x => x.IsSimilar(filename)))
                    {
                        filename.CtlNo = null;
                        mstCoopFilenameEntities.Add(filename);
                    }
                }
            }

            return true;
        }

        private string GetSourceKey(params string[] values)
        {
            return string.Join("\t", values.Select(x => (x ?? string.Empty).Trim()));
        }

        private bool IsSourceCtlNo(string ctlNo)
        {
            long parsedCtlNo = 0;
            return long.TryParse(ctlNo, out parsedCtlNo) && parsedCtlNo <= 0;
        }

        private void UpdateUnselectedMstCoopDistributes(List<MstCoopDistributeEntity> mstCoopDistributeEntities, List<OrdCd> selectedOrdCds)
        {
            if (mstCoopDistributeEntities == null)
            {
                return;
            }

            foreach (MstCoopDistributeEntity distribute in mstCoopDistributeEntities)
            {
                if (!IsSelectedMstCoopDistribute(distribute, selectedOrdCds))
                {
                    MarkDeleted(distribute);
                }
            }
        }

        private void UpdateUnselectedMstCoopLayouts(List<MstCoopLayoutEntity> mstCoopLayoutEntities, List<OrdCd> selectedOrdCds)
        {
            if (mstCoopLayoutEntities == null)
            {
                return;
            }

            foreach (MstCoopLayoutEntity layout in mstCoopLayoutEntities)
            {
                if (!IsSelectedMstCoopLayout(layout, selectedOrdCds))
                {
                    MarkDeleted(layout);
                }
            }
        }

        private void UpdateUnselectedMstCoopLayoutDetails(List<MstCoopLayoutDetailEntity> mstCoopLayoutDetailEntities, List<OrdCd> selectedOrdCds)
        {
            if (mstCoopLayoutDetailEntities == null)
            {
                return;
            }

            foreach (MstCoopLayoutDetailEntity layoutDetail in mstCoopLayoutDetailEntities)
            {
                if (!IsSelectedMstCoopLayoutDetail(layoutDetail, selectedOrdCds))
                {
                    MarkDeleted(layoutDetail);
                }
            }
        }

        private void UpdateUnselectedMstCoopFilenames(List<MstCoopFilenameEntity> mstCoopFilenameEntities, List<OrdCd> selectedOrdCds)
        {
            if (mstCoopFilenameEntities == null)
            {
                return;
            }

            foreach (MstCoopFilenameEntity filename in mstCoopFilenameEntities)
            {
                if (!IsSelectedMstCoopFilename(filename, selectedOrdCds))
                {
                    MarkDeleted(filename);
                }
            }
        }

        private bool IsSelectedMstCoopDistribute(MstCoopDistributeEntity distribute, List<OrdCd> selectedOrdCds)
        {
            if (distribute == null || selectedOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(distribute.CoopVersion, selectedOrdCd.CoopVersion)
                    && IsSameSettingField(distribute.CoopCd, selectedOrdCd.CoopCd)
                    && IsSameSettingField(distribute.Direction, selectedOrdCd.Direction))
                {
                    return true;
                }
            }

            return false;
        }

        private bool IsSelectedMstCoopLayout(MstCoopLayoutEntity layout, List<OrdCd> selectedOrdCds)
        {
            if (layout == null || selectedOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(layout.CoopVersion, selectedOrdCd.CoopVersion)
                    && IsSameSettingField(layout.CoopCd, selectedOrdCd.CoopCd)
                    && IsSameSettingField(layout.Direction, selectedOrdCd.Direction))
                {
                    return true;
                }
            }

            return false;
        }

        private bool IsSelectedMstCoopLayoutDetail(MstCoopLayoutDetailEntity layoutDetail, List<OrdCd> selectedOrdCds)
        {
            if (layoutDetail == null || selectedOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(layoutDetail.CoopVersion, selectedOrdCd.CoopVersion)
                    && IsSameSettingField(layoutDetail.CoopCd, selectedOrdCd.CoopCd)
                    && IsSameSettingField(layoutDetail.Direction, selectedOrdCd.Direction))
                {
                    return true;
                }
            }

            return false;
        }

        private bool IsSelectedMstCoopFilename(MstCoopFilenameEntity filename, List<OrdCd> selectedOrdCds)
        {
            if (filename == null || selectedOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(filename.CoopVersion, selectedOrdCd.CoopVersion)
                    && IsSameSettingField(filename.CoopCd, selectedOrdCd.CoopCd))
                {
                    return true;
                }
            }

            return false;
        }

        private bool IsSourceMstCoopDistribute(MstCoopDistributeEntity distribute)
        {
            return distribute != null && IsSourceCtlNo(distribute.CtlNo);
        }

        private bool IsSourceMstCoopLayout(MstCoopLayoutEntity layout)
        {
            return layout != null && IsSourceCtlNo(layout.CtlNo);
        }

        private bool IsSourceMstCoopLayoutDetail(MstCoopLayoutDetailEntity layoutDetail)
        {
            return layoutDetail != null && IsSourceCtlNo(layoutDetail.CtlNo);
        }

        private bool IsSourceMstCoopFilename(MstCoopFilenameEntity filename)
        {
            return filename != null && IsSourceCtlNo(filename.CtlNo);
        }

        private bool IsDeletedMstCoopDistribute(MstCoopDistributeEntity distribute)
        {
            return distribute != null && IsDeletedSetting(distribute.IsDel);
        }

        private bool IsDeletedMstCoopLayout(MstCoopLayoutEntity layout)
        {
            return layout != null && IsDeletedSetting(layout.IsDel);
        }

        private bool IsDeletedMstCoopLayoutDetail(MstCoopLayoutDetailEntity layoutDetail)
        {
            return layoutDetail != null && IsDeletedSetting(layoutDetail.IsDel);
        }

        private bool IsDeletedMstCoopFilename(MstCoopFilenameEntity filename)
        {
            return filename != null && IsDeletedSetting(filename.IsDel);
        }

        private bool IsDeletedSetting(string isDel)
        {
            return string.Equals(isDel, "1", StringComparison.Ordinal);
        }

        private void MarkDeleted(MstCoopDistributeEntity distribute)
        {
            distribute.IsDel = "1";
            distribute.IsDisp = "0";
        }

        private void MarkDeleted(MstCoopLayoutEntity layout)
        {
            layout.IsDel = "1";
            layout.IsDisp = "0";
        }

        private void MarkDeleted(MstCoopLayoutDetailEntity layoutDetail)
        {
            layoutDetail.IsDel = "1";
            layoutDetail.IsDisp = "0";
        }

        private void MarkDeleted(MstCoopFilenameEntity filename)
        {
            filename.IsDel = "1";
            filename.IsDisp = "0";
        }

        /// <summary>
        /// Updates unselected MST coop API link records to deleted.
        /// </summary>
        /// <param name="mstCoopApilinkEntities">The MST coop API link entities.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        private void UpdateUnselectedMstCoopApilinks(List<MstCoopApilinkEntity> mstCoopApilinkEntities, List<OrdCd> selectedOrdCds)
        {
            if (mstCoopApilinkEntities == null)
            {
                return;
            }

            foreach (MstCoopApilinkEntity apilink in mstCoopApilinkEntities)
            {
                if (!IsSelectedMstCoopApilink(apilink, selectedOrdCds))
                {
                    apilink.IsDel = "1";
                }
            }
        }

        /// <summary>
        /// Determines whether the MST coop API link is selected.
        /// </summary>
        /// <param name="apilink">The MST coop API link.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns><c>true</c> if the MST coop API link is selected; otherwise, <c>false</c>.</returns>
        private bool IsSelectedMstCoopApilink(MstCoopApilinkEntity apilink, List<OrdCd> selectedOrdCds)
        {
            if (apilink == null || selectedOrdCds == null)
            {
                return false;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(apilink.CoopVersion, selectedOrdCd.CoopVersion)
                    && IsSameSettingField(apilink.CoopCd, selectedOrdCd.CoopCd))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Determines whether the setting fields are the same.
        /// </summary>
        /// <param name="source">The source value.</param>
        /// <param name="target">The target value.</param>
        /// <returns><c>true</c> if the fields are the same; otherwise, <c>false</c>.</returns>
        private bool IsSameSettingField(string source, string target)
        {
            return string.Equals((source ?? string.Empty).Trim(), (target ?? string.Empty).Trim(), StringComparison.Ordinal);
        }

        /// <summary>
        /// Determines whether the MST coop API link is a source template.
        /// </summary>
        /// <param name="apilink">The MST coop API link.</param>
        /// <returns><c>true</c> if the MST coop API link is a source template; otherwise, <c>false</c>.</returns>
        private bool IsSourceMstCoopApilink(MstCoopApilinkEntity apilink)
        {
            if (apilink == null)
            {
                return false;
            }

            long ctlNo = 0;
            if (!long.TryParse(apilink.CtlNo, out ctlNo))
            {
                return false;
            }

            return ctlNo <= 0;
        }

        /// <summary>
        /// Determines whether the MST coop API link is active.
        /// </summary>
        /// <param name="apilink">The MST coop API link.</param>
        /// <returns><c>true</c> if the MST coop API link is active; otherwise, <c>false</c>.</returns>
        private bool IsActiveMstCoopApilink(MstCoopApilinkEntity apilink)
        {
            return apilink != null && !IsDeletedMstCoopApilink(apilink);
        }

        /// <summary>
        /// Determines whether the MST coop API link is deleted.
        /// </summary>
        /// <param name="apilink">The MST coop API link.</param>
        /// <returns><c>true</c> if the MST coop API link is deleted; otherwise, <c>false</c>.</returns>
        private bool IsDeletedMstCoopApilink(MstCoopApilinkEntity apilink)
        {
            return apilink != null && string.Equals(apilink.IsDel, "1", StringComparison.Ordinal);
        }

        /// <summary>
        /// Creates the selected common setting object.
        /// </summary>
        /// <param name="baseCoopFacility">The base coop facility.</param>
        /// <param name="selectedCoopFacilityArtifacts">The selected coop facility artifacts.</param>
        /// <returns>The selected common setting object.</returns>
        private object CreateCommonSettingObject(MstCoopFacilityEntity baseCoopFacility, List<MstCoopFacilityEntity> selectedCoopFacilityArtifacts)
        {
            JObject commonSettingObject = GetCommonSettingJObject(baseCoopFacility);
            JArray selectedCoopOrdCds = new JArray();

            foreach (MstCoopFacilityEntity selectedCoopFacilityArtifact in selectedCoopFacilityArtifacts)
            {
                JObject selectedCommonSettingObject = GetCommonSettingJObject(selectedCoopFacilityArtifact);
                JArray coopOrdCds = selectedCommonSettingObject["coop_ord_cd"] as JArray;
                if (coopOrdCds == null)
                {
                    continue;
                }

                foreach (JToken coopOrdCd in coopOrdCds)
                {
                    selectedCoopOrdCds.Add(coopOrdCd.DeepClone());
                }
            }

            commonSettingObject["coop_ord_cd"] = selectedCoopOrdCds;
            UpdateCoopOpeCdStatus(commonSettingObject, selectedCoopOrdCds);

            return commonSettingObject;
        }

        /// <summary>
        /// Updates the coop operation code status.
        /// </summary>
        /// <param name="commonSettingObject">The common setting object.</param>
        /// <param name="selectedCoopOrdCds">The selected coop order codes.</param>
        private void UpdateCoopOpeCdStatus(JObject commonSettingObject, JArray selectedCoopOrdCds)
        {
            if (commonSettingObject == null)
            {
                return;
            }

            JObject coopOpeCds = commonSettingObject["coop_ope_cd"] as JObject;
            if (coopOpeCds == null)
            {
                return;
            }

            HashSet<string> selectedOpeCds = GetSelectedOpeCds(selectedCoopOrdCds);
            UpdateCoopOpeCdStatus(coopOpeCds["ope_cd_send"] as JArray, selectedOpeCds);
            UpdateCoopOpeCdStatus(coopOpeCds["ope_cd_receive"] as JArray, selectedOpeCds);
        }

        /// <summary>
        /// Gets the selected operation codes.
        /// </summary>
        /// <param name="selectedCoopOrdCds">The selected coop order codes.</param>
        /// <returns>The selected operation codes.</returns>
        private HashSet<string> GetSelectedOpeCds(JArray selectedCoopOrdCds)
        {
            HashSet<string> result = new HashSet<string>(StringComparer.Ordinal);
            if (selectedCoopOrdCds == null)
            {
                return result;
            }

            foreach (JToken selectedCoopOrdCd in selectedCoopOrdCds)
            {
                JToken opeCdToken = selectedCoopOrdCd["ope_cd"];
                if (opeCdToken == null || opeCdToken.Type == JTokenType.Null)
                {
                    continue;
                }

                JArray opeCds = opeCdToken as JArray;
                if (opeCds != null)
                {
                    foreach (JToken opeCd in opeCds)
                    {
                        AddOpeCd(result, opeCd);
                    }
                }
                else
                {
                    AddOpeCd(result, opeCdToken);
                }
            }

            return result;
        }

        /// <summary>
        /// Adds the operation code.
        /// </summary>
        /// <param name="opeCds">The operation codes.</param>
        /// <param name="opeCdToken">The operation code token.</param>
        private void AddOpeCd(HashSet<string> opeCds, JToken opeCdToken)
        {
            if (opeCds == null || opeCdToken == null || opeCdToken.Type == JTokenType.Null)
            {
                return;
            }

            string opeCd = opeCdToken.ToString();
            if (string.IsNullOrWhiteSpace(opeCd))
            {
                return;
            }

            opeCds.Add(NormalizeOpeCd(opeCd));
        }

        /// <summary>
        /// Updates the coop operation code status.
        /// </summary>
        /// <param name="coopOpeCdSettings">The coop operation code settings.</param>
        /// <param name="selectedOpeCds">The selected operation codes.</param>
        private void UpdateCoopOpeCdStatus(JArray coopOpeCdSettings, HashSet<string> selectedOpeCds)
        {
            if (coopOpeCdSettings == null || selectedOpeCds == null)
            {
                return;
            }

            foreach (JToken coopOpeCdSetting in coopOpeCdSettings)
            {
                JObject coopOpeCdSettingObject = coopOpeCdSetting as JObject;
                if (coopOpeCdSettingObject == null)
                {
                    continue;
                }

                string opeCd = GetJsonString(coopOpeCdSettingObject, "ope_cd");
                if (string.IsNullOrWhiteSpace(opeCd))
                {
                    continue;
                }

                coopOpeCdSettingObject["status"] = selectedOpeCds.Contains(NormalizeOpeCd(opeCd)) ? "ON" : "OFF";
            }
        }

        /// <summary>
        /// Normalizes the operation code.
        /// </summary>
        /// <param name="opeCd">The operation code.</param>
        /// <returns>The normalized operation code.</returns>
        private string NormalizeOpeCd(string opeCd)
        {
            if (string.IsNullOrWhiteSpace(opeCd))
            {
                return string.Empty;
            }

            string normalizedOpeCd = opeCd.Trim();
            if (normalizedOpeCd.StartsWith("OFF_", StringComparison.Ordinal))
            {
                normalizedOpeCd = normalizedOpeCd.Substring(4);
            }

            return normalizedOpeCd;
        }

        /// <summary>
        /// Creates the selected IF edge setting.
        /// </summary>
        /// <param name="baseCoopFacility">The base coop facility.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns>The selected IF edge setting.</returns>
        private string CreateIfEdgeSetting(MstCoopFacilityEntity baseCoopFacility, List<OrdCd> selectedOrdCds)
        {
            if (baseCoopFacility == null || string.IsNullOrWhiteSpace(baseCoopFacility.IfEdgeSetting))
            {
                return null;
            }

            JObject ifEdgeSettingObject = ParseIfEdgeSettingJObject(baseCoopFacility.IfEdgeSetting);
            if (!ifEdgeSettingObject.HasValues)
            {
                return baseCoopFacility.IfEdgeSetting;
            }

            JArray timerSettings = ifEdgeSettingObject["timer"] as JArray;
            if (timerSettings != null)
            {
                ifEdgeSettingObject["timer"] = FilterIfEdgeSettings(timerSettings, selectedOrdCds);
            }

            JObject receiveSetting = ifEdgeSettingObject["receive"] as JObject;
            if (receiveSetting != null)
            {
                JArray watchSettings = receiveSetting["watch"] as JArray;
                if (watchSettings != null)
                {
                    receiveSetting["watch"] = FilterIfEdgeSettings(watchSettings, selectedOrdCds);
                }
            }

            return ifEdgeSettingObject.ToString(Formatting.None);
        }

        /// <summary>
        /// Parses the IF edge setting JSON object.
        /// </summary>
        /// <param name="ifEdgeSetting">The IF edge setting.</param>
        /// <returns>The IF edge setting JSON object.</returns>
        private JObject ParseIfEdgeSettingJObject(string ifEdgeSetting)
        {
            if (string.IsNullOrWhiteSpace(ifEdgeSetting) || ifEdgeSetting == "null")
            {
                return new JObject();
            }

            try
            {
                JToken ifEdgeSettingToken = JToken.Parse(ifEdgeSetting);
                if (ifEdgeSettingToken.Type == JTokenType.String)
                {
                    string ifEdgeSettingString = ifEdgeSettingToken.ToObject<string>();
                    if (string.IsNullOrWhiteSpace(ifEdgeSettingString))
                    {
                        return new JObject();
                    }

                    ifEdgeSettingToken = JToken.Parse(ifEdgeSettingString);
                }

                return ifEdgeSettingToken as JObject ?? new JObject();
            }
            catch (JsonReaderException)
            {
                return new JObject();
            }
        }

        /// <summary>
        /// Filters the IF edge settings.
        /// </summary>
        /// <param name="settings">The IF edge settings.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns>The filtered IF edge settings.</returns>
        private JArray FilterIfEdgeSettings(JArray settings, List<OrdCd> selectedOrdCds)
        {
            JArray result = new JArray();
            if (settings == null || selectedOrdCds == null)
            {
                return result;
            }

            foreach (JToken setting in settings)
            {
                if (IsSelectedIfEdgeSetting(setting, selectedOrdCds))
                {
                    result.Add(setting.DeepClone());
                }
            }

            return result;
        }

        /// <summary>
        /// Determines whether the IF edge setting is selected.
        /// </summary>
        /// <param name="setting">The IF edge setting.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns><c>true</c> if the IF edge setting is selected; otherwise, <c>false</c>.</returns>
        private bool IsSelectedIfEdgeSetting(JToken setting, List<OrdCd> selectedOrdCds)
        {
            string coopVersion = GetJsonString(setting, "coop_version");
            string dataType = GetJsonString(setting, "datatype");

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (IsRequiredSettingFieldMatched(coopVersion, selectedOrdCd.CoopVersion)
                    && IsRequiredSettingFieldMatched(dataType, selectedOrdCd.CoopCd))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Determines whether the coop setting is selected.
        /// </summary>
        /// <param name="coopCd">The coop cd.</param>
        /// <param name="coopCdIndex">The coop cd index.</param>
        /// <param name="direction">The direction.</param>
        /// <param name="coopVersion">The coop version.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns><c>true</c> if the coop setting is selected; otherwise, <c>false</c>.</returns>
        private bool IsSelectedCoopSetting(string coopCd, string coopCdIndex, string direction, string coopVersion, List<OrdCd> selectedOrdCds)
        {
            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (!IsSettingFieldMatched(coopCdIndex, selectedOrdCd.CoopCdIndex))
                {
                    continue;
                }

                if (!IsSettingFieldMatched(coopCd, selectedOrdCd.CoopCd))
                {
                    continue;
                }

                if (!IsSettingFieldMatched(direction, selectedOrdCd.Direction))
                {
                    continue;
                }

                if (!IsSettingFieldMatched(coopVersion, selectedOrdCd.CoopVersion))
                {
                    continue;
                }

                return true;
            }

            return false;
        }

        /// <summary>
        /// Determines whether the target field matches the selected field.
        /// </summary>
        /// <param name="targetValue">The target value.</param>
        /// <param name="selectedValue">The selected value.</param>
        /// <returns><c>true</c> if the field matches; otherwise, <c>false</c>.</returns>
        private bool IsSettingFieldMatched(string targetValue, string selectedValue)
        {
            if (string.IsNullOrWhiteSpace(targetValue))
            {
                return true;
            }

            return string.Equals(targetValue, selectedValue, StringComparison.Ordinal);
        }

        /// <summary>
        /// Determines whether the coop ini info is selected.
        /// </summary>
        /// <param name="coopIniInfo">The coop ini info.</param>
        /// <param name="selectedOrdCds">The selected order codes.</param>
        /// <returns><c>true</c> if the coop ini info is selected; otherwise, <c>false</c>.</returns>
        private bool IsSelectedCoopIniInfo(CoopIniInfo coopIniInfo, List<OrdCd> selectedOrdCds)
        {
            if (coopIniInfo == null)
            {
                return false;
            }

            if (string.IsNullOrWhiteSpace(coopIniInfo.Key0))
            {
                return true;
            }

            foreach (OrdCd selectedOrdCd in selectedOrdCds)
            {
                if (string.Equals(coopIniInfo.Key0, selectedOrdCd.Key0, StringComparison.Ordinal)
                    || string.Equals(coopIniInfo.Key0, selectedOrdCd.CoopVersion, StringComparison.Ordinal))
                {
                    return true;
                }
            }

            return false;
        }

        /// <summary>
        /// Determines whether the coop ini info is same.
        /// </summary>
        /// <param name="left">The left coop ini info.</param>
        /// <param name="right">The right coop ini info.</param>
        /// <returns><c>true</c> if the coop ini info is same; otherwise, <c>false</c>.</returns>
        private bool IsSameCoopIniInfo(CoopIniInfo left, CoopIniInfo right)
        {
            return string.Equals(left.Key0, right.Key0, StringComparison.Ordinal)
                && string.Equals(left.Key1, right.Key1, StringComparison.Ordinal)
                && string.Equals(left.Key2, right.Key2, StringComparison.Ordinal);
        }

        /// <summary>
        /// Class CoopOrdCdSource.
        /// </summary>
        private class CoopOrdCdSource
        {
            /// <summary>
            /// Gets or sets the coop order code.
            /// </summary>
            /// <value>The coop order code.</value>
            public OrdCd CoopOrdCd { get; set; }

            /// <summary>
            /// Gets or sets the source token.
            /// </summary>
            /// <value>The source token.</value>
            public JToken SourceToken { get; set; }
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
