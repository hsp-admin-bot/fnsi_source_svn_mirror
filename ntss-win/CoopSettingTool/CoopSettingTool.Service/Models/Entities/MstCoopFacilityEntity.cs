// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-20-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-17-2021
// ***********************************************************************
// <copyright file="MstCoopFacilityEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class ReportType.
    /// </summary>
    public class ReportType
    {
        [JsonProperty("rep_dial")]
        public string RepDial { get; set; }
    }    

    /// <summary>
    /// Class OrdCd.
    /// </summary>
    public class OrdCd
    {
        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="OrdCd"/> is enable.
        /// </summary>
        /// <value><c>true</c> if enable; otherwise, <c>false</c>.</value>
        [JsonIgnore]
        [Browsable(false)]
        public bool Enable
        {
            get
            {
                if (OpeCds[0].Contains("OFF_"))
                {
                    return false;
                }
                else
                {
                    return true;
                }
            }

            set
            {
                if (value)
                {
                    for (int i = 0; i < OpeCds.Count; i++)
                    {
                        if (OpeCds[i].Contains("OFF_"))
                        {
                            OpeCds[i] = OpeCds[i].Remove(0, 4);
                        }
                    }
                }
                else
                {
                    for (int i = 0; i < OpeCds.Count; i++)
                    {
                        if (!OpeCds[i].Contains("OFF_"))
                        {
                            OpeCds[i] = "OFF_" + OpeCds[i];
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctl_no")]
        [DisplayName("管理番号")]
        public string CtlNo { get; set; }

        /// <summary>
        /// Gets or sets the coop cd.
        /// </summary>
        /// <value>The coop cd.</value>
        [JsonProperty("coop_cd")]
        [DisplayName("電文種別")]
        public string CoopCd { get; set; }

        /// <summary>
        /// Gets or sets the name of the coop.
        /// </summary>
        /// <value>The name of the coop.</value>
        [JsonProperty("coop_name")]
        [DisplayName("レイアウト名称")]
        public string CoopName { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether [create index].
        /// </summary>
        /// <value><c>true</c> if [create index]; otherwise, <c>false</c>.</value>
        [JsonProperty("createIndex")]
        [Browsable(false)]
        public bool CreateIndex { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this instance is get no.
        /// </summary>
        /// <value><c>true</c> if this instance is get no; otherwise, <c>false</c>.</value>
        [JsonProperty("is_get_no")]
        [Browsable(false)]
        public bool IsGetNo { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="OrdCd"/> is report.
        /// </summary>
        /// <value><c>true</c> if report; otherwise, <c>false</c>.</value>
        [JsonProperty("report")]
        [Browsable(false)]
        public bool Report { get; set; }

        /// <summary>
        /// Gets or sets the effect days.
        /// </summary>
        /// <value>The effect days.</value>
        [JsonProperty("effect_days")]
        [Browsable(false)]
        public string EffectDays { get; set; }

        /// <summary>
        /// Gets or sets the index of the coop cd.
        /// </summary>
        /// <value>The index of the coop cd.</value>
        [JsonProperty("coop_cd_index")]
        [DisplayName("付帯情報（電文）")]
        public string CoopCdIndex { get; set; }

        /// <summary>
        /// Gets or sets the direction.
        /// </summary>
        /// <value>The direction.</value>
        [JsonProperty("direction")]
        [DisplayName("向き（送受信）")]
        public string Direction { get; set; }

        /// <summary>
        /// Gets or sets the ana result.
        /// </summary>
        /// <value>The ana result.</value>
        [JsonProperty("ana_result")]
        [Browsable(false)]
        public string AnaResult { get; set; }

        /// <summary>
        /// Gets or sets the coop result.
        /// </summary>
        /// <value>The coop result.</value>
        [JsonProperty("coop_result")]
        [Browsable(false)]
        public string CoopResult { get; set; }

        /// <summary>
        /// Gets or sets the time out second.
        /// </summary>
        /// <value>The time out second.</value>
        [JsonProperty("time_out_second")]
        [Browsable(false)]
        public string TimeOutSecond { get; set; }

        /// <summary>
        /// Gets or sets the ope CDS.
        /// </summary>
        /// <value>The ope CDS.</value>
        [Browsable(false)]
        [JsonProperty("ope_cd")]
        public List<string> OpeCds { get; set; }

        /// <summary>
        /// Gets or sets the report types.
        /// </summary>
        [JsonProperty("report_type")]
        public List<ReportType> ReportTypes { get; set; }

        /// <summary>
        /// Gets or sets the coop version.
        /// </summary>
        [JsonProperty("coop_version")]
        public string CoopVersion { get; set; }

        /// <summary>
        /// Gets or sets key0.
        /// </summary>
        [JsonProperty("key0")]
        public string Key0 { get; set; }
    }

    /// <summary>
    /// Class CommonSetting.
    /// </summary>
    public class CommonSetting
    {
        /// <summary>
        /// Gets or sets the status.
        /// </summary>
        /// <value>The status.</value>
        [JsonProperty("status")]
        public string Status { get; set; }

        /// <summary>
        /// Gets or sets the ins mode.
        /// </summary>
        /// <value>The ins mode.</value>
        [JsonProperty("ins_mode")]
        public string InsMode { get; set; }

        /// <summary>
        /// Gets or sets the journal keep days.
        /// </summary>
        /// <value>The journal keep days.</value>
        [JsonProperty("journal_keep_days")]
        public string JournalKeepDays { get; set; }

        /// <summary>
        /// Gets or sets the dataset limit.
        /// </summary>
        /// <value>The dataset limit.</value>
        [JsonProperty("dataset_limit")]
        public string DatasetLimit { get; set; }

        /// <summary>
        /// Gets or sets the view synchronize time out second.
        /// </summary>
        /// <value>The view synchronize time out second.</value>
        [JsonProperty("ViewSyncTimeOutSecond")]
        public int ViewSyncTimeOutSecond { get; set; }

        /// <summary>
        /// Gets or sets the hosp pat identifier check coop.
        /// </summary>
        /// <value>The hosp pat identifier check coop.</value>
        [JsonProperty("hospPatIdCheckCoop")]
        public string HospPatIdCheckCoop { get; set; }

        /// <summary>
        /// Gets or sets the coop ope CDS.
        /// </summary>
        /// <value>The coop ope CDS.</value>
        [JsonProperty("coop_ope_cd")]
        public Dictionary<string, List<Dictionary<string, string>>> CoopOpeCds { get; set; }

        /// <summary>
        /// Gets or sets the coop ord CDS.
        /// </summary>
        /// <value>The coop ord CDS.</value>
        [JsonProperty("coop_ord_cd")]
        public List<OrdCd> CoopOrdCds { get; set; }

        /// <summary>
        /// Gets or sets the report types.
        /// </summary>
        /// <value>The report types.</value>
        [JsonProperty("report_type")]
        public List<ReportType> ReportTypes { get; set; }

        /// <summary>
        /// Merges the specified common setting.
        /// </summary>
        /// <param name="commonSetting">The common setting.</param>
        public void Merge(CommonSetting commonSetting)
        {
            if (this.CoopOpeCds == null)
            {
                this.CoopOpeCds = new Dictionary<string, List<Dictionary<string, string>>>();
                this.CoopOpeCds.Add("ope_cd_send", new List<Dictionary<string, string>>());
                this.CoopOpeCds.Add("ope_cd_receive", new List<Dictionary<string, string>>());
            }

            if (commonSetting.CoopOpeCds != null)
            {
                if (commonSetting.CoopOpeCds.ContainsKey("ope_cd_send"))
                {
                    // coop_ope_send
                    var baseOpeSends = this.CoopOpeCds["ope_cd_send"];
                    foreach (var opeSend in commonSetting.CoopOpeCds["ope_cd_send"])
                    {
                        if (!baseOpeSends.Exists(x => x["ope_cd"].Equals(opeSend["ope_cd"])))
                        {
                            baseOpeSends.Add(opeSend);
                        }
                    }
                    this.CoopOpeCds["ope_cd_send"] = baseOpeSends;
                }

                if (commonSetting.CoopOpeCds.ContainsKey("ope_cd_receive"))
                {
                    // coop_ope_receive
                    var baseOpeReceives = this.CoopOpeCds["ope_cd_receive"];
                    foreach (var opeReceive in commonSetting.CoopOpeCds["ope_cd_receive"])
                    {
                        if (!baseOpeReceives.Exists(x => x["ope_cd"].Equals(opeReceive["ope_cd"])))
                        {
                            baseOpeReceives.Add(opeReceive);
                        }
                    }
                    this.CoopOpeCds["ope_cd_receive"] = baseOpeReceives;
                }
            }

            if (commonSetting.CoopOrdCds != null)
            {
                // coop_ord_cd
                if (this.CoopOrdCds == null)
                {
                    this.CoopOrdCds = new List<OrdCd>();
                }
                foreach (OrdCd ordCd in commonSetting.CoopOrdCds)
                {
                    if (!this.CoopOrdCds.Exists(x => x.CoopCdIndex.Equals(ordCd.CoopCdIndex)))
                    {
                        this.CoopOrdCds.Add(ordCd);
                    }
                }
                for (int i = 0; i < this.CoopOrdCds.Count; i++)
                {
                    this.CoopOrdCds[i].CtlNo = (1 + i).ToString();
                }
            }
        }
    }

    /// <summary>
    /// Class MstCoopFacilityEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopFacilityEntity : BaseEntity
    {
        public MstCoopFacilityEntity()
        {
            this.Initialize();
        }

        /// <summary>
        /// Gets or sets the reg date.
        /// </summary>
        /// <value>The reg date.</value>
        [JsonProperty("regDate")]
        [Browsable(false)]
        public DateTime RegDate { get; set; }

        /// <summary>
        /// Gets or sets up date.
        /// </summary>
        /// <value>Up date.</value>
        [JsonProperty("upDate")]
        [Browsable(false)]
        public DateTime UpDate { get; set; }

        /// <summary>
        /// Gets or sets the control no.
        /// </summary>
        /// <value>The control no.</value>
        [JsonProperty("ctlNo")]
        [ReadOnly(true)]
        [DisplayName("管理番号")]
        public string CtlNo { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        [ReadOnly(true)]
        [DisplayName("施設コード")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        /// <value>The description.</value>
        [JsonProperty("description")]
        [ReadOnly(true)]
        [DisplayName("説明")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets if edge setting string.
        /// </summary>
        /// <value>If edge setting string.</value>
        [JsonProperty("ifEdgeSetting")]
        [ReadOnly(true)]
        [DisplayName("IFエッジ設定")]
        public string IfEdgeSetting { get; set; }

        /// <summary>
        /// Gets or sets the common setting.
        /// </summary>
        /// <value>The common setting.</value>
        [JsonProperty("commonSetting")]
        [Browsable(false)]
        public object CommonSettingObject { get; set; }

        /// <summary>
        /// Gets or sets the <see cref="System.String"/> with the specified error.
        /// </summary>
        /// <returns>System.String.</returns>
        [DisplayName("各機能共通設定")]
        [ReadOnly(true)]
        public string CommonSetting
        {
            get
            {
                string rs = string.Empty;
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };
                rs = JsonConvert.SerializeObject(this.CommonSettingObject, settings);

                return rs;
            }

            set
            {
                if (!string.IsNullOrEmpty(value))
                {
                    var settings = new JsonSerializerSettings
                    {
                        NullValueHandling = NullValueHandling.Ignore,
                        MissingMemberHandling = MissingMemberHandling.Ignore,
                        TypeNameHandling = TypeNameHandling.Auto
                    };
                    this.CommonSettingObject = JsonConvert.DeserializeObject(value, settings);
                }
            }
        }
        /// <summary>
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        [Browsable(false)]
        public string UserId { get; set; }

        /// <summary>
        /// Gets the display member.
        /// </summary>
        /// <value>The display member.</value>
        [JsonIgnore]
        [Browsable(false)]
        public string DisplayMember => string.Join(" - ", new List<string>() { FacilityCd, Description });

        /// <summary>
        /// Gets if edge setting.
        /// </summary>
        /// <returns>IfEgdeSetting.</returns>
        public IfEgdeSetting GetIfEdgeSetting()
        {

            IfEgdeSetting item = new IfEgdeSetting();
            if (!string.IsNullOrEmpty(IfEdgeSetting))
            {
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore,
                    TypeNameHandling = TypeNameHandling.Auto
                };
                item = JsonConvert.DeserializeObject<IfEgdeSetting>(IfEdgeSetting, settings);
            }

            return item;
        }

        /// <summary>
        /// Sets if edge setting.
        /// </summary>
        /// <param name="inSetting">The in setting.</param>
        public void SetIfEdgeSetting(IfEgdeSetting inSetting)
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            IfEdgeSetting = JsonConvert.SerializeObject(inSetting, settings);
        }

        /// <summary>
        /// Gets or sets the is disp.
        /// </summary>
        /// <value>The is disp.</value>
        [JsonProperty("isDisp")]
        [Browsable(false)]
        public string IsDisp { get; set; }

        /// <summary>
        /// Gets or sets the is delete.
        /// </summary>
        /// <value>The is delete.</value>
        [JsonProperty("isDel")]
        [DisplayName("削除フラグ")]
        public string IsDel { get; set; }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            return (this.IfEdgeSetting + this.CommonSetting + this.IsDel).GetHashCode();
        }
    }
}
