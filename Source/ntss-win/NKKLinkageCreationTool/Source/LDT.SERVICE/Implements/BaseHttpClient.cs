using LDT.LOG;
using LDT.SERVICE.Configuration;
using LDT.SERVICE.Cookies;
using LDT.SERVICE.Enums;
using LDT.SERVICE.Extendsions;
using LDT.SERVICE.Interfaces;
using LDT.SERVICE.Models.Responses;
using Newtonsoft.Json;
using System;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Text;
using System.Threading.Tasks;

namespace LDT.SERVICE.Implements
{
  public class BaseHttpClient : IBaseHttpClient
  {
    private HttpClient _httpClient;
    private HttpRequestMessage _httpRequestMessage;
    public CookieContainer cookies = new CookieContainer();
    private HttpClientHandler handler = new HttpClientHandler();

    CookieContainer IBaseHttpClient.Cookies { get => cookies; }

    public BaseHttpClient()
    {
      handler.CookieContainer = cookies;
      if (this._httpClient == null)
      {
        this._httpClient = new HttpClient(handler, true);
      }
    }

    public async Task<BaseResponse<T>> DeleteAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      return await CommonSendHTTP<T>(RequestMethod.DELETE, url, content, IsAddHeader, IsUseBody, timeout, application);
    }

    public async Task<BaseResponse<T>> GetAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      return await CommonSendHTTP<T>(RequestMethod.GET, url, content, IsAddHeader, IsUseBody, timeout, application);
    }

    public async Task<BaseResponse<T>> PostAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      return await CommonSendHTTP<T>(RequestMethod.POST, url, content, IsAddHeader, IsUseBody, timeout, application);
    }

    public async Task<BaseResponse<T>> PutAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      return await CommonSendHTTP<T>(RequestMethod.PUT, url, content, IsAddHeader, IsUseBody, timeout, application);
    }

    private async Task<BaseResponse<T>> CommonSendHTTP<T>(RequestMethod method, string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      BaseResponse<T> response = new BaseResponse<T>();
      try
      {
        string urlRequest = CombineRequestURL(url);
        var request = await this.HandleRequest(method, urlRequest, content, IsAddHeader, IsUseBody, timeout, application);
        response = await this.HandleResponse<T>(request);
      }
      catch (Exception ex)
      {
        LogHelper.LogError(ex.Message, ex);
        response.Exception = ex;
        response.Data = default(T);
        Console.WriteLine(ex);
      }

      return response;
    }

    private string GetBaseURL()
    {
      return string.Format("{0}/{1}", AppSettingConfig.ApplicationConfigJSON.API.BASE_DOMAIN, AppSettingConfig.ApplicationConfigJSON.API.BASE_URL);
    }

    private string CombineRequestURL(string requestURL)
    {
      string baseURL = this.GetBaseURL();
      string urlCombine = string.Format("{0}/{1}", baseURL, requestURL);
      return urlCombine;
    }

    private async Task<HttpResponseMessage> HandleRequest(RequestMethod requestMethod, string url, object content, bool IsAddHeader = true, bool IsUseBody = false, int timeout = 100000, string application = "application/json")
    {
      this._httpRequestMessage = new HttpRequestMessage()
      {
        RequestUri = new Uri(url)
      };
      this._httpRequestMessage.Headers.Accept.Clear();
      this._httpRequestMessage.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue(application));
      if (IsAddHeader)
      {
        var cookieValue = CookieManager.GetCookies();
        if (cookieValue.Count > 0)
        {
          this.handler = new HttpClientHandler
          {
            CookieContainer = cookieValue
          };
          this._httpRequestMessage.Headers.Add("X-XSRF-TOKEN", CookieManager.GetToken("XSRF-TOKEN"));
          this._httpClient = new HttpClient(this.handler, true);
        }
      }
      this._httpClient.Timeout.Add(TimeSpan.FromSeconds(timeout));
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };
      switch (requestMethod)
      {
        case RequestMethod.POST:
          {
            if (IsUseBody)
            {
              var json = JsonConvert.SerializeObject(content, settings);
              this._httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                    application);
            }
            else
            {
              this._httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
            }
            _httpRequestMessage.Method = HttpMethod.Post;
            LogHelper.LogDebug(this._httpRequestMessage);
            break;
          }
        case RequestMethod.PUT:
          {
            if (IsUseBody)
            {
              var json = JsonConvert.SerializeObject(content, settings);
              this._httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                    application);
            }
            else
            {
              this._httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
            }
            _httpRequestMessage.Method = HttpMethod.Put;
            LogHelper.LogDebug(this._httpRequestMessage);
            break;
          }
        case RequestMethod.DELETE:
          {
            if (IsUseBody)
            {
              var json = JsonConvert.SerializeObject(content, settings);
              this._httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                    application);
            }
            else
            {
              this._httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
            }
            _httpRequestMessage.Method = HttpMethod.Delete;
            LogHelper.LogDebug(this._httpRequestMessage);
            break;
          }
        case RequestMethod.GET:
          {
            _httpRequestMessage.Method = HttpMethod.Get;
            LogHelper.LogDebug(this._httpRequestMessage);
            break;
          }
      }
      HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
      try
      {
        httpResponseMessage = await this._httpClient.SendAsync(this._httpRequestMessage);
      }
      catch (Exception ex)
      {
        Console.WriteLine(ex);
        LogHelper.LogError(nameof(HttpResponseMessage), ex);
      }
      return httpResponseMessage;
    }

    private async Task<BaseResponse<TResult>> HandleResponse<TResult>(HttpResponseMessage httpResponseMessage)
    {
      BaseResponse<TResult> result = new BaseResponse<TResult>();
      var content = await httpResponseMessage.Content.ReadAsStringAsync();
      Console.WriteLine(content);
      var settings = new JsonSerializerSettings
      {
        NullValueHandling = NullValueHandling.Ignore,
        MissingMemberHandling = MissingMemberHandling.Ignore
      };

      result.StatusCode = httpResponseMessage.StatusCode;
      if (httpResponseMessage.StatusCode == HttpStatusCode.OK)
      {
        result.Data = JsonConvert.DeserializeObject<TResult>(content, settings);
      }
      else
      {
        try
        {
          result.Error = JsonConvert.DeserializeObject<BaseResponseError>(content, settings);
        }
        catch (Exception _)
        {
          LogHelper.LogError("RESPONSE ERROR", new Exception(content));
        }
      }
      return result;
    }
  }
}
