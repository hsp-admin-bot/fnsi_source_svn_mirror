using Newtonsoft.Json;
using System;
using System.Net;

namespace LDT.SERVICE.Models.Responses
{
  public class BasePageable
    {
        [JsonProperty("content")]
        public string Sort { get; set; }

        [JsonProperty("offset")]
        public int Offset { get; set; }

        [JsonProperty("pageSize")]
        public int Pagesize { get; set; }

        [JsonProperty("pageNumber")]
        public int PageNumber { get; set; }

        [JsonProperty("unpaged")]
        public bool Unpaged { get; set; }

        [JsonProperty("paged")]
        public bool Paged { get; set; }
    }

    public class BaseContent<T>
    {
        [JsonProperty("content")]
        public T Content { get; set; }

        [JsonProperty("pageable")]
        public BasePageable Pageable { get; set; }

        [JsonProperty("last")]
        public bool Last { get; set; }

        [JsonProperty("totalElements")]
        public int TotalElements { get; set; }

        [JsonProperty("totalPages")]
        public int TotalPages { get; set; }

        [JsonProperty("size")]
        public int Size { get; set; }

        [JsonProperty("number")]
        public int Number { get; set; }

        [JsonProperty("sort")]
        public bool Sort { get; set; }

        [JsonProperty("numberOfElements")]
        public int NumberOfElements { get; set; }

        [JsonProperty("first")]
        public bool First { get; set; }
    }

    public class BaseResponseError
    {
        [JsonProperty("timestamp")]
        public DateTime Timestamp { get; set; }

        [JsonProperty("status")]
        public int Status { get; set; }

        [JsonProperty("error")]
        public string Error { get; set; }

        [JsonProperty("message")]
        public string Message { get; set; }

        [JsonProperty("path")]
        public string Path { get; set; }
    }

    public class BaseResponse<TResult>
    {
        public BaseResponseError Error { get; set; }
        public HttpStatusCode StatusCode { get; set; }
        public TResult Data { get; set; }
        public Exception Exception { get; set; }
        public string ErrorMessage => Error != null ? string.Format("ERROR: {0} - {1} - {2}", Error.Status, Error.Error, Error.Message) : null;
    }
}
