// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-21-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-18-2021
// ***********************************************************************
// <copyright file="MstCoopDistributeEntity.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using JsonSubTypes;
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
    /// Class ProtocolInfo.
    /// </summary>
    [JsonConverter(typeof(JsonSubtypes), "Protocol")]
    [JsonSubtypes.KnownSubType(typeof(SocketProtocolInfo), "socket")]
    [JsonSubtypes.KnownSubType(typeof(FileProtocolInfo), "file")]
    [JsonSubtypes.KnownSubType(typeof(FileSocketProtocolInfo), "filesocket")]
    public class ProtocolInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public virtual string Protocol { get; }

    }

    /// <summary>
    /// Class FileSocketProtocolInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    public class FileSocketProtocolInfo : ProtocolInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "filesocket";

        /// <summary>
        /// Gets or sets the host.
        /// </summary>
        /// <value>The host.</value>
        [JsonProperty("host")]
        [DisplayName("")]
        public string Host { get; set; }

        /// <summary>
        /// Gets or sets the port.
        /// </summary>
        /// <value>The port.</value>
        [JsonProperty("port")]
        public string Port { get; set; }

        /// <summary>
        /// Gets or sets the dummy.
        /// </summary>
        /// <value>The dummy.</value>
        [JsonProperty("dummy")]
        public string Dummy { get; set; }

        /// <summary>
        /// Gets or sets the delete.
        /// </summary>
        /// <value>The delete.</value>
        [JsonProperty("delete")]
        public string Delete { get; set; }

        /// <summary>
        /// Gets or sets the addesss.
        /// </summary>
        /// <value>The addesss.</value>
        [JsonProperty("address")]
        public string Addesss { get; set; }

        /// <summary>
        /// Gets or sets the time out.
        /// </summary>
        /// <value>The time out.</value>
        [JsonProperty("timeout")]
        public int TimeOut { get; set; }

        /// <summary>
        /// Gets or sets the retry maximum.
        /// </summary>
        /// <value>The retry maximum.</value>
        [JsonProperty("retryMax")]
        public int RetryMax { get; set; }

        /// <summary>
        /// Gets or sets the type of the send.
        /// </summary>
        /// <value>The type of the send.</value>
        [JsonProperty("sendType")]
        public string SendType { get; set; }

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket-type")]
        public string SocketType { get; set; }

        /// <summary>
        /// Gets or sets the rename when copying.
        /// </summary>
        /// <value>The rename when copying.</value>
        [JsonProperty("renameWhenCopying")]
        public string RenameWhenCopying { get; set; }
    }

    /// <summary>
    /// Class SocketProtocolInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    public class SocketProtocolInfo : ProtocolInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "socket";

        /// <summary>
        /// Gets or sets the host.
        /// </summary>
        /// <value>The host.</value>
        [JsonProperty("host")]
        [DisplayName("")]
        public string Host { get; set; }

        /// <summary>
        /// Gets or sets the port.
        /// </summary>
        /// <value>The port.</value>
        [JsonProperty("port")]
        public string Port { get; set; }

        /// <summary>
        /// Gets or sets the time out.
        /// </summary>
        /// <value>The time out.</value>
        [JsonProperty("timeout")]
        public int TimeOut { get; set; }

        /// <summary>
        /// Gets or sets the retry maximum.
        /// </summary>
        /// <value>The retry maximum.</value>
        [JsonProperty("retryMax")]
        public int RetryMax { get; set; }

        /// <summary>
        /// Gets or sets the type of the send.
        /// </summary>
        /// <value>The type of the send.</value>
        [JsonProperty("sendType")]
        public string SendType { get; set; }

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket-type")]
        public string SocketType { get; set; }
    }

    /// <summary>
    /// Class FileProtocolInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.ProtocolInfo" />
    public class FileProtocolInfo : ProtocolInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "file";

        /// <summary>
        /// Gets or sets the dummy.
        /// </summary>
        /// <value>The dummy.</value>
        [JsonProperty("dummy")]
        public string Dummy { get; set; }

        /// <summary>
        /// Gets or sets the delete.
        /// </summary>
        /// <value>The delete.</value>
        [JsonProperty("delete")]
        public string Delete { get; set; }

        /// <summary>
        /// Gets or sets the addesss.
        /// </summary>
        /// <value>The addesss.</value>
        [JsonProperty("address")]
        public string Addesss { get; set; }

        /// <summary>
        /// Gets or sets the replace.
        /// </summary>
        /// <value>The replace.</value>
        [JsonProperty("replace")]
        public string Replace { get; set; }

        /// <summary>
        /// Gets or sets the rename when copying.
        /// </summary>
        /// <value>The rename when copying.</value>
        [JsonProperty("renameWhenCopying")]
        public string RenameWhenCopying { get; set; }

    }

    /// <summary>
    /// Class DistributeSetting.
    /// </summary>
    public class DistributeSetting
    {
        /// <summary>
        /// Gets or sets the protocol information.
        /// </summary>
        /// <value>The protocol information.</value>
        [JsonProperty("protocolInfo")]
        public ProtocolInfo ProtocolInfo { get; set; }
    }

    /// <summary>
    /// Class MstCoopDistributeEntity.
    /// Implements the <see cref="CoopSettingTool.Service.Models.BaseEntity" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.BaseEntity" />
    public class MstCoopDistributeEntity : BaseEntity
    {
        public MstCoopDistributeEntity()
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
        /// 
        /// </summary>
        [JsonProperty("coopVersion")]
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
        [Browsable(false)]
        public string IsEditable { get; set; }

        /// <summary>
        /// Gets or sets the distribute setting.
        /// </summary>
        /// <value>The distribute setting.</value>
        [JsonProperty("distributeSetting")]
        [DisplayName("配信設定")]
        public string DistributeSetting { get; set; }

        /// <summary>
        /// Sets the distribute setting.
        /// </summary>
        /// <param name="distributeSettingProtocol">The distribute setting protocol.</param>
        public void SetDistributeSetting(DistributeSetting distributeSettingProtocol)
        {
            var settings = new JsonSerializerSettings
            {
                NullValueHandling = NullValueHandling.Ignore,
                MissingMemberHandling = MissingMemberHandling.Ignore
            };
            DistributeSetting = JsonConvert.SerializeObject(distributeSettingProtocol, settings);
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
        public long UserId { get; set; }

        /// <summary>
        /// Gets the distribute setting.
        /// </summary>
        /// <returns>DistributeSetting.</returns>
        public DistributeSetting GetDistributeSetting()
        {
            DistributeSetting item = new DistributeSetting();
            if (DistributeSetting != null)
            {
                var settings = new JsonSerializerSettings
                {
                    NullValueHandling = NullValueHandling.Ignore,
                    MissingMemberHandling = MissingMemberHandling.Ignore
                };
                item = JsonConvert.DeserializeObject<DistributeSetting>(DistributeSetting, settings);
            }
            return item;
        }

        /// <summary>
        /// Returns a hash code for this instance.
        /// </summary>
        /// <returns>A hash code for this instance, suitable for use in hashing algorithms and data structures like a hash table.</returns>
        public override int GetHashCode()
        {
            return (DistributeSetting + IsDel).GetHashCode();
        }
    }
}
