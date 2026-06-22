using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using NKKLoggingLib;
using NKKWebAccessLib;

namespace Fnw.StatisticsTool
{
    public static class JsonDataSerializeHelperForNewtonsoft<T>
    {
        public static T Deserialize(string aJsonData)
        {
            if (string.IsNullOrEmpty(aJsonData))
                return default;

            try
            {
                return JsonConvert.DeserializeObject<T>(aJsonData);
            }
            catch (JsonException ex)
            {
                NKKLogging.GetInstance().AddErrorLogInfo(DateTime.Now, StatisticsUtility.PRODUCT_NAME, nameof(JsonDataSerializeHelperForNewtonsoft<T>), NKKLogging.LOGGING_CLASS.ERROR, String.Format("JSONデシリアライズエラー,{0}", ex.ToString().Replace("\r\n", "{CRLF}")));
                return default;
            }
        }
    }

    /// <summary>
    /// JSON データシリアル化及び逆シリアル化ヘルパークラス
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public static class JsonDataSerializeHelper<T>
    {
        /// <summary>
        /// JSON データを T に逆シリアル化したデータを取得します。
        /// </summary>
        /// <param name="aJsonData"></param>
        /// <returns></returns>
        public static T Deserialize(String aJsonData)
        {
            T wRet = default(T);

            if( !String.IsNullOrEmpty(aJsonData) ) {
                using( var wStream = new System.IO.MemoryStream(NKKWebAccess.Encoding.GetBytes(aJsonData)) ) {
                    var settings = new System.Runtime.Serialization.Json.DataContractJsonSerializerSettings
                    {
                        IgnoreExtensionDataObject = true
                    };
                    var wSerializer = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T), settings);
                    wRet = (T)wSerializer.ReadObject(wStream);
                }
            }
            return wRet;
        }

        /// <summary>
        /// T のインスタンスを JSON にシリアル化したデータを文字列で取得します。
        /// </summary>
        /// <param name="aData"></param>
        /// <returns></returns>
        public static String Serialize(T aData)
        {
            String wRet = String.Empty;

            if( aData != null ) {
                using( var wStream = new System.IO.MemoryStream() ) {
                    var wSerializer = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T));
                    wSerializer.WriteObject(wStream, aData);
                    wRet = NKKWebAccess.Encoding.GetString(wStream.ToArray());
                }
            }

            return wRet;
        }
    }
}
