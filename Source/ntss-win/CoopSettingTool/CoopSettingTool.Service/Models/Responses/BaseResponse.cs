// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 04-16-2021
// ***********************************************************************
// <copyright file="BaseResponse.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using Newtonsoft.Json;
using System;
using System.Net;

namespace CoopSettingTool.Service.Models
{
    /// <summary>
    /// Class BasePageable.
    /// </summary>
    public class BasePageable
    {
        /// <summary>
        /// Gets or sets the sort.
        /// </summary>
        /// <value>The sort.</value>
        [JsonProperty("content")]
        public string Sort { get; set; }

        /// <summary>
        /// Gets or sets the offset.
        /// </summary>
        /// <value>The offset.</value>
        [JsonProperty("offset")]
        public int Offset { get; set; }

        /// <summary>
        /// Gets or sets the pagesize.
        /// </summary>
        /// <value>The pagesize.</value>
        [JsonProperty("pageSize")]
        public int Pagesize { get; set; }

        /// <summary>
        /// Gets or sets the page number.
        /// </summary>
        /// <value>The page number.</value>
        [JsonProperty("pageNumber")]
        public int PageNumber { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="BasePageable"/> is unpaged.
        /// </summary>
        /// <value><c>true</c> if unpaged; otherwise, <c>false</c>.</value>
        [JsonProperty("unpaged")]
        public bool Unpaged { get; set; }

        /// <summary>
        /// Gets or sets a value indicating whether this <see cref="BasePageable"/> is paged.
        /// </summary>
        /// <value><c>true</c> if paged; otherwise, <c>false</c>.</value>
        [JsonProperty("paged")]
        public bool Paged { get; set; }
    }

    /// <summary>
    /// Class BaseContent.
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public class BaseContent<T>
    {
        /// <summary>
        /// Gets or sets the content.
        /// </summary>
        /// <value>The content.</value>
        [JsonProperty("content")]
        public T Content { get; set; }

        ///// <summary>
        ///// Gets or sets the pageable.
        ///// </summary>
        ///// <value>The pageable.</value>
        //[JsonProperty("pageable")]
        //public BasePageable Pageable { get; set; }

        ///// <summary>
        ///// Gets or sets a value indicating whether this <see cref="BaseContent{T}"/> is last.
        ///// </summary>
        ///// <value><c>true</c> if last; otherwise, <c>false</c>.</value>
        //[JsonProperty("last")]
        //public bool Last { get; set; }

        ///// <summary>
        ///// Gets or sets the total elements.
        ///// </summary>
        ///// <value>The total elements.</value>
        //[JsonProperty("totalElements")]
        //public int TotalElements { get; set; }

        ///// <summary>
        ///// Gets or sets the total pages.
        ///// </summary>
        ///// <value>The total pages.</value>
        //[JsonProperty("totalPages")]
        //public int TotalPages { get; set; }

        ///// <summary>
        ///// Gets or sets the size.
        ///// </summary>
        ///// <value>The size.</value>
        //[JsonProperty("size")]
        //public int Size { get; set; }

        ///// <summary>
        ///// Gets or sets the number.
        ///// </summary>
        ///// <value>The number.</value>
        //[JsonProperty("number")]
        //public int Number { get; set; }

        ///// <summary>
        ///// Gets or sets a value indicating whether this <see cref="BaseContent{T}"/> is sort.
        ///// </summary>
        ///// <value><c>true</c> if sort; otherwise, <c>false</c>.</value>
        //[JsonProperty("sort")]
        //public bool Sort { get; set; }

        ///// <summary>
        ///// Gets or sets the number of elements.
        ///// </summary>
        ///// <value>The number of elements.</value>
        //[JsonProperty("numberOfElements")]
        //public int NumberOfElements { get; set; }

        ///// <summary>
        ///// Gets or sets a value indicating whether this <see cref="BaseContent{T}"/> is first.
        ///// </summary>
        ///// <value><c>true</c> if first; otherwise, <c>false</c>.</value>
        //[JsonProperty("first")]
        //public bool First { get; set; }
    }

    /// <summary>
    /// Class BaseResponseError.
    /// </summary>
    public class BaseResponseError
    {
        /// <summary>
        /// Gets or sets the timestamp.
        /// </summary>
        /// <value>The timestamp.</value>
        [JsonProperty("timestamp")]
        public DateTime Timestamp { get; set; }

        /// <summary>
        /// Gets or sets the status.
        /// </summary>
        /// <value>The status.</value>
        [JsonProperty("status")]
        public int Status { get; set; }

        /// <summary>
        /// Gets or sets the error.
        /// </summary>
        /// <value>The error.</value>
        [JsonProperty("error")]
        public string Error { get; set; }

        /// <summary>
        /// Gets or sets the message.
        /// </summary>
        /// <value>The message.</value>
        [JsonProperty("message")]
        public string Message { get; set; }

        /// <summary>
        /// Gets or sets the path.
        /// </summary>
        /// <value>The path.</value>
        [JsonProperty("path")]
        public string Path { get; set; }
    }

    /// <summary>
    /// Class BaseResponse.
    /// </summary>
    /// <typeparam name="TResult">The type of the t result.</typeparam>
    public class BaseResponse<TResult>
    {
        /// <summary>
        /// Gets or sets the error.
        /// </summary>
        /// <value>The error.</value>
        public BaseResponseError Error { get; set; }
        /// <summary>
        /// Gets or sets the status code.
        /// </summary>
        /// <value>The status code.</value>
        public HttpStatusCode StatusCode { get; set; }
        /// <summary>
        /// Gets or sets the data.
        /// </summary>
        /// <value>The data.</value>
        public TResult Data { get; set; }
        /// <summary>
        /// Gets or sets the exception.
        /// </summary>
        /// <value>The exception.</value>
        public Exception Exception { get; set; }
        /// <summary>
        /// Gets the error message.
        /// </summary>
        /// <value>The error message.</value>
        public string ErrorMessage => Error != null ? string.Format("ERROR: {0} - {1} - {2}", Error.Status, Error.Error, Error.Message) : null;
    }
}
