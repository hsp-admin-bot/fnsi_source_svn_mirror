using System;
using System.IO;
using System.Xml.Serialization;

namespace CoopExtractTool
{
    [XmlRoot("Settings")]
    public class Settings
    {
        public Connection Connection { get; set; }

        public DBView DBView { get; set; }

    }

    /// <summary>
    /// システム設定項目
    /// </summary>
    [XmlRoot("Connection")]
    public class Connection
    {
        /// <summary>
        /// プロトコル
        /// </summary>
        public string Protocol { get; set; }

        /// <summary>
        /// IPアドレス
        /// </summary>
        public string IPAddress { get; set; }

        /// <summary>
        /// ポートNo
        /// </summary>
        public string PortNo { get; set; }

        /// <summary>
        /// Database名
        /// </summary>
        public string Database { get; set; }

        /// <summary>
        /// 接続仕様 DatabaseにてSID（システム識別子）を指定してOracle Databaseに接続する場合「SID」を設定しておく
        /// </summary>
        public string ConnectSpecificat { get; set; }

        /// <summary>
        /// ユーザー名
        /// </summary>
        public string Username { get; set; }

        /// <summary>
        /// パスワード
        /// </summary>
        public string Password { get; set; }

        /// <summary>
        /// 管理権限　「Normal」「SYSDBA」「SYSOPER」のいずれかを設定
        /// </summary>
        public string Role { get; set; }

        /// <summary>
        /// 接続タイムアウト（秒）
        /// </summary>
        public int ConnectionTimeout { get; set; } = 15;
    }

    /// <summary>
    /// システム設定項目
    /// </summary>
    [XmlRoot("DBView")]
    public class DBView
    {
        /// <summary>
        /// SYS_COOP_INI_DATAのデータを抽出する時に使用される
        /// </summary>
        public string SQL { get; set; }

        /// <summary>
        /// SYS_SERIES_FACILITYのデータを抽出する時に使用される
        /// </summary>
        public string SQL_SYS_SERIES_FACILITY { get; set; }   
    }

    public static class ConfigSettingManager
    {
        /// <summary>
        /// 設定ＸＭＬファイル名
        /// </summary>
        public const string FILENAME = "CoopExtractTool.config";

        /// <summary>
        /// データ実体
        /// </summary>
        public static Settings Data = new Settings();

        /// <summary>
        /// ＸＭＬから設定を読み込む
        /// </summary>
        public static int ReadXML()
        {
            // EXEと同じ場所のパスを取得
            string exePath = AppDomain.CurrentDomain.BaseDirectory;
            string filePath = Path.Combine(exePath, FILENAME);

            if (!File.Exists(filePath))
            {
                // ファイルが存在しない場合
                return Commons.RetCode_Nothing;
            }

            try
            {
                // XmlSerializerオブジェクトを作成
                System.Xml.Serialization.XmlSerializer serializer =
                    new System.Xml.Serialization.XmlSerializer(typeof(Settings));
                // 読み込むファイルを開く
                System.IO.StreamReader sr = new System.IO.StreamReader(
                    filePath, new System.Text.UTF8Encoding(false));
                // XMLファイルから読み込み、逆シリアル化する
                Data = (Settings)serializer.Deserialize(sr);
                // ファイルを閉じる
                sr.Close();
            }
            catch
            {
                return Commons.RetCode_Error;
            }

            return Commons.RetCode_Success;
        }

        /// <summary>
        /// DBの接続文字列を取得
        /// </summary>
        /// <returns></returns>
        public static string GetConnectionString()
        {
            string connectionString = "";

            string connectSpecificat = "SERVICE_NAME";
            if (Data.Connection.ConnectSpecificat == "SID")
            {
                connectSpecificat = "SID";
            }

            connectionString = string.Format("Data Source=(DESCRIPTION=(ADDRESS=(PROTOCOL={0})(HOST={1})(PORT={2}))(CONNECT_DATA=({3}={4})));User Id={5};Password={6};"
                , Data.Connection.Protocol
                , Data.Connection.IPAddress
                , Data.Connection.PortNo
                , connectSpecificat
                , Data.Connection.Database
                , Data.Connection.Username
                , Data.Connection.Password
                );

            // Role
            if (Data.Connection.Role == "SYSDBA")
            {
                connectionString += "DBA Privilege=SYSDBA;";
            }
            else if (Data.Connection.Role == "SYSOPER")
            {
                connectionString += "DBA Privilege=SYSOPER;";
            }

            // Connection Timeout
            connectionString += string.Format("Connection Timeout = {0};", Data.Connection.ConnectionTimeout);

            return connectionString;
        }

    }
}
