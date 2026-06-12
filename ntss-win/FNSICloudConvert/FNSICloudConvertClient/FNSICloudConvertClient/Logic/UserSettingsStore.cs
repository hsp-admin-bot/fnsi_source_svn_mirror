using System;
using System.IO;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;
using System.Windows.Forms;
using FNSICloudConvertClient.Models;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// FormSettings で設定した接続情報をファイルへ永続化するクラス
    ///
    /// 保存先: {EXEフォルダ}\user_settings.json
    /// タイミング:
    ///   書き込み — FormSettings の [確定] ボタン押下時
    ///   読み込み — FormSettings を開いた時（AppSettings が未設定の場合にファイルから復元）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    [DataContract]
    public class UserSettingsStore
    {
        private const string FILE_NAME = "user_settings.json";

        // --------------------------------------------------
        // 保存対象フィールド
        // --------------------------------------------------
        [DataMember] public string OnpreRdbIpAddress   { get; set; } = string.Empty;
        [DataMember] public string OnpreMongoIpAddress { get; set; } = string.Empty;
        [DataMember] public string OnpreFnsiRootFolder { get; set; } = string.Empty;
        [DataMember] public string OnpreTempFolder     { get; set; } = string.Empty;
        [DataMember] public string CloudTempFolder     { get; set; } = string.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 保存ファイルのフルパス（EXE と同じディレクトリ）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static string FilePath =>
            Path.Combine(Application.StartupPath, FILE_NAME);

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// ファイルが存在する場合に読み込んで返す。存在しない・解析失敗の場合は null を返す
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static UserSettingsStore Load()
        {
            if (!File.Exists(FilePath))
                return null;

            try
            {
                string json = File.ReadAllText(FilePath, Encoding.UTF8);
                using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(json)))
                {
                    var ser = new DataContractJsonSerializer(typeof(UserSettingsStore));
                    return (UserSettingsStore)ser.ReadObject(ms);
                }
            }
            catch
            {
                // ファイルが壊れている場合は無視して null を返す
                return null;
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 現在の内容をファイルへ書き込む
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void Save()
        {
            try
            {
                using (var ms = new MemoryStream())
                {
                    var ser = new DataContractJsonSerializer(typeof(UserSettingsStore));
                    ser.WriteObject(ms, this);
                    string json = Encoding.UTF8.GetString(ms.ToArray());
                    File.WriteAllText(FilePath, json, Encoding.UTF8);
                }
            }
            catch
            {
                // 保存失敗は無視（次回も手動設定になるだけ）
            }
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// AppSettings の値から UserSettingsStore を生成する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static UserSettingsStore FromSettings(AppSettings s) =>
            new UserSettingsStore
            {
                OnpreRdbIpAddress   = s.OnpreRdbIpAddress,
                OnpreMongoIpAddress = s.OnpreMongoIpAddress,
                OnpreFnsiRootFolder = s.OnpreFnsiRootFolder,
                OnpreTempFolder     = s.OnpreTempFolder,
                CloudTempFolder     = s.CloudTempFolder,
            };

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 自身の値を AppSettings へ適用する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public void ApplyTo(AppSettings s)
        {
            s.OnpreRdbIpAddress   = OnpreRdbIpAddress;
            s.OnpreMongoIpAddress = OnpreMongoIpAddress;
            s.OnpreFnsiRootFolder = OnpreFnsiRootFolder;
            s.OnpreTempFolder     = OnpreTempFolder;
            s.CloudTempFolder     = CloudTempFolder;
        }
    }
}
