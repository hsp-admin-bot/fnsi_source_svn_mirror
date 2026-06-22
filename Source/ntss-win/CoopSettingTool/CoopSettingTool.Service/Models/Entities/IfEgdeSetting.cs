// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-23-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 11-17-2021
// ***********************************************************************
// <copyright file="IfEgdeSetting.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved
// </copyright>
// <summary></summary>
// ***********************************************************************
using JsonSubTypes;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.ComponentModel;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class Timer.
    /// </summary>
    public class Timer
    {
        /// <summary>
        /// Gets or sets the ope cd.
        /// </summary>
        /// <value>The ope cd.</value>
        [JsonProperty("ope_cd")]
        public string OpeCd { get; set; }

        /// <summary>
        /// Gets or sets the type of the data.
        /// </summary>
        /// <value>The type of the data.</value>
        [JsonProperty("datatype")]
        public string DataType { get; set; }

        /// <summary>
        /// Gets or sets the send times.
        /// </summary>
        /// <value>The send times.</value>
        [JsonProperty("send_time")]
        public List<string> SendTimes { get; set; }
    }

    /// <summary>
    /// Class WatchInfo.
    /// </summary>
    [JsonConverter(typeof(JsonSubtypes), "Protocol")]
    [JsonSubtypes.KnownSubType(typeof(HeadSocketWatchInfo), "headsocket")]
    [JsonSubtypes.KnownSubType(typeof(SocketWatchInfo), "socket")]
    [JsonSubtypes.KnownSubType(typeof(FileWatchInfo), "file")]
    public class WatchInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public virtual string Protocol { get;}

        /// <summary>
        /// Gets or sets the type of the data.
        /// </summary>
        /// <value>The type of the data.</value>
        [JsonProperty("datatype")]
        [Browsable(false)]
        public string DataType { get; set; }

        /// <summary>
        /// Gets or sets the index of the coop cd.
        /// </summary>
        /// <value>The index of the coop cd.</value>
        [JsonProperty("coop_cd_index")]
        [Browsable(false)]
        public string CoopCdIndex { get; set; }
    }

    /// <summary>
    /// Class HeadSocketWatchInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.WatchInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.WatchInfo" />
    public class HeadSocketWatchInfo : WatchInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "headsocket";

        /// <summary>
        /// Gets or sets the port.
        /// </summary>
        /// <value>The port.</value>
        [JsonProperty("port")]
        public string Port { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket-type")]
        public string SocketType { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the ope cd.
        /// </summary>
        /// <value>The ope cd.</value>
        [JsonProperty("ope_cd")]
        public string OpeCd { get; set; }
    }

    /// <summary>
    /// Class SocketWatchInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.WatchInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.WatchInfo" />
    public class SocketWatchInfo : WatchInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "socket";

        /// <summary>
        /// Gets or sets the port.
        /// </summary>
        /// <value>The port.</value>
        [JsonProperty("port")]
        public string Port { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket-type")]
        public string SocketType { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the ope cd.
        /// </summary>
        /// <value>The ope cd.</value>
        [JsonProperty("ope_cd")]
        public string OpeCd { get; set; }
    }

    /// <summary>
    /// Class FileWatchInfo.
    /// Implements the <see cref="CoopSettingTool.Service.Models.WatchInfo" />
    /// </summary>
    /// <seealso cref="CoopSettingTool.Service.Models.WatchInfo" />
    public class FileWatchInfo : WatchInfo
    {
        /// <summary>
        /// Gets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        [Browsable(false)]
        public override string Protocol { get; } = "file";

        /// <summary>
        /// Gets or sets the data path.
        /// </summary>
        /// <value>The data path.</value>
        [JsonProperty("data")]
        public string DataPath { get; set; } = string.Empty;

        /// <summary>
        /// Gets or sets the information path.
        /// </summary>
        /// <value>The information path.</value>
        [JsonProperty("watch")]
        public string InfoPath { get; set; } = string.Empty;
    }


    /// <summary>
    /// Class Receive.
    /// </summary>
    public class Receive
    {
        /// <summary>
        /// Gets or sets the watch infos.
        /// </summary>
        /// <value>The watch infos.</value>
        [JsonProperty("watch")]
        public List<WatchInfo> WatchInfos { get; set; }

        /// <summary>
        /// Gets or sets the keep die root.
        /// </summary>
        /// <value>The keep die root.</value>
        [JsonProperty("keepDirRoot")]
        public string KeepDieRoot { get; set; }
    }

    /// <summary>
    /// Class Header.
    /// </summary>
    public class Header
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        /// <value>The name.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the value.
        /// </summary>
        /// <value>The value.</value>
        [JsonProperty("value")]
        public string Value { get; set; }

        /// <summary>
        /// Gets or sets the format.
        /// </summary>
        /// <value>The format.</value>
        [JsonProperty("format")]
        public string Format { get; set; }

        /// <summary>
        /// Gets or sets the length.
        /// </summary>
        /// <value>The length.</value>
        [JsonProperty("length")]
        public string Length { get; set; }
    }

    /// <summary>
    /// Class Response.
    /// </summary>
    public class Response
    {
        /// <summary>
        /// Gets or sets the headers.
        /// </summary>
        /// <value>The headers.</value>
        [JsonProperty("header")]
        public List<Header> Headers { get; set; }

        /// <summary>
        /// Gets or sets the length.
        /// </summary>
        /// <value>The length.</value>
        [JsonProperty("header_length")]
        public string Length { get; set; }
    }

    /// <summary>
    /// Class ResponseTelegram.
    /// </summary>
    public class ResponseTelegram
    {
        /// <summary>
        /// Gets or sets the name of the type.
        /// </summary>
        /// <value>The name of the type.</value>
        [JsonProperty("type_name")]
        public string TypeName { get; set; }

        /// <summary>
        /// Gets or sets the skip value.
        /// </summary>
        /// <value>The skip value.</value>
        [JsonProperty("skip_value")]
        public string SkipValue { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        /// <value>The description.</value>
        [JsonProperty("description")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the name of the length.
        /// </summary>
        /// <value>The name of the length.</value>
        [JsonProperty("length_name")]
        public string LengthName { get; set; }

        /// <summary>
        /// Gets or sets the retry value.
        /// </summary>
        /// <value>The retry value.</value>
        [JsonProperty("retry_value")]
        public string RetryValue { get; set; }

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket_type")]
        public string SocketType { get; set; }

        /// <summary>
        /// Gets or sets the abnormal values.
        /// </summary>
        /// <value>The abnormal values.</value>
        [JsonProperty("abnormal_value")]
        public List<string> AbnormalValues { get; set; }

        /// <summary>
        /// Gets or sets the failure response.
        /// </summary>
        /// <value>The failure response.</value>
        [JsonProperty("response_failure")]
        public Response FailureResponse { get; set; }

        /// <summary>
        /// Gets or sets the success response.
        /// </summary>
        /// <value>The success response.</value>
        [JsonProperty("response_success")]
        public Response SuccessResponse { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether [header length included].
        /// </summary>
        /// <value><c>true</c> if [header length included]; otherwise, <c>false</c>.</value>
        [JsonProperty("header_length_included")]
        public bool HeaderLengthIncluded { get; set; }
    }

    /// <summary>
    /// Class CheckConnectItems.
    /// </summary>
    public class CheckConnectItems
    {
        /// <summary>
        /// Gets or sets the FTP.
        /// </summary>
        /// <value>The FTP.</value>
        [JsonProperty("ftp")]
        public List<string> Ftp { get; set; }

        /// <summary>
        /// Gets or sets the file.
        /// </summary>
        /// <value>The file.</value>
        [JsonProperty("file")]
        public List<string> File { get; set; }

        /// <summary>
        /// Gets or sets the SOAP.
        /// </summary>
        /// <value>The SOAP.</value>
        [JsonProperty("soap")]
        public List<string> Soap { get; set; }

        /// <summary>
        /// Gets or sets the socket.
        /// </summary>
        /// <value>The socket.</value>
        [JsonProperty("socket")]
        public List<string> Socket { get; set; }

        /// <summary>
        /// Gets or sets the TSH socket.
        /// </summary>
        /// <value>The TSH socket.</value>
        [JsonProperty("tshsocket")]
        public List<string> TshSocket { get; set; }

        /// <summary>
        /// Gets or sets the file socket.
        /// </summary>
        /// <value>The file socket.</value>
        [JsonProperty("filesocket")]
        public List<string> FileSocket { get; set; }

        /// <summary>
        /// Gets or sets the head socket.
        /// </summary>
        /// <value>The head socket.</value>
        [JsonProperty("headsocket")]
        public List<string> HeadSocket { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="CheckConnectItems" /> is redelivery.
        /// </summary>
        /// <value><c>true</c> if redelivery; otherwise, <c>false</c>.</value>
        [JsonProperty("redelivery")]
        public bool Redelivery { get; set; }
    }

    /// <summary>
    /// Class Format.
    /// </summary>
    public class Format
    {
        /// <summary>
        /// Gets or sets the name.
        /// </summary>
        /// <value>The name.</value>
        [JsonProperty("name")]
        public string Name { get; set; }

        /// <summary>
        /// Gets or sets the value.
        /// </summary>
        /// <value>The value.</value>
        [JsonProperty("value")]
        public string Value { get; set; }

        /// <summary>
        /// Gets or sets the length.
        /// </summary>
        /// <value>The length.</value>
        [JsonProperty("length")]
        public int Length { get; set; }
    }

    /// <summary>
    /// Class TshPlusTelegramFormat.
    /// </summary>
    public class TshPlusTelegramFormat
    {
        /// <summary>
        /// Gets or sets the formats.
        /// </summary>
        /// <value>The formats.</value>
        [JsonProperty("format")]
        public List<Format> Formats { get; set; }

        /// <summary>
        /// Gets or sets the protocol.
        /// </summary>
        /// <value>The protocol.</value>
        [JsonProperty("protocol")]
        public string Protocol { get; set; }

        /// <summary>
        /// Gets or sets the description.
        /// </summary>
        /// <value>The description.</value>
        [JsonProperty("description")]
        public string Description { get; set; }

        /// <summary>
        /// Gets or sets the type of the socket.
        /// </summary>
        /// <value>The type of the socket.</value>
        [JsonProperty("socket-type")]
        public string SocketType { get; set; }

        /// <summary>
        /// Gets or sets the length of the header.
        /// </summary>
        /// <value>The length of the header.</value>
        [JsonProperty("header_length")]
        public int HeaderLength { get; set; }

        /// <summary>
        /// Gets or sets the maximum length of the data.
        /// </summary>
        /// <value>The maximum length of the data.</value>
        [JsonProperty("data_max_length")]
        public int DataMaxLength { get; set; }
    }

    /// <summary>
    /// Class IfEgdeSetting.
    /// </summary>
    public class IfEgdeSetting
    {
        /// <summary>
        /// Gets or sets the send information.
        /// </summary>
        /// <value>The send information.</value>
        [JsonProperty("send")]
        public Dictionary<string, string> SendInfo { get; set; }

        /// <summary>
        /// Gets or sets the timers.
        /// </summary>
        /// <value>The timers.</value>
        [JsonProperty("timer")]
        public List<Timer> Timers { get; set; }

        /// <summary>
        /// Gets or sets the receive.
        /// </summary>
        /// <value>The receive.</value>
        [JsonProperty("receive")]
        public Receive Receive { get; set; }

        /// <summary>
        /// Gets or sets the URL root.
        /// </summary>
        /// <value>The URL root.</value>
        [JsonProperty("urlRoot")]
        public string UrlRoot { get; set; }

        /// <summary>
        /// Gets or sets the serial no.
        /// </summary>
        /// <value>The serial no.</value>
        [JsonProperty("serial_no")]
        public string SerialNo { get; set; }

        /// <summary>
        /// Gets or sets the temporary dir path.
        /// </summary>
        /// <value>The temporary dir path.</value>
        [JsonProperty("tmpDirPath")]
        public string TmpDirPath { get; set; }

        /// <summary>
        /// Gets or sets the facility cd.
        /// </summary>
        /// <value>The facility cd.</value>
        [JsonProperty("facility_cd")]
        public string FacilityCd { get; set; }

        /// <summary>
        /// Gets or sets the response telegram.
        /// </summary>
        /// <value>The response telegram.</value>
        [JsonProperty("response_telegram")]
        public List<ResponseTelegram> ResponseTelegrams { get; set; }

        /// <summary>
        /// Gets or sets the check connect items.
        /// </summary>
        /// <value>The check connect items.</value>
        [JsonProperty("check_connect_items")]
        public CheckConnectItems CheckConnectItems { get; set; }

        /// <summary>
        /// Gets or sets the TSH plus telegram formats.
        /// </summary>
        /// <value>The TSH plus telegram formats.</value>
        [JsonProperty("tshplus_telegram_format")]
        public List<TshPlusTelegramFormat> TshPlusTelegramFormats { get; set; }

        /// <summary>
        /// Merges the specified if egde setting.
        /// </summary>
        /// <param name="ifEgdeSetting">If egde setting.</param>
        public void Merge(IfEgdeSetting ifEgdeSetting)
        {
            foreach(var watch in ifEgdeSetting.Receive.WatchInfos)
            {
                if(!this.Receive.WatchInfos.Exists(x=> x.CoopCdIndex.Equals(watch.CoopCdIndex)))
                {
                    this.Receive.WatchInfos.Add(watch);
                }
            }
        }    
    }
}
