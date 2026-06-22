using NKKWebAccessLib;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace CoopEventCreateOrStopTool
{
    static public class MyJson
    {
        static public class Conv<T>
        {
            /// <summary>
            /// JSON文字列 を Tのインスタンス に逆シリアル化します
            /// </summary>
            /// <param name="argJsonStr"></param>
            /// <returns></returns>
            static public T Deserialize(string argJsonStr)
            {
                T ret = default;

                if (false == string.IsNullOrWhiteSpace(argJsonStr))
                {
                    using (var ms = new MemoryStream(NKKWebAccess.Encoding.GetBytes(argJsonStr)))
                    {
                        var dcjs = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T));
                        ret = (T)dcjs.ReadObject(ms);
                    }
                }

                return ret;
            }

            /// <summary>
            /// Tのインスタンス を JSON文字列 にシリアル化します
            /// </summary>
            static public string Serialize(T argT)
            {
                string ret = "";

                if (argT != null)
                {
                    using (var ms = new MemoryStream())
                    {
                        var dcjs = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T));
                        dcjs.WriteObject(ms, argT);
                        ret = NKKWebAccess.Encoding.GetString(ms.ToArray());
                    }
                }

                return ret;
            }

            /// <summary>
            /// JSON文字列のファイル を Tのインスタンス に逆シリアル化します
            /// </summary>
            static public T DeserializeFromFile(string argFilePath)
            {
                T ret = default;

                if (File.Exists(argFilePath))
                {
                    using (var fs = new FileStream(argFilePath, FileMode.Open))
                    {
                        var dcjs = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T));
                        ret = (T)dcjs.ReadObject(fs);
                    }
                }

                return ret;
            }

            /// <summary>
            /// Tのインスタンス を JSON文字列のファイル にシリアル化します
            /// </summary>
            static public void SerializeToFile(T argT, string argFilePath)
            {
                if (argT != null)
                {
                    using (var fs = new FileStream(argFilePath, FileMode.Create))
                    {
                        var dcjs = new System.Runtime.Serialization.Json.DataContractJsonSerializer(typeof(T));
                        dcjs.WriteObject(fs, argT);
                    }
                }
            }
        }

        /// <summary>
        /// 患者情報
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class PatInfo
        {
            // <> NameはJSONキー名／プロパティの型がJSONバリューの型
            [System.Runtime.Serialization.DataMember(Name = "pat_name")]
            public string PatNm { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "pat_id")]
            public string PatId { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "ord_no")]
            public string OrdNo { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "treat_date")]
            public string TreatDate { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "hosp_pat_id")]
            public string HosppatId { get; set; } = "";

            //#9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 start
            [System.Runtime.Serialization.DataMember(Name = "SumNo")]
            public int SumNo { get; set; } = 0;

            [System.Runtime.Serialization.DataMember(Name = "ErrNo")]
            public int ErrNo { get; set; } = 0;

            [System.Runtime.Serialization.DataMember(Name = "SendNo")]
            public int SendNo { get; set; } = 0;
            //#9033 仕様変更　 処理中患者の処理件数/全件と何人目の患者/患者総数を表示する画面 董 end
            //add #9409 検出された患者が全て同姓同名表示がされてしまっている 董 start
            [System.Runtime.Serialization.DataMember(Name = "is_same")]
            public string Isname { get; set; } = "";
            //add #9409 検出された患者が全て同姓同名表示がされてしまっている 董 end
            [System.Runtime.Serialization.DataMember(Name = "ind_user_id")]
            public string IndUserId { get; set; } = "";
        }
    }
}
