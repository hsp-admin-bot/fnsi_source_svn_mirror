using NKKWebAccessLib;
using System.Diagnostics;
using System.IO;
using System.Windows.Forms;

namespace NKK.BloodPurify
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
        /// 特殊浄化治療のOrdNo等の情報
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class BloodPurifyOrdInfo
        {
            // <> NameはJSONキー名／プロパティの型がJSONバリューの型
            [System.Runtime.Serialization.DataMember(Name = "ordNo")]
            public long OrdNo { get; set; } = 0;

            [System.Runtime.Serialization.DataMember(Name = "bedName")]
            public string BedName { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "isSame")]
            public bool IsSame { get; set; } = false;

            [System.Runtime.Serialization.DataMember(Name = "patName")]
            public string PatName { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "inOutClass")]
            public int InOutClass { get; set; } = 0;

            [System.Runtime.Serialization.DataMember(Name = "dialysisState")]
            public string DialysisState { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "kurName")]
            public string KurName { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "kurStartTime")]
            public string KurStartTime { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "kurEndTime")]
            public string KurEndTime { get; set; } = "";

            // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 start
            [System.Runtime.Serialization.DataMember(Name = "hosp_pat_id")]  // 患者ID
            public string hospPatID { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "rst_treatment_name")]  // 治療方法名
            public string RstTreatmentName { get; set; } = "";
            // add 2020-08-04 FNSI-仕様追加 モニタ詳細画面に患者情報を表示する 李 end
            // </>

            public string ParseNull(string argStr)
            {
                return (string.IsNullOrWhiteSpace(argStr) ? "" : argStr);
            }
        }

        /// <summary>
        /// クールの情報
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class KurInfo
        {
            // <> NameはJSONキー名／プロパティの型がJSONバリューの型
            [System.Runtime.Serialization.DataMember(Name = "kurName")]
            public string KurName { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "kurStartTime")]
            public string KurStartTime { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "kurEndTime")]
            public string KurEndTime { get; set; } = "";
            // </>

            public string ParseNull(string argStr)
            {
                return (string.IsNullOrWhiteSpace(argStr) ? "" : argStr);
            }
        }

        // add 2020-08-04 FNSI-仕様追加 装置マスタに「特殊浄化通信アプリ使用選択」、「特殊浄化装置種別」を追加する 李 start
        /// <summary>
        /// 透析設備情報
        /// </summary>
        [System.Runtime.Serialization.DataContract()]
        public class DialysisDeviceInfo
        {
            // <> NameはJSONキー名／プロパティの型がJSONバリューの型

            [System.Runtime.Serialization.DataMember(Name = "facilityCd")]
            public string FacilityCd { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "machineName")]
            public string MachineName { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "machineType")]
            public string MachineType { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "ipAddress")]
            public string IPAddress { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "port")]
            public string Port { get; set; } = "";

            [System.Runtime.Serialization.DataMember(Name = "blood_purify_type")]
            public string BloodPurifyType { get; set; } = "";
            // </>
        }
        // add 2020-08-04 FNSI-仕様追加 装置マスタに「特殊浄化通信アプリ使用選択」、「特殊浄化装置種別」を追加する 李 end

    }
}
