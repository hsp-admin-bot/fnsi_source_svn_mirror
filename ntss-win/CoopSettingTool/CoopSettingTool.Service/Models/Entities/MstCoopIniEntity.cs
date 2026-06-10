// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 05-26-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="MstCoopIniEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Service.Extendsions;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Text;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class CoopIniInfo.
    /// </summary>
    public class CoopIniInfo : BaseEntity
    {
        public CoopIniInfo() 
        {
            IsEffect = "1";

            this.Initialize();
        }

        public CoopIniInfo(string key0, string key1, string key2, string value, string comment, string defaultValue, string isEffect)
        {
            this.Key0 = key0;
            this.Key1 = key1;
            this.Key2 = key2;
            this.Value = value;
            this.Comment = comment;
            this.DefaultValue = defaultValue;
            this.IsEffect = isEffect;
            this.Initialize();
        }

        /// <summary>
        /// Gets or sets the key0.
        /// </summary>
        /// <value>The key1.</value>
        [JsonProperty("key0")]
        [DisplayName("キー０")]
        public string Key0 { get; set; }

        /// <summary>
        /// Gets or sets the key1.
        /// </summary>
        /// <value>The key1.</value>
        [JsonProperty("key1")]
        [DisplayName("キー１")]
        public string Key1 { get; set; }

        /// <summary>
        /// Gets or sets the key2.
        /// </summary>
        /// <value>The key2.</value>
        [JsonProperty("key2")]
        [DisplayName("キー２")]
        public string Key2 { get; set; }

        /// <summary>
        /// Gets or sets the value.
        /// </summary>
        /// <value>The value.</value>
        [JsonProperty("value")]
        [DisplayName("値")]
        public string Value { get; set; }

        /// <summary>
        /// Gets or sets the comment.
        /// </summary>
        /// <value>The comment.</value>
        [JsonProperty("comment")]
        [DisplayName("コメント")]
        public string Comment 
        { 
            get { return this._comment; }
            set 
            {
                if (value == null)
                {
                    this._comment = string.Empty;
                }
                else
                {
                    this._comment = value;
                }
            }
        }
        private string _comment = string.Empty;

        /// <summary>
        /// Gets or sets the default value.
        /// </summary>
        /// <value>The default value.</value>
        [JsonProperty("default_v")]
        [DisplayName("デフォルト値")]
        public string DefaultValue { get; set; }

        /// <summary>
        /// Gets or sets the is effect.
        /// </summary>
        /// <value>The is effect.</value>
        [JsonProperty("is_effect")]
        [Browsable(false)]
        public string IsEffect { get; set; }

        /// <summary>
        /// Froms the CSV.
        /// RFC 4180 準拠のCSV解析を行う。
        /// </summary>
        /// <param name="values">The CSV values.</param>
        /// <returns>CoopIniInfo.</returns>
        public static CoopIniInfo FromCsv(List<string> values)
        {
            // 値が7つ未満の場合は空文字で補完
            while (values.Count < 7)
            {
                values.Add(string.Empty);
            }

            CoopIniInfo coopIniInfo = new CoopIniInfo(
                values[0]
                , values[1]
                , values[2]
                , values[3]
                , values[4]
                , values[5]
                , values[6]);

            return coopIniInfo;
        }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            int hashCode = this.GetHashCodeOnProperties();
            return hashCode;
        }
    }


    /// <summary>
    /// Class MstCoopIniEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopIniEntity : BaseEntity
    {
        public MstCoopIniEntity(string facilityCd)
        {
            this.FacilityCd = facilityCd;
            this.IsDisp = "1";
            this.IsDel = "0";
            this.SetCoopIniInfos(new List<CoopIniInfo>());
        }

        /// <summary>
        /// Gets or sets the coop ini cd.
        /// </summary>
        /// <value>The coop ini cd.</value>
        [JsonProperty("coopIniCd")]
        [Browsable(false)]
        public string CoopIniCd { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facilityCd")]
        [Browsable(false)]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the coop ini memo.
        /// </summary>
        /// <value>The coop ini memo.</value>
        [JsonProperty("coopIniMemo")]
        public string CoopIniMemo { get; set; }

        /// <summary>
        /// Gets or sets the coop ini infos.
        /// </summary>
        /// <value>The coop ini infos.</value>
        [JsonProperty("coopIniInfo")]
        private string CoopIniInfos { get; set; }

        /// <summary>
        /// Gets or sets the is disp.
        /// </summary>
        /// <value>The is disp.</value>
        [JsonProperty("isDisp")]
        public string IsDisp { get; set; }

        /// <summary>
        /// Gets or sets the is delete.
        /// </summary>
        /// <value>The is delete.</value>
        [JsonProperty("isDel")]
        public string IsDel { get; set; }

        /// <summary>
        /// Gets or sets the reg date.
        /// </summary>
        /// <value>The reg date.</value>
        [JsonProperty("regDate")]
        public DateTime RegDate { get; set; }

        /// <summary>
        /// Gets or sets up date.
        /// </summary>
        /// <value>Up date.</value>
        [JsonProperty("upDate")]
        public DateTime UpDate { get; set; }

        /// <summary>
        /// Gets if edge setting.
        /// </summary>
        /// <returns>IfEgdeSetting.</returns>
        public List<CoopIniInfo> GetCoopIniInfos()
        {

            List<CoopIniInfo> item = new List<CoopIniInfo>();
            if (CoopIniInfos != null)
            {
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore,
                    TypeNameHandling = TypeNameHandling.Auto
                };
                item = JsonConvert.DeserializeObject<List<CoopIniInfo>>(CoopIniInfos, settings);
            }

            return item;
        }

        /// <summary>
        /// Sets if edge setting.
        /// </summary>
        /// <param name="inSetting">The in setting.</param>
        public void SetCoopIniInfos(List<CoopIniInfo> coopIniInfos)
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            CoopIniInfos = JsonConvert.SerializeObject(coopIniInfos, settings);
        }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            int hashCode = this.GetHashCodeOnProperties();
            return hashCode;
        }
    }
}
