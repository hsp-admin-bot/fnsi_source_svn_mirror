// ***********************************************************************
// Assembly         : CoopSettingTool.Service
// Author           : Phan Hai Thach
// Created          : 04-16-2021
//
// Last Modified By : Phan Hai Thach
// Last Modified On : 05-31-2021
// ***********************************************************************
// <copyright file="ServerAccess.cs" company="">
//     Copyright©2021 NIKKISO CO., LTD. All Rights Reserved 
// </copyright>
// <summary></summary>
// ***********************************************************************
using CoopSettingTool.Log;
using CoopSettingTool.Service.Configuration;
using CoopSettingTool.Service.Enums;
using CoopSettingTool.Service.Extendsions;
using CoopSettingTool.Service.Models;
using Newtonsoft.Json;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Net;
using System.Net.Http;
using System.Reflection;
using System.Security.Cryptography.X509Certificates;
using System.Text;
using System.Threading.Tasks;

namespace CoopSettingTool.Service
{
    /// <summary>
    /// Class ServerAccess.
    /// </summary>
    public class ServerAccess
    {
        #region プライベート属性

        /// <summary>
        /// The DefaultTimeOut
        /// </summary>
        private const int DefaultTimeOut = 30;

        /// <summary>
        /// The instance
        /// </summary>
        private static volatile ServerAccess _Instance = null;

        /// <summary>
        /// HttpClientオブジェクト
        /// </summary>
        private HttpClient _httpClient;

        /// <summary>
        /// HttpRequestMessageオブジェクト
        /// </summary>
        private HttpRequestMessage _httpRequestMessage;

        /// <summary>
        /// Cookie
        /// </summary>
        private CookieContainer _cookies;

        /// <summary>
        /// WebRequestHandlerオブジェクト
        /// </summary>
        private WebRequestHandler _handler;

        /// <summary>
        /// ユーザーID
        /// </summary>
        private string _userId;

        /// <summary>
        /// パスワード
        /// </summary>
        private string _password;

        /// <summary>
        /// OTP
        /// </summary>
        private string _otp;

        /// <summary>
        /// 施設コード
        /// </summary>
        private string _facilityCd;

        /// <summary>
        /// ユーザー番号
        /// </summary>
        private long _userNo;

        /// <summary>
        /// ログイン状態フラグ
        /// </summary>
        private bool _isSignedIn;

        /// <summary>
        /// 利用者種別
        /// </summary>
        private long _userType;

        #endregion

        #region #region パブリックプロパティ

        /// <summary>
        /// Cookie
        /// </summary>
        /// <value>The cookies.</value>
        CookieContainer Cookies { get => _cookies; }

        /// <summary>
        /// WebRequestHandlerオブジェクト
        /// </summary>
        /// <value>The handler.</value>
        WebRequestHandler Handler
        {
            get
            {
                return _handler;
            }
            set
            {
                if (_handler != null)
                {
                    _handler.Dispose();
                }

                _handler = value;
                _cookies = new CookieContainer();
                _handler.CookieContainer = _cookies;
            }
        }

        /// <summary>
        /// HttpClientオブジェクト
        /// </summary>
        /// <value>The HTTP client.</value>
        public HttpClient HttpClient
        {
            get { return _httpClient; }
            set
            {
                //
                if (_httpClient != null)
                {
                    _httpClient.Dispose();
                }

                _httpClient = value;

                // タイムアウト時間設定(30秒)
                _httpClient.Timeout = TimeSpan.FromSeconds(DefaultTimeOut);
            }
        }

        /// <summary>
        /// 施設コード
        /// </summary>
        /// <value>The facility cd.</value>
        public string FacilityCd { get => _facilityCd; }

        /// <summary>
        /// ログイン状態フラグ
        /// </summary>
        /// <value><c>true</c> if this instance is signed in; otherwise, <c>false</c>.</value>
        public bool IsSignedIn { get => _isSignedIn; }

        /// <summary>
        /// 利用者種別
        /// </summary>
        /// <value>The type of the user.</value>
        public long UserType { get => _userType; }

        /// <summary>
        /// ユーザー番号
        /// </summary>
        /// <value>The user no.</value>
        public long UserNo { get => _userNo; }

        #endregion

        /// <summary>
        /// コンストラクタ
        /// </summary>
        private ServerAccess()
        {

        }

        /// <summary>
        /// 処理オブジェクト取得
        /// </summary>
        /// <returns>ServerAccess.</returns>
        public static ServerAccess GetInstance()
        {
            if (_Instance == null)
            {
                if (_Instance == null)
                    _Instance = new ServerAccess();
            }

            return (_Instance);
        }

        /// <summary>
        /// 指定したキーでクライアント証明書を取得する
        /// </summary>
        /// <param name="strValue1">検索用のキー値1</param>
        /// <param name="strValue2">検索用のキー値2</param>
        /// <returns>null：合致なし/else：取得したX509証明書</returns>
        private X509Certificate2Collection GetX509Certificate(String strValue1, String strValue2)
        {
            X509Certificate2Collection ret = null;

            // ログ記録：
            LogHelper.LogInfo("クライアント証明書取得開始, 検索キー:" + strValue1 + " / " + strValue2);


            // 証明書ストアの情報取得
            StoreLocation[] stores = (StoreLocation[])Enum.GetValues(typeof(StoreLocation));
            StoreName[] storeNames = (StoreName[])Enum.GetValues(typeof(StoreName));

            // 証明書ストアの場所分
            for (int intlop1 = 0; ret == null && intlop1 < stores.Length; intlop1++)
            {
                StoreLocation storeLocation = stores[intlop1];

                //　証明書ストアの名前分
                for (int intlop2 = 0; ret == null && intlop2 < storeNames.Length; intlop2++)
                {
                    // 場所と名前を指定して証明書ストアを作成
                    X509Store store = new X509Store(storeNames[intlop2], storeLocation);

                    try
                    {
                        // 証明書ストアを開く
                        store.Open(OpenFlags.OpenExistingOnly | OpenFlags.ReadOnly);

                        // 証明書の一覧を取得
                        X509Certificate2Collection findResult = store.Certificates;

                        // 現時点の日付で有効な証明書に絞り込む
                        findResult = findResult.Find(X509FindType.FindByTimeValid, DateTime.Now, false);
                        // サブジェクト名から検索キー値1で証明書を絞り込む
                        findResult = findResult.Find(X509FindType.FindBySubjectName, strValue1, false);
                        // サブジェクト名から検索キー値2で証明書を絞り込む
                        findResult = findResult.Find(X509FindType.FindBySubjectName, strValue2, false);
                        if (0 < findResult.Count)
                        {
                            ret = findResult;
                            //LogHelper.LogInfo("クライアント証明書取得, 表示名:" + ret.FriendlyName + "/サブジェクト名：" + ret.SubjectName.Name);
                        }
                    }
                    catch (Exception ex)
                    {
                        // ログ記録
                        LogHelper.LogError(String.Format("クライアント証明書取得失敗,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                    }
                    finally
                    {
                        store.Close();
                    }
                }
            }

            // ログ記録：
            if (ret != null)
            {
                LogHelper.LogInfo("クライアント証明書取得終了");
            }
            else
            {
                LogHelper.LogError("クライアント証明書取得終了, 合致なし");
            }
            return ret;
        }

        /// <summary>
        /// delete as an asynchronous operation.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>A Task&lt;BaseResponse`1&gt; representing the asynchronous operation.</returns>
        public async Task<BaseResponse<T>> DeleteAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            return await CommonSendHTTP<T>(RequestMethod.DELETE, url, content, IsAddHeader, IsUseBody, application);
        }

        /// <summary>
        /// get as an asynchronous operation.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>A Task&lt;BaseResponse`1&gt; representing the asynchronous operation.</returns>
        public async Task<BaseResponse<T>> GetAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            return await CommonSendHTTP<T>(RequestMethod.GET, url, content, IsAddHeader, IsUseBody, application);
        }

        /// <summary>
        /// post as an asynchronous operation.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>A Task&lt;BaseResponse`1&gt; representing the asynchronous operation.</returns>
        public async Task<BaseResponse<T>> PostAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            return await CommonSendHTTP<T>(RequestMethod.POST, url, content, IsAddHeader, IsUseBody, application);
        }

        /// <summary>
        /// put as an asynchronous operation.
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>A Task&lt;BaseResponse`1&gt; representing the asynchronous operation.</returns>
        public async Task<BaseResponse<T>> PutAsync<T>(string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            return await CommonSendHTTP<T>(RequestMethod.PUT, url, content, IsAddHeader, IsUseBody, application);
        }

        /// <summary>
        /// ログイン処理
        /// </summary>
        /// <param name="username">The username.</param>
        /// <param name="password">The password.</param>
        /// <param name="otp">The otp.</param>
        /// <returns>BaseResponse&lt;LoginResponseEntity&gt;.</returns>
        public async Task<BaseResponse<LoginResponseEntity>> SignIn(string username, string password, string otp)
        {
            //// WebRequestHandler構築
            Handler = new WebRequestHandler();

            if (!string.IsNullOrEmpty(AppSettingConfig.ApplicationConfigJSON.API.CLIENT_CERTIFIATE_SEARCH_VALUE_1)
                || !string.IsNullOrEmpty(AppSettingConfig.ApplicationConfigJSON.API.CLIENT_CERTIFIATE_SEARCH_VALUE_2))
            {
                var cer = GetX509Certificate(AppSettingConfig.ApplicationConfigJSON.API.CLIENT_CERTIFIATE_SEARCH_VALUE_1
                    , AppSettingConfig.ApplicationConfigJSON.API.CLIENT_CERTIFIATE_SEARCH_VALUE_2);
                if (cer != null)
                {
                    Handler.ClientCertificates.AddRange(cer);
                    Handler.ClientCertificateOptions = ClientCertificateOption.Manual;
                }
                else
                {
                    return new BaseResponse<LoginResponseEntity>() { StatusCode = HttpStatusCode.BadRequest, Error = new BaseResponseError() {　Message　= "クライアント証明書が見つからない。" } };
                }
            }

            //// HttpClient構築
            HttpClient = new HttpClient(Handler);

            var usr = new LoginRequest()
            {
                FacilityCd = System.Web.HttpUtility.UrlDecode(AppSettingConfig.ApplicationConfigJSON.API.FACILITY_CD),
                Password = password,
                UserId = username
            };

            if (!string.IsNullOrWhiteSpace(otp))
            {
                usr.OtpCd = otp;
            }

            var response = await CommonSendHTTP<LoginResponseEntity>(RequestMethod.POST, Constant.LOGIN_URL, usr, false);

            if (response.StatusCode == HttpStatusCode.OK)
            {
                LoginResponseEntity loginResponseEntity = response.Data as LoginResponseEntity;
                if (!string.IsNullOrEmpty(loginResponseEntity.FacilityCode))
                {
                    this._facilityCd = loginResponseEntity.FacilityCode;
                    this._userNo = loginResponseEntity.UserId;
                    this._userType = loginResponseEntity.UserType;
                    this._isSignedIn = true;
                    this._userId = username;
                    this._password = password;
                    this._otp = otp;
                }
                else
                {
                    this._isSignedIn = false;
                }
            }

            return response;
        }

        /// <summary>
        /// HTTP送信する
        /// </summary>
        /// <typeparam name="T"></typeparam>
        /// <param name="method">The method.</param>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>BaseResponse&lt;T&gt;.</returns>
        private async Task<BaseResponse<T>> CommonSendHTTP<T>(RequestMethod method, string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            BaseResponse<T> response = new BaseResponse<T>();
            try
            {
                string urlRequest = CombineRequestURL(url);
                var httpResponse = await HandleRequest(method, urlRequest, content, IsAddHeader, IsUseBody, application);
                response = await HandleResponse<T>(httpResponse);
            }
            catch (Exception ex)
            {
                LogHelper.LogError(ex.Message, ex);
                response.Data = default(T);
                Console.WriteLine(ex);
            }

            return response;
        }

        /// <summary>
        /// Gets the base URL.
        /// </summary>
        /// <returns>System.String.</returns>
        private string GetBaseURL()
        {
            return string.Format("{0}/{1}", AppSettingConfig.ApplicationConfigJSON.API.BASE_DOMAIN, Constant.BASE_URL);
        }

        /// <summary>
        /// リクェストURLを作成する
        /// </summary>
        /// <param name="requestURL">The request URL.</param>
        /// <returns>System.String.</returns>
        private string CombineRequestURL(string requestURL)
        {
            string baseURL = GetBaseURL();
            string urlCombine = string.Format("{0}/{1}", baseURL, requestURL);
            return urlCombine;
        }

        /// <summary>
        /// Tokenを取得する
        /// </summary>
        /// <param name="keyToken">The key token.</param>
        /// <returns>System.String.</returns>
        private string GetToken(string keyToken)
        {
            var result = "";
            var table = (Hashtable)_cookies.GetType().InvokeMember("m_domainTable",
              BindingFlags.NonPublic |
              BindingFlags.GetField |
              BindingFlags.Instance,
              null,
              _cookies,
              null);

            foreach (string key in table.Keys)
            {
                var item = table[key];
                var items = (ICollection)item.GetType().GetProperty("Values").GetGetMethod().Invoke(item, null);
                foreach (CookieCollection cc in items)
                {
                    foreach (Cookie cookie in cc)
                    {
                        Console.WriteLine(cookie.Value);
                        if (cookie.Name == keyToken)
                        {
                            result = cookie.Value;
                            break;
                        }
                    }
                }
            }
            return result;
        }

        /// <summary>
        /// リクェストを処理する
        /// </summary>
        /// <param name="requestMethod">The request method.</param>
        /// <param name="url">The URL.</param>
        /// <param name="content">The content.</param>
        /// <param name="IsAddHeader">if set to <c>true</c> [is add header].</param>
        /// <param name="IsUseBody">if set to <c>true</c> [is use body].</param>
        /// <param name="timeout">The timeout.</param>
        /// <param name="application">The application.</param>
        /// <returns>HttpResponseMessage.</returns>
        private async Task<HttpResponseMessage> HandleRequest(RequestMethod requestMethod, string url, object content, bool IsAddHeader = true, bool IsUseBody = false, string application = "application/json")
        {
            _httpRequestMessage = new HttpRequestMessage()
            {
                RequestUri = new Uri(url)
            };
            _httpRequestMessage.Headers.Accept.Clear();
            _httpRequestMessage.Headers.Accept.Add(new System.Net.Http.Headers.MediaTypeWithQualityHeaderValue(application));
            if (IsAddHeader)
            {
                if (_cookies.Count > 0)
                {
                    _httpRequestMessage.Headers.Add("X-XSRF-TOKEN", GetToken("XSRF-TOKEN"));
                }
            }

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
                            _httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                                  application);
                        }
                        else
                        {
                            _httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
                        }
                        _httpRequestMessage.Method = HttpMethod.Post;
                        LogHelper.LogDebug(_httpRequestMessage);
                        break;
                    }
                case RequestMethod.PUT:
                    {
                        if (IsUseBody)
                        {
                            var json = JsonConvert.SerializeObject(content, settings);
                            _httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                                  application);
                        }
                        else
                        {
                            _httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
                        }
                        _httpRequestMessage.Method = HttpMethod.Put;
                        LogHelper.LogDebug(_httpRequestMessage);
                        break;
                    }
                case RequestMethod.DELETE:
                    {
                        if (IsUseBody)
                        {
                            var json = JsonConvert.SerializeObject(content, settings);
                            _httpRequestMessage.Content = new System.Net.Http.StringContent(json, Encoding.UTF8,
                                                  application);
                        }
                        else
                        {
                            _httpRequestMessage.Content = new FormUrlEncodedContent(content != null ? content.ToDictionary<string>() : new Dictionary<string, string>());
                        }
                        _httpRequestMessage.Method = HttpMethod.Delete;
                        LogHelper.LogDebug(_httpRequestMessage);
                        break;
                    }
                case RequestMethod.GET:
                    {
                        _httpRequestMessage.Method = HttpMethod.Get;
                        LogHelper.LogDebug(_httpRequestMessage);
                        break;
                    }
            }
            HttpResponseMessage httpResponseMessage = new HttpResponseMessage();
            try
            {
                httpResponseMessage = await _httpClient.SendAsync(_httpRequestMessage);
                LogHelper.LogDebug(httpResponseMessage);
            }
            catch(TaskCanceledException ex)
            {
                Console.WriteLine(ex);
                LogHelper.LogError(nameof(HttpResponseMessage), ex);
                throw (ex);
            }
            catch (Exception ex)
            {
                Console.WriteLine(ex);
                LogHelper.LogError(nameof(HttpResponseMessage), ex);
                throw (ex);
            }
            return httpResponseMessage;
        }

        /// <summary>
        /// レスポンスを処理する
        /// </summary>
        /// <typeparam name="TResult">The type of the t result.</typeparam>
        /// <param name="httpResponseMessage">The HTTP response message.</param>
        /// <returns>BaseResponse&lt;TResult&gt;.</returns>
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
                catch (Exception )
                {
                    LogHelper.LogError("RESPONSE ERROR", new Exception(content));
                }
            }
            return result;
        }
    }
}
