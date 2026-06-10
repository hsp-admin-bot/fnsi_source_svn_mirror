using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using NKKWebAccessLib;

namespace LayoutDesigner
{
    /// <summary>
    /// JSON データシリアル化及び逆シリアル化ヘルパークラス
    /// </summary>
    /// <typeparam name="T"></typeparam>
    public static class RldJsonDataSerializeHelper<T>
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
