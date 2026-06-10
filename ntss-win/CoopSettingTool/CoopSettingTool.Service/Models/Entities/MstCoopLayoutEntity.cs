// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-11-2021
// ***********************************************************************
// <copyright file="MstCoopLayoutEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class CoopSettingItemList.
    /// </summary>
    public class CoopSettingItemList
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        /// <value>The name.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the length.
        /// </summary>
        /// <value>The length.</value>
        [JsonProperty("len")]
        public string Len { get; set; }

        /// <summary>
        /// Gets or sets the col.
        /// </summary>
        /// <value>The col.</value>
        [JsonProperty("col")]
        public string Col { get; set; }

        /// <summary>
        /// Gets or sets the key.
        /// </summary>
        /// <value>The key.</value>
        [JsonProperty("key")]
        public string Key { get; set; }

        /// <summary>
        /// Gets or sets the term.
        /// </summary>
        /// <value>The term.</value>
        [JsonProperty("term")]
        public string Term { get; set; }

        /// <summary>
        /// Gets or sets the type.
        /// </summary>
        /// <value>The type.</value>
        [JsonProperty("type")]
        public string Type { get; set; }

        /// <summary>
        /// Gets or sets the value.
        /// </summary>
        /// <value>The value.</value>
        [JsonProperty("value")]
        public string Value { get; set; }

        /// <summary>
        /// Gets or sets the append.
        /// </summary>
        /// <value>The append.</value>
        [JsonProperty("append")]
        public string Append { get; set; }

        /// <summary>
        /// Gets or sets the detail.
        /// </summary>
        /// <value>The detail.</value>
        [JsonProperty("detail")]
        public string Detail { get; set; }

        /// <summary>
        /// Gets or sets the length of the message.
        /// </summary>
        /// <value>The length of the message.</value>
        [JsonProperty("messageLen")]
        public string MessageLen { get; set; }

        /// <summary>
        /// Gets or sets the padding position.
        /// </summary>
        /// <value>The padding position.</value>
        [JsonProperty("paddingPosition")]
        public string PaddingPosition { get; set; }

        /// <summary>
        /// Gets or sets the padding format.
        /// </summary>
        /// <value>The padding format.</value>
        [JsonProperty("paddingFormat")]
        public string PaddingFormat { get; set; }

        /// <summary>
        /// Gets or sets the type of the item.
        /// </summary>
        /// <value>The type of the item.</value>
        [JsonProperty("itemType")]
        public string ItemType { get; set; }

        /// <summary>
        /// Gets or sets the repeat.
        /// </summary>
        /// <value>The repeat.</value>
        [JsonProperty("repeat")]
        public string Repeat { get; set; }

        /// <summary>
        /// The data set
        /// </summary>
        private string _dataSet;

        /// <summary>
        /// Gets or sets the data set.
        /// </summary>
        /// <value>The data set.</value>
        [JsonProperty("dataSet")]
        public string DataSet
        {
            get
            {
                if (!string.IsNullOrEmpty(Value))
                {
                    if (Occ)
                    {
                    }
                    else
                    {
                        var items = Value.Split(':');
                        if (items != null && items?.Length > 1)
                        {
                            var sqlcode = items[1].Split('.');
                            if (sqlcode != null && sqlcode.Length > 1)
                            {
                                _dataSet = sqlcode[0];
                            }
                        }
                    }
                }
                return _dataSet;
            }
            set => _dataSet = value;
        }

        /// <summary>
        /// The SQL parameter
        /// </summary>
        private string _sqlParam;

        /// <summary>
        /// Gets or sets the SQL parameter.
        /// </summary>
        /// <value>The SQL parameter.</value>
        [JsonProperty("sqlParam")]
        public string SqlParam
        {
            get
            {
                if (!string.IsNullOrEmpty(Value))
                {
                    if (Occ)
                    {
                    }
                    else
                    {
                        var items = Value.Split(':');
                        if (items != null && items?.Length > 1)
                        {
                            var sqlParam = items[1].Split('.');
                            if (sqlParam != null && sqlParam.Length > 1)
                            {
                                _sqlParam = sqlParam[1];
                            }
                        }
                    }
                }
                return _sqlParam;
            }
            set => _sqlParam = value;
        }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="CoopSettingItemList"/> is occ.
        /// </summary>
        /// <value><c>true</c> if occ; otherwise, <c>false</c>.</value>
        [JsonProperty("occ")]
        public bool Occ { get; set; }
    }

    /// <summary>
    /// Class DatasetKey.
    /// </summary>
    public class DatasetKey
    {
        /// <summary>
        /// Gets or sets the datakey.
        /// </summary>
        /// <value>The datakey.</value>
        [JsonProperty("dataKey")]
        public Dictionary<string, string> Datakey { get; set; }
        /// <summary>
        /// Gets or sets the SQL code.
        /// </summary>
        /// <value>The SQL code.</value>
        [JsonProperty("sqlCode")]
        public string SqlCode { get; set; }
    }

    /// <summary>
    /// Class CoopExtSetting.
    /// </summary>
    public class CoopExtSetting
    {
        /// <summary>
        /// Gets or sets the key.
        /// </summary>
        /// <value>The key.</value>
        [JsonProperty("key")]
        public Dictionary<string, Dictionary<string, string>> Key { get; set; }
        /// <summary>
        /// Gets or sets the dataset.
        /// </summary>
        /// <value>The dataset.</value>
        [JsonProperty("dataset")]
        public List<DatasetKey> Dataset { get; set; }
    }

    /// <summary>
    /// Class CoopSetting.
    /// </summary>
    public class CoopSetting
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        /// <value>The name.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the item list.
        /// </summary>
        /// <value>The item list.</value>
        [JsonProperty("itemList")]
        public List<CoopSettingItemList> ItemList { get; set; }
    }

    /// <summary>
    /// Class MstCoopLayoutEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopLayoutEntity : BaseEntity
    {
        public MstCoopLayoutEntity()
        {
            this.Initialize();
        }

        /// <summary>
        /// Gets or sets the reg date.
        /// </summary>
        /// <value>The reg date.</value>
        [JsonProperty("regDate")]
        [Browsable(false)]
        public DateTime? RegDate { get; set; }

        /// <summary>
        /// Gets or sets up date.
        /// </summary>
        /// <value>Up date.</value>
        [JsonProperty("upDate")]
        [Browsable(false)]
        public DateTime? UpDate { get; set; }

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
        /// Gets or sets the coop version.
        /// </summary>
        /// <value>The coop version.</value>
        [JsonProperty("coopVersion")]
        [ReadOnly(true)]
        [DisplayName("連携名")]
        public string CoopVersion { get; set; }

        /// <summary>
        /// Gets or sets the coop cd.
        /// </summary>
        /// <value>The coop cd.</value>
        [JsonProperty("coopCd")]
        [ReadOnly(true)]
        [DisplayName("電文種別")]
        public string CoopCd { get; set; }

        /// <summary>
        /// Gets or sets the index of the coop cd.
        /// </summary>
        /// <value>The index of the coop cd.</value>
        [JsonProperty("coopCdIndex")]
        [ReadOnly(true)]
        [DisplayName("付帯情報（電文）")]
        public string CoopCdIndex { get; set; }

        /// <summary>
        /// Gets or sets the direction.
        /// </summary>
        /// <value>The direction.</value>
        [JsonProperty("direction")]
        [ReadOnly(true)]
        [DisplayName("向き（送受信）")]
        public string Direction { get; set; }

        /// <summary>
        /// Gets or sets the coop cd sub.
        /// </summary>
        /// <value>The coop cd sub.</value>
        [JsonProperty("coopCdSub")]
        [ReadOnly(true)]
        [DisplayName("電文種別補足コード")]
        public string CoopCdSub { get; set; }

        /// <summary>
        /// Gets or sets the coop format.
        /// </summary>
        /// <value>The coop format.</value>
        [JsonProperty("coopFormat")]
        [ReadOnly(true)]
        [DisplayName("電文フォーマット")]
        public string CoopFormat { get; set; }

        /// <summary>
        /// Gets or sets the name of the coop.
        /// </summary>
        /// <value>The name of the coop.</value>
        [JsonProperty("coopName")]
        [ReadOnly(true)]
        [DisplayName("レイアウト名称")]
        public string CoopName { get; set; }

        /// <summary>
        /// Gets or sets the coop vender.
        /// </summary>
        /// <value>The coop vender.</value>
        [JsonProperty("coopVender")]
        [ReadOnly(true)]
        [DisplayName("対応ベンダー名")]
        public string CoopVender { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        /// <value>The description.</value>
        [JsonProperty("description")]
        [ReadOnly(true)]
        [DisplayName("説明")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the is editable.
        /// </summary>
        /// <value>The is editable.</value>
        [JsonProperty("isEditable")]
        [ReadOnly(true)]
        [Browsable(false)]
        public string IsEditable { get; set; }

        /// <summary>
        /// Gets or sets the coop setting string.
        /// </summary>
        /// <value>The coop setting string.</value>
        [JsonProperty("coopSetting")]
        [DisplayName("連携設定")]
        public string CoopSetting { get; set; }

        /// <summary>
        /// Gets or sets the coop ext setting.
        /// </summary>
        /// <value>The coop ext setting.</value>
        [JsonProperty("coopExtSetting")]
        [Browsable(false)]
        public object CoopExtSettingObject { get; set; }

        /// <summary>
        /// Gets or sets the coop ext setting.
        /// </summary>
        /// <value>The coop ext setting.</value>
        [DisplayName("拡張設定")]
        [ReadOnly(true)]
        public string CoopExtSetting
        {
            get
            {
                string rs = string.Empty;
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };
                rs = JsonConvert.SerializeObject(this.CoopExtSettingObject, settings);

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
                    this.CoopExtSettingObject = JsonConvert.DeserializeObject(value, settings);
                }
            }
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
        /// Gets or sets the user identifier.
        /// </summary>
        /// <value>The user identifier.</value>
        [JsonProperty("userId")]
        [Browsable(false)]
        public string UserId { get; set; }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            return (this.CoopSetting + this.CoopExtSetting + this.IsDel).GetHashCode();
        }
    }
}
