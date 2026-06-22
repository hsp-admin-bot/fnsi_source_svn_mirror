using ConvertCommon.Common;
using Newtonsoft.Json;
using System;
using System.Net.Http;


namespace ConvertCommon.parts
{
    public  class HttpTool
    {
        private HttpClient _client;

        public HttpTool()
        {
            _client = new HttpClient();
        }

        public T SendRequest<T>(string url, HttpMethod method, object body = null,
                             string contentType = "application/json")
        {
            var request = new HttpRequestMessage(method, url);

            if (!string.IsNullOrEmpty(CommonConfig.token)) {
                request.Headers.Add("Authorization", CommonConfig.token);
            }
            
            request.Headers.Add("Accept", "application/json");

            if (body != null)
            {
                string jsonBody = JsonConvert.SerializeObject(body);
                request.Content = new StringContent(jsonBody, System.Text.Encoding.UTF8, contentType);
            }

            var response = _client.SendAsync(request).Result;
            string StatusCode = response.StatusCode.ToString();

            
            //if (!response.IsSuccessStatusCode)
            //{
            //    throw new HttpRequestException($"HTTP request failed with status code {response.StatusCode}");
            //}

            string responseContent = response.Content.ReadAsStringAsync().Result;

            if (!StatusCode.Equals("OK") && !url.Contains("/login") && !responseContent.Contains("アクセス権なし") )
            {
                throw new Exception("サーバーアプリケーションが停止している可能性があります");
            }
            if (typeof(T) == typeof(string))
            {
                return (T)(object)responseContent;
            }
            else
            {
                return JsonConvert.DeserializeObject<T>(responseContent);
            }
        }
    
    }
}
