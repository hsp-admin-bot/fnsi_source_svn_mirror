// ***********************************************************************
// Assembly         : CoopSettingTool.App
// Author           : Phan Hai Thach
// Created          : 05-24-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-25-2021
// ***********************************************************************
// <copyright file="OrderNumberSettingController.cs" company="">
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
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Net;
using System.Threading.Tasks;
using System;

namespace CoopSettingTool.App.Controllers
{
    /// <summary>
    /// Class OrderNumberSettingController.
    /// Implements the <see cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IOrderNumberSettingView, CoopSettingTool.App.Models.IOrderNumberSettingModel}" />
    /// Implements the <see cref="CoopSettingTool.App.Controllers.IOrderNumberSettingController" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.App.Controllers.BaseController{CoopSettingTool.App.Views.IOrderNumberSettingView, CoopSettingTool.App.Models.IOrderNumberSettingModel}" />
    /// <seealso cref="CoopSettingTool.App.Controllers.IOrderNumberSettingController" />
    public class OrderNumberSettingController : BaseController<IOrderNumberSettingView, IOrderNumberSettingModel>, IOrderNumberSettingController
    {
        private const int ImportOrderNumberColumnCount = 9;
        private const int ImportColumnOffsetWithFacilityAndCoopVersion = 2;

        /// <summary>
        /// The system coop no service
        /// </summary>
        ISysCoopNoService sysCoopNoService;
        IMstCoopFacilityService mstCoopFacilityService;

        /// <summary>
        /// Initializes a new instance of the <see cref="OrderNumberSettingController"/> class.
        /// </summary>
        /// <param name="view">The view.</param>
        /// <param name="model">The model.</param>
        public OrderNumberSettingController(IOrderNumberSettingView view, IOrderNumberSettingModel model) : base(view, model)
        {
            sysCoopNoService = CompositionRoot.Resolve<ISysCoopNoService>();
            mstCoopFacilityService = CompositionRoot.Resolve<IMstCoopFacilityService>();
        }

        /// <summary>
        /// Adds the blank order number setting.
        /// </summary>
        public void AddBlankOrderNumberSetting()
        {
            this.Model.AddBlankOrderNumberSetting();
        }

        /// <summary>
        /// Loads the system coop no list.
        /// </summary>
        public async void LoadSysCoopNoList()
        {
            this.View.ShowLoading();

            bool result = await Task.Run(() =>
            {
                List<SysCoopNoEntity> sysCoopNoEntities = new List<SysCoopNoEntity>();
                var res = sysCoopNoService.GetSysCoopNo(this.Model.Facility.FacilityCd).Result;
                if (res != null && res.StatusCode == HttpStatusCode.OK)
                {
                    sysCoopNoEntities = res.Data;
                }
                else
                {
                    if (this.View.ShowAskMessage(Resources.ERROR_GET_DATA + "\r\n" + Resources.ASK_ABORT, Resources.ERROR, Enums.MessageTypeEnum.ERROR))
                    {
                        return false;
                    }
                }

                if (sysCoopNoEntities.Count == 0)
                {
                    sysCoopNoEntities.Add(new SysCoopNoEntity(this.Model.Facility.FacilityCd));
                }

                this.Model.SysCoopNoList = sysCoopNoEntities;

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
                // Get MstCoopFacility
                var facilityCd = this.Model.Facility.FacilityCd;
                var mstCoopFacilityReq = new GetMstCoopFacilityRequest() { FacilityCd = facilityCd };
                var mstCoopFacilityRes = mstCoopFacilityService.GetMstCoopFacility(mstCoopFacilityReq).Result;
                MstCoopFacilityEntity mstCoopFacility = null;
                if (mstCoopFacilityRes.StatusCode == HttpStatusCode.OK && mstCoopFacilityRes.Data != null && mstCoopFacilityRes.Data.Content.Count > 0)
                {
                    mstCoopFacility = mstCoopFacilityRes.Data.Content[0];
                }

                foreach (var sysCoopNo in this.Model.SysCoopNoList)
                {
                    if (sysCoopNo.IsModified)
                    {
                        // OrdCdsがない場合、保存しない
                        if (string.IsNullOrEmpty(sysCoopNo.OrdCds))
                        {
                            continue;
                        }

                        // Set UserId
                        long userNo = ServerAccess.GetInstance().UserNo;
                        sysCoopNo.UserId = (userNo > 0) ? userNo.ToString() : "-1";

                        // Set CoopVersion
                        if (mstCoopFacility != null && mstCoopFacility.CommonSettingObject != null)
                        {
                            // CommonSettingObject is sometimes object due to JSON deserialization issues in base class, need to ensure it's cast or re-serialized
                            // But MstCoopFacilityEntity has property CommonSetting (string) and CommonSettingObject (object).
                            // Let's use the CommonSetting string and deserialize it to CommonSetting class if needed.
                            // Accessing CommonSetting string property handles serialization/deserialization internally in the entity.
                            
                            // Re-instantiate CommonSetting from string to be safe
                            var commonSetting = JsonConvert.DeserializeObject<CommonSetting>(mstCoopFacility.CommonSetting);
                            
                            if(commonSetting != null && commonSetting.CoopOrdCds != null)
                            {
                                OrdCd match = null;
                                List<OrdCd> coopOrdCdCandidates = commonSetting.CoopOrdCds;
                                List<OrdCd> coopVersionMatchedCandidates = new List<OrdCd>();
                                if (!string.IsNullOrEmpty(sysCoopNo.CoopVersion))
                                {
                                    coopVersionMatchedCandidates = coopOrdCdCandidates
                                        .Where(x => x.CoopVersion == sysCoopNo.CoopVersion)
                                        .ToList();
                                }

                                // Try match by CoopCdIndex
                                if (!string.IsNullOrEmpty(sysCoopNo.CoopCdIndex))
                                {
                                    if (coopVersionMatchedCandidates.Count > 0)
                                    {
                                        match = coopVersionMatchedCandidates.FirstOrDefault(x => x.CoopCdIndex == sysCoopNo.CoopCdIndex);
                                    }

                                    if (match == null)
                                    {
                                        match = coopOrdCdCandidates.FirstOrDefault(x => x.CoopCdIndex == sysCoopNo.CoopCdIndex);
                                    }
                                }
                                
                                // Fallback: Try match by CoopCd from OrdCds
                                if (match == null && !string.IsNullOrEmpty(sysCoopNo.OrdCds))
                                {
                                    try
                                    {
                                        var sysOrdCds = JsonConvert.DeserializeObject<List<CoopCdItem>>(sysCoopNo.OrdCds);
                                        if (sysOrdCds != null && sysOrdCds.Count > 0)
                                        {
                                            var targetCd = sysOrdCds[0].CoopCd;
                                            if (coopVersionMatchedCandidates.Count > 0)
                                            {
                                                match = coopVersionMatchedCandidates.FirstOrDefault(x => x.CoopCd == targetCd);
                                            }

                                            if (match == null)
                                            {
                                                match = coopOrdCdCandidates.FirstOrDefault(x => x.CoopCd == targetCd);
                                            }
                                        }
                                    }
                                    catch { }
                                }

                                if (match != null)
                                {
                                    sysCoopNo.CoopVersion = match.CoopVersion;
                                }
                            }
                        }

                        // Default if null
                        if(string.IsNullOrEmpty(sysCoopNo.CoopVersion))
                        {
                            sysCoopNo.CoopVersion = "1";
                        }
                        
                        // Debug log
                        System.Diagnostics.Debug.WriteLine($"Saving SysCoopNo: FacilityCd={sysCoopNo.FacilityCd}, CoopVersion={sysCoopNo.CoopVersion}");
                        Console.WriteLine($"Saving SysCoopNo: FacilityCd={sysCoopNo.FacilityCd}, CoopVersion={sysCoopNo.CoopVersion}");

                        var res = sysCoopNoService.SubmitSysCoopNo(sysCoopNo).Result;
                        if (res == null || res.StatusCode != HttpStatusCode.OK)
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
        /// ファイルをインポートする
        /// </summary>
        /// <param name="filePath"></param>
        public async void Import(string filePath)
        {
            this.View.ShowLoading();

            await Task.Run(() =>
            {
                // ファイルのすべての行を取り込む
                string[] allLines = File.ReadAllLines(filePath);
                int importColumnOffset = HasFacilityAndCoopVersionColumns(allLines.FirstOrDefault()?.Split(','))
                    ? ImportColumnOffsetWithFacilityAndCoopVersion
                    : 0;
                List<string[]> lines = allLines.Skip(1).Select(v => v.Split(',')).ToList();
                foreach (string[] line in lines)
                {
                    // *[FacilityCd, CoopVersion,] OrdCds, CurCoopOrdNo, NoOfDigit, PaddingChar, PaddingPos, RangeMax, RangeMin, PrefixChar, SuffixChar
                    if (line.Length >= importColumnOffset + ImportOrderNumberColumnCount)
                    {
                        string importCoopVersion = importColumnOffset == ImportColumnOffsetWithFacilityAndCoopVersion ? line[1] : string.Empty;
                        string importOrdCds = line[importColumnOffset];

                        // 合ってる連携配信設定を探す
                        SysCoopNoEntity sysCoopNoEntity = this.Model.SysCoopNoList.FirstOrDefault(x => CheckCoopOrdCd(x.OrdCds, importOrdCds)
                                                                                                    && IsCoopVersionMatched(x.CoopVersion, importCoopVersion)
                                                                                                    && x.IsDel == "0");
                        if(sysCoopNoEntity != null)
                        {
                            if (!string.IsNullOrEmpty(importCoopVersion))
                            {
                                sysCoopNoEntity.CoopVersion = importCoopVersion;
                            }

                            sysCoopNoEntity.CurCoopOrdNo = line[importColumnOffset + 1];
                            sysCoopNoEntity.NoOfDigit = line[importColumnOffset + 2];
                            sysCoopNoEntity.PaddingChar = string.IsNullOrEmpty(line[importColumnOffset + 3]) ? '0' : line[importColumnOffset + 3][0];
                            sysCoopNoEntity.PaddingPos = line[importColumnOffset + 4];
                            sysCoopNoEntity.RangeMax = line[importColumnOffset + 5];
                            sysCoopNoEntity.RangeMin = line[importColumnOffset + 6];
                            sysCoopNoEntity.PrefixChar = line[importColumnOffset + 7];
                            sysCoopNoEntity.SuffixChar = line[importColumnOffset + 8];
                        }
                        else
                        {
                            sysCoopNoEntity = new SysCoopNoEntity(this.Model.Facility.FacilityCd);

                            if (!string.IsNullOrEmpty(importCoopVersion))
                            {
                                sysCoopNoEntity.CoopVersion = importCoopVersion;
                            }

                            string[] importCoopOrdCds = importOrdCds.Split(';');
                            List<CoopCdItem> coopCdItems = new List<CoopCdItem>();
                            foreach (string importCoopOrdCd in importCoopOrdCds)
                            {
                                coopCdItems.Add(new CoopCdItem() { CoopCd = importCoopOrdCd });
                            }
                            var settings = new JsonSerializerSettings
                            {
                                NullValueHandling = NullValueHandling.Ignore,
                                MissingMemberHandling = MissingMemberHandling.Ignore
                            };

                            sysCoopNoEntity.OrdCds = JsonConvert.SerializeObject(coopCdItems, settings);
                            sysCoopNoEntity.CurCoopOrdNo = line[importColumnOffset + 1];
                            sysCoopNoEntity.NoOfDigit = line[importColumnOffset + 2];
                            sysCoopNoEntity.PaddingChar = string.IsNullOrEmpty(line[importColumnOffset + 3])?'0':line[importColumnOffset + 3][0];
                            sysCoopNoEntity.PaddingPos = line[importColumnOffset + 4];
                            sysCoopNoEntity.RangeMax = line[importColumnOffset + 5];
                            sysCoopNoEntity.RangeMin = line[importColumnOffset + 6];
                            sysCoopNoEntity.PrefixChar = line[importColumnOffset + 7];
                            sysCoopNoEntity.SuffixChar = line[importColumnOffset + 8];

                            this.Model.SysCoopNoList.Add(sysCoopNoEntity);
                        }
                    }
                }

                this.Model.SysCoopNoList = this.Model.SysCoopNoList;

            });

            this.View.HideLoading();
        }

        /// <summary>
        /// 
        /// </summary>
        /// <param name="coopOrdCdsJson"></param>
        /// <param name="coopOrdCdsFromCsv"></param>
        /// <returns></returns>
        private static bool CheckCoopOrdCd(string coopOrdCdsJson, string coopOrdCdsFromCsv)
        {
            List<CoopCdItem> coopCdItems = new List<CoopCdItem>();
            try
            {
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore,
                    TypeNameHandling = TypeNameHandling.Auto
                };
                coopCdItems = JsonConvert.DeserializeObject<List<CoopCdItem>>(coopOrdCdsJson, settings);
                string[] importCoopOrdCds = coopOrdCdsFromCsv.Split(';');

                return coopCdItems != null
                    && coopCdItems.Count == importCoopOrdCds.Length
                    && importCoopOrdCds.All(importCoopOrdCd => coopCdItems.Exists(x => x.CoopCd == importCoopOrdCd));
            }
            catch
            {
            }

            return false;
        }

        private static bool IsCoopVersionMatched(string coopVersion, string coopVersionFromCsv)
        {
            return string.IsNullOrEmpty(coopVersionFromCsv) || coopVersion == coopVersionFromCsv;
        }

        private static bool HasFacilityAndCoopVersionColumns(string[] header)
        {
            return header != null
                && header.Length >= 3
                && IsHeaderMatched(header[0], "施設コード", "facilityCd", "FacilityCd")
                && IsHeaderMatched(header[1], "連携名", "連携版番号", "coopVersion", "CoopVersion", "coop_version");
        }

        private static bool IsHeaderMatched(string header, params string[] candidates)
        {
            string normalizedHeader = (header ?? string.Empty).Trim().Trim('"');
            return candidates.Any(candidate => normalizedHeader.Equals(candidate, StringComparison.OrdinalIgnoreCase));
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
