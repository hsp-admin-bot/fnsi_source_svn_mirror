using ConvertCommon.Common;
using ConvertCommon.dto;
using Fnw.IOControl.DB;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Security;
using System.Security.Cryptography.X509Certificates;
using System.Threading;

namespace ConvertCommon.parts
{
    public class HttpControl
    {

        public static string sendWebRequestPost(string url, Dictionary<string, string> Data)
        {
            //add #12338 start
            url = string.Format(url,
                   CommonConfig.ConvertRestWebServerIp,
                   CommonConfig.ConvertRestWebServerPort);
            // mod #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
            if (!string.IsNullOrEmpty(CommonConfig.LoadBalancing) && !url.Contains("server"))
            // mod #12450 コンバート出力後にサーバー処理が続けて実行ができない end
            {
                url += "?" + CommonConfig.LoadBalancing;
            }
            //add #12338 end

            string ret = string.Empty;
            var httpTool = new HttpTool();
            var postData = Data;
            try
            {
                if (string.IsNullOrEmpty(CommonConfig.LoginUrl)) {
                    return null;
                }
                if (url.ToLower().Trim().StartsWith("https"))
                {
                    ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
                    //request.ProtocolVersion = HttpVersion.Version10;
                    ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
                }
                var postResponse = httpTool.SendRequest<string>(url, HttpMethod.Post, postData);
                if (postResponse.Contains("アクセス権なし")) {
                    if (!string.IsNullOrEmpty(GetToken()))
                    {
                        return sendWebRequestPost(url, Data);
                    }
                    else {
                        return null;
                    }
                     
                }
                ConvertBase.WriteTraceLog("サーバー通信情報：{0}", url + JsonConvert.SerializeObject(Data) + "/" + postResponse);
                return postResponse;
            }
            catch (Exception e)
            {
                //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
                ConvertBase.WriteErrorLog("sendWebRequestPost:{0}", url + e.Message);
                //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない end 
                // add #10674 convertdb service is abnormal, Sleep for 30 seconds before making another request zkm start
                Thread.Sleep(30000);
                // add #10674 convertdb service is abnormal, Sleep for 30 seconds before making another request zkm end
                return null;
            }          
        }

        private static string GetToken()
        {
                var httpTool = new HttpTool();
                DBCtrl db = new DBCtrl(null);
                DataTable dt = db.SelectTable("select * from SYNC_LOGIN");
                string user = dt.Rows[0]["LOGIN"].ToString();
                string pass = dt.Rows[0]["PASS"].ToString();
                string url = CommonConfig.LoginUrl;
               //add #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
                url = string.Format(url,
                       CommonConfig.ConvertRestWebServerIp,
                       CommonConfig.ConvertRestWebServerPort);
               if (!string.IsNullOrEmpty(CommonConfig.LoadBalancing) && !url.Contains("server"))
                {
                    url += "?" + CommonConfig.LoadBalancing;
                }
            //add #12450 コンバート出力後にサーバー処理が続けて実行ができない  end

                //add 7997 start
                string facility_cd = string.Join(",", CommonConfig.HashValueSet.Keys);
                var postData = new Dictionary<String, String> { { "login", user }, { "password", pass }, { "facilitycd", facility_cd } };
                //add end start
                try
                {
                    var response = httpTool.SendRequest<string>(url, HttpMethod.Post, postData);
                    JObject jsonObject = JObject.Parse(response);
                   
                    string code = (string)jsonObject["code"];
                    if (code.Equals("200"))
                    {
                        CommonConfig.token = (string)jsonObject["token"];
                         ConvertBase.WriteTraceLog("TOKEN検証成功：", url + JsonConvert.SerializeObject(postData) + "/" + response);
                    }
                    else
                    {
                        CommonConfig.token = null;
                        Environment.Exit(0);
                        ConvertBase.WriteErrorLog("TOKEN検証失敗："+ url + JsonConvert.SerializeObject(postData) + "/" + response);
                    }      
                     return response;
                }
                catch (Exception e)
                {
                     // mod #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
                     ConvertBase.WriteErrorLog("GetToken:{0}", url + e.Message);
                     // mod #12450 コンバート出力後にサーバー処理が続けて実行ができない end 
                return null;
                }

        }
        /// <summary>
        /// httpリクエストを送信してレスポンスを返す
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string sendWebRequest(string url)
        {
            string ret;

            //mod https追加 李 start
            if (url.ToLower().Trim().StartsWith("https"))
            {
                ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
                //request.ProtocolVersion = HttpVersion.Version10;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            }
            HttpWebRequest request = (HttpWebRequest)WebRequest.CreateHttp(new Uri(url));
            request.Method = "GET";
            WebResponse response;
            request.Headers.Add("Authorization", CommonConfig.token);
            try
            {
                response = (HttpWebResponse)request.GetResponse();
                //response = request.GetResponse();
            }
            catch (Exception e)
            {
                ConvertBase.WriteErrorLog("sendWebRequest:{0}", e.Message);
                return null;
            }
            //mod https追加 李 end

            using (Stream dataStream = response.GetResponseStream())
            {
                // 簡単にアクセスできるようにStreamReaderを使用してストリームを開く  
                StreamReader reader = new StreamReader(dataStream);
                // 内容を読む
                ret = reader.ReadToEnd();
            }

            response.Close();
            ConvertBase.WriteTraceLog("ファイル圧縮中:{0}", ret);
            return ret;

        }

        //add #7403 2022-05-31 鄭  start
        public static string getpatConvertTableLog(string url)
        {
            string body = sendWebRequest(url);
            if (body == null)
            {
                return "";
            }
            //var ret = JsonUtility.Deserialize<DataTable>(body);
            return body;
        }
        //add #7403 2022-05-31 鄭  end
        /// <summary>
        /// httpリクエストを送信してレスポンスを返す
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static string sendPostWebRequest(string postUrl, string contentType, byte[] formData, Dictionary<string, object> postParameters)
        {
            //add #12338 start
            //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない start 
            if (!string.IsNullOrEmpty(CommonConfig.LoadBalancing) && !postUrl.Contains("server"))
            //mod #12450 コンバート出力後にサーバー処理が続けて実行ができない end 
            {
                postUrl += "?" + CommonConfig.LoadBalancing;
            }
            //add #12338 end
            if (string.IsNullOrEmpty(CommonConfig.LoginUrl))
            {
                return "サーバ側アプリケーションに接続できません。";
            }
            string ret="";

            //add https追加 李 start
            if (postUrl.ToLower().Trim().StartsWith("https"))
            {
                ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
                //request.ProtocolVersion = HttpVersion.Version10;
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            }
            //add https追加 李 end

            HttpWebRequest request = WebRequest.Create(postUrl) as HttpWebRequest;
            if (request == null)
            {
              throw new NullReferenceException("Invalid HTTP Request");
            }
            request.Method = "POST";
            request.ContentType = contentType;
            request.ContentLength = formData.Length;
            request.Headers.Add("Authorization", CommonConfig.token);
            HttpWebResponse response;
            try
            {
              using (Stream requestStream = request.GetRequestStream())
              {
              requestStream.Write(formData, 0, formData.Length);
              requestStream.Close();
              }
              response = request.GetResponse() as HttpWebResponse;
            }
            catch (Exception e)
            {
                response = null;
                 ConvertBase.WriteErrorLog("サーバー通信失敗：" + postUrl + JsonConvert.SerializeObject(postParameters) + "/" + e.Message);
                if (e.Message.Contains("許可されていません"))
                {
                    if (!string.IsNullOrEmpty(GetToken()))
                    {
                        return sendPostWebRequest(postUrl, contentType, formData, postParameters);
                    }
                    else {
                        ret = "サーバ側アプリケーションに接続できません。";
                    }
                        
                }
                else {
                    ret = "サーバ側アプリケーションに接続できません。";
                }                
                //ret = "サーバに接続できませんでした。"; 
            }

            if(response != null)
            {
              using (Stream dataStream = response.GetResponseStream())
              {
                StreamReader reader = new StreamReader(dataStream);
                ret = reader.ReadToEnd();
              }
              response.Close();
            }
            if (ret.Contains("ファイル転送が完了した")) { 
              ConvertBase.WriteTraceLog("サーバー通信成功：{0}", postUrl+JsonConvert.SerializeObject(postParameters) + "/" + ret);
            }
            return ret;
        }

        /// <summary>
        /// リクエストを送信してバッチ進捗をJSON形式で取得し、
        /// デシリアライズする
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static IList<BatchConvertStatusDto> getBatchConvertStatus(string facilityCd,string url)
        {
            //string body = sendWebRequest(url);
            string facility_Cd = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(facilityCd, out var value))
            {
                facility_Cd = $"[\"{value}\"]";
            }
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", facility_Cd } };
            string body = sendWebRequestPost(url, parameters);
            if (body == null)
            {
              return new List<BatchConvertStatusDto>();
            }
            var ret = JsonUtility.Deserialize<IList<BatchConvertStatusDto>>(body);
            return ret;
        }

        /// <summary>
        /// リクエストを送信してバッチ進捗（テーブル毎）をJSON形式で取得し、
        /// デシリアライズする
        /// </summary>
        /// <param name="url"></param>
        /// <returns></returns>
        public static IList<BatchConvertTableStatusDto> getBatchConvertTableStatus(string url,string fCd, string no)
        {
            //string body = sendWebRequest(url);
            string facilityCd = string.Empty;
            if (CommonConfig.HashValueSet.TryGetValue(fCd, out var value))
            {
                facilityCd = $"[\"{value}\"]";

            }
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", facilityCd }, { "orderNo", no } };
            string body = sendWebRequestPost(url, parameters);
            if (body == null)
            {
              return new List<BatchConvertTableStatusDto>();
            }
            var ret = JsonUtility.Deserialize<IList<BatchConvertTableStatusDto>>(body);
            return ret;
        }
        public static IList<BatchConvertTableLogDto> getBatchConvertTableLog(string url,string orderNo,string facilityCd)
        {
            Dictionary<string, string> parameters = new Dictionary<String, String> { { "facilityCd", facilityCd }, { "orderNo", orderNo } };
            // string body = sendWebRequest(url);
            string body = sendWebRequestPost(url, parameters);
            if (body == null)
            {
              return new List<BatchConvertTableLogDto>();
            }
            var ret = JsonUtility.Deserialize<IList<BatchConvertTableLogDto>>(body);
            return ret;
        }

        public static Boolean isFNsiConnection(string url)
        {
            //mod FNSI-ログ追加 楊 start
            //string body = sendWebRequest(url);
            //if (body != null)
            //  return true;
            //else
            //  return false;
            ConvertBase.WriteTraceLog("FNSiに接続します。");
            Dictionary<string, string> postParameters = new Dictionary<string, string>();
            string body = sendWebRequestPost(url,postParameters);
            if (body != null && body.Equals("true"))
            {
                ConvertBase.WriteTraceLog("FNSi接続に成功しました。");
                return true;
            } else {
                //ConvertBase.WriteTraceLog("FNSi接続に失敗しました。");
                ConvertBase.WriteErrorLog("FNSi接続に失敗しました。");
                return false;
            }
            //mod FNSI-ログ追加 楊 end
        }

        //add https追加　李 end
        protected static bool CheckValidationResult(object sender, X509Certificate certificate, X509Chain chain, SslPolicyErrors errors)
        {
            return true;
        }
        //add https追加　李 end

        // add #10753 djy start
        public static bool fnsiHealthCheck(string url)
        {
            bool ret = false;
            // add https追加 limingyang 20230728 start
            if (url.ToLower().Trim().StartsWith("https"))
            {
                ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            }
            // add https追加 limingyang 20230728 end
            HttpWebRequest request = (HttpWebRequest)WebRequest.CreateHttp(new Uri(url));
            request.Method = "GET";
            WebResponse response;
            try
            {
                response = (HttpWebResponse)request.GetResponse();
            }
            catch (Exception e)
            {
                ConvertBase.WriteErrorLog("fnsiHealthCheck:{0}", e.Message);
                return false;
            }

            using (Stream dataStream = response.GetResponseStream())
            {
                // 簡単にアクセスできるようにStreamReaderを使用してストリームを開く  
                StreamReader reader = new StreamReader(dataStream);
                // 内容を読む
                if ("true".Equals(reader.ReadToEnd()))
                {
                    ret = true;
                }
            }
            response.Close();

            return ret;
        }
        // add #10753 djy end

        // add #10856 コンバータツールのインストーラに内包物と設定が不足している limingyang start
        public static bool fnsiHealthCheck(string url, ref string ex)
        {
            bool ret = false;
            if (url.ToLower().Trim().StartsWith("https"))
            {
                ServicePointManager.ServerCertificateValidationCallback = new RemoteCertificateValidationCallback(CheckValidationResult);
                ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            }
            HttpWebRequest request = (HttpWebRequest)WebRequest.CreateHttp(new Uri(url));
            request.Method = "GET";
            WebResponse response;
            try
            {
                response = (HttpWebResponse)request.GetResponse();
            }
            catch (Exception e)
            {
                ex = e.Message;
                return false;
            }

            using (Stream dataStream = response.GetResponseStream())
            {
                StreamReader reader = new StreamReader(dataStream);
                if ("true".Equals(reader.ReadToEnd()))
                {
                    ret = true;
                }
            }
            response.Close();
            return ret;
        }
        // add #10856 コンバータツールのインストーラに内包物と設定が不足している limingyang end

    }
}
