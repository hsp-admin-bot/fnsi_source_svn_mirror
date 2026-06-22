using System;
using System.IO;
using System.Net.Http.Headers;
using System.Windows.Forms;

namespace FNSICloudConvertClient.Logic
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// アプリケーション共通設定ファイル（FNSICloudConvertClient.config）の読み書きを担当するクラス
    ///
    /// 設定ファイル構造:
    ///   Settings/CommonSection  — 接続・証明書・更新・ヘルプ設定
    ///   Settings/LogSection     — ログ出力設定
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public static class AppConfigLoader
    {
        // --------------------------------------------------
        // 定数
        // --------------------------------------------------
        private const string CONFIG_FILE_NAME = "FNSICloudConvertClient.config";
        private const string CONFIG_COMMON    = @"Settings\CommonSection";
        private const string CONFIG_LOG       = @"Settings\LogSection";
        private const string CONFIG_DATABASE  = @"Settings\DatabaseSection";
        private const string CONFIG_TOOLS     = @"Settings\ToolsSection";
        private const string CONVERTER_PATH_PREFIX = "/fnsi-cloud-convert-server";
        private const string CONVERTER_HEADER_NAME = "server";
        private const string DEFAULT_CONVERTER_BASE_URI = "http://localhost:8080/fnsi-cloud-convert-server";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイルのフルパス（EXE と同じディレクトリ）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static string ConfigFilePath =>
            Path.Combine(Application.StartupPath, CONFIG_FILE_NAME);

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// pg_dump_config.yaml のフルパス（EXE と同じディレクトリ）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static string PgDumpConfigPath =>
            Path.Combine(Application.StartupPath, "pg_dump_config.yaml");

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// mongo_dump_config.yaml のフルパス（EXE と同じディレクトリ）
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static string MongoDumpConfigPath =>
            Path.Combine(Application.StartupPath, "mongo_dump_config.yaml");

        // --------------------------------------------------
        // CommonSection プロパティ
        // --------------------------------------------------

        /// <summary>クライアント証明書検索キー値1</summary>
        public static string ClientCertificateSearchValue1 { get; private set; } = string.Empty;

        /// <summary>クライアント証明書検索キー値2</summary>
        public static string ClientCertificateSearchValue2 { get; private set; } = string.Empty;

        /// <summary>施設ハッシュ</summary>
        public static string FacilityHash { get; private set; } = string.Empty;

        /// <summary>業務アプリサーバーアドレス</summary>
        public static string BaseUri { get; private set; } = "http://localhost:8080";

        /// <summary>コンバーターサーバーアドレス（コンテキストパス込み）</summary>
        public static string ConverterBaseUri { get; private set; } = DEFAULT_CONVERTER_BASE_URI;

        /// <summary>コンバーターサーバー向け固定ルーティングヘッダー値</summary>
        public static string ConverterServerHeaderValue { get; private set; } = "01";

        /// <summary>最新ファイル取得先フォルダ</summary>
        public static string DownloadFolder { get; private set; } = string.Empty;

        /// <summary>最新ファイル取得先ファイル名</summary>
        public static string DownloadFileName { get; private set; } = string.Empty;

        /// <summary>システム支援ドキュメントパス</summary>
        public static string HelpDocument { get; private set; } = string.Empty;

        /// <summary>ZIP圧縮パスワード（空の場合はパスワードなし）</summary>
        public static string ZipPassword { get; private set; } = string.Empty;

        /// <summary>
        /// LAN モードかどうか（true=LAN / false=WAN）
        /// LAN モード時はオンプレ作業とクラウド作業を分割して実行する
        /// </summary>
        public static bool IsLanMode { get; private set; } = false;

        // --------------------------------------------------
        // LogSection プロパティ
        // --------------------------------------------------

        /// <summary>ログ格納先フォルダ（空の場合は実行フォルダ直下の LOG フォルダ）</summary>
        public static string LogFolder { get; private set; } = string.Empty;

        /// <summary>ログ保持日数（既定値: 20）</summary>
        public static int LogKeepNumberOfDays { get; private set; } = 20;

        // --------------------------------------------------
        // DatabaseSection プロパティ
        // --------------------------------------------------

        /// <summary>PostgreSQL DB4 DB名</summary>
        public static string PgDb4Name     { get; private set; } = "ntss_db4";
        /// <summary>PostgreSQL DB4 ユーザー名</summary>
        public static string PgDb4User     { get; private set; } = "nkk4";
        /// <summary>PostgreSQL DB4 パスワード</summary>
        public static string PgDb4Password { get; private set; } = "nkk4";

        /// <summary>PostgreSQL DB5 DB名</summary>
        public static string PgDb5Name     { get; private set; } = "ntss_db5";
        /// <summary>PostgreSQL DB5 ユーザー名</summary>
        public static string PgDb5User     { get; private set; } = "nkk5";
        /// <summary>PostgreSQL DB5 パスワード</summary>
        public static string PgDb5Password { get; private set; } = "nkk5";

        /// <summary>PostgreSQL DB6 DB名</summary>
        public static string PgDb6Name     { get; private set; } = "ntss_db6";
        /// <summary>PostgreSQL DB6 ユーザー名</summary>
        public static string PgDb6User     { get; private set; } = "nkk6";
        /// <summary>PostgreSQL DB6 パスワード</summary>
        public static string PgDb6Password { get; private set; } = "nkk6";

        /// <summary>MongoDB DB名</summary>
        public static string MongoDbName   { get; private set; } = "ntss";
        /// <summary>MongoDB ユーザー名</summary>
        public static string MongoUser     { get; private set; } = "nkk";
        /// <summary>MongoDB パスワード</summary>
        public static string MongoPassword { get; private set; } = "nkk";

        // --------------------------------------------------
        // ToolsSection プロパティ
        // --------------------------------------------------

        /// <summary>pg_dump.exe のフルパス</summary>
        public static string PgDumpExe     { get; private set; } = @"C:\Program Files\PostgreSQL\16\bin\pg_dump.exe";

        /// <summary>psql.exe のフルパス</summary>
        public static string PsqlExe       { get; private set; } = @"C:\Program Files\PostgreSQL\16\bin\psql.exe";

        /// <summary>pg_restore.exe のフルパス</summary>
        public static string PgRestoreExe  { get; private set; } = @"C:\Program Files\PostgreSQL\16\bin\pg_restore.exe";

        /// <summary>mongodump.exe のフルパス</summary>
        public static string MongoDumpExe  { get; private set; } = @"C:\Program Files\MongoDB\Tools\100\bin\mongodump.exe";

        /// <summary>mongorestore.exe のフルパス（mongodump.exe と同じディレクトリから自動導出）</summary>
        public static string MongoRestoreExe =>
            Path.Combine(
                Path.GetDirectoryName(MongoDumpExe) ?? string.Empty,
                "mongorestore.exe");

        /// <summary>mongoimport.exe のフルパス</summary>
        public static string MongoImportExe { get; private set; } = @"C:\Program Files\MongoDB\Tools\100\bin\mongoimport.exe";

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 設定ファイルを読み込み、各プロパティおよび BusinessApiClient / AppLogger へ反映する
        /// アプリケーション起動直後（Application.Run より前）に呼び出すこと
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static void Load()
        {
            if (!File.Exists(ConfigFilePath))
            {
                throw new FileNotFoundException(
                    string.Format("設定ファイルが見つかりません。\n{0}", ConfigFilePath),
                    ConfigFilePath);
            }

            var info = SimpleConfigReader.GetInstance();
            if (!info.Load(ConfigFilePath))
            {
                throw new ApplicationException(
                    "設定ファイルの読み込みに失敗しました。", info.Error);
            }

            // --------------------------------------------------
            // CommonSection 読み込み
            // --------------------------------------------------
            ClientCertificateSearchValue1 = info.GetSingleLineValue(CONFIG_COMMON, "ClientCertificateSearchValue1", string.Empty).Trim();
            ClientCertificateSearchValue2 = info.GetSingleLineValue(CONFIG_COMMON, "ClientCertificateSearchValue2", string.Empty).Trim();
            FacilityHash                  = info.GetSingleLineValue(CONFIG_COMMON, "FacilityHash",                  string.Empty).Trim();
            BaseUri                       = info.GetSingleLineValue(CONFIG_COMMON, "BaseUri",          "http://localhost:8080").Trim(' ', '/');
            ConverterBaseUri              = NormalizeConverterBaseUri(
                info.GetSingleLineValue(CONFIG_COMMON, "ConverterBaseUri", DEFAULT_CONVERTER_BASE_URI));
            ConverterServerHeaderValue    = info.GetSingleLineValue(CONFIG_COMMON, "ConverterServerHeaderValue", "01").Trim();
            DownloadFolder                = info.GetSingleLineValue(CONFIG_COMMON, "DownloadFolder",   string.Empty).Trim();
            DownloadFileName              = info.GetSingleLineValue(CONFIG_COMMON, "DownloadFileName", string.Empty).Trim();
            HelpDocument                  = info.GetSingleLineValue(CONFIG_COMMON, "HelpDocument",     string.Empty).Trim();
            ZipPassword                   = info.GetSingleLineValue(CONFIG_COMMON, "ZipPassword",      string.Empty).Trim();

            string networkMode = info.GetSingleLineValue(CONFIG_COMMON, "NetworkMode", "WAN").Trim();
            IsLanMode = string.Equals(networkMode, "LAN", StringComparison.OrdinalIgnoreCase);

            // --------------------------------------------------
            // LogSection 読み込み
            // --------------------------------------------------
            LogFolder = info.GetSingleLineValue(CONFIG_LOG, "Folder", string.Empty).Trim();

            string keepDaysStr = info.GetSingleLineValue(CONFIG_LOG, "KeepNumberOfDays", string.Empty).Trim();
            if (int.TryParse(keepDaysStr, out int days) && days >= 0)
                LogKeepNumberOfDays = days;

            // --------------------------------------------------
            // DatabaseSection 読み込み
            // --------------------------------------------------
            PgDb4Name     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb4Name",     "ntss_db4").Trim();
            PgDb4User     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb4User",     "nkk4").Trim();
            PgDb4Password = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb4Password", "nkk4").Trim();

            PgDb5Name     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb5Name",     "ntss_db5").Trim();
            PgDb5User     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb5User",     "nkk5").Trim();
            PgDb5Password = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb5Password", "nkk5").Trim();

            PgDb6Name     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb6Name",     "ntss_db6").Trim();
            PgDb6User     = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb6User",     "nkk6").Trim();
            PgDb6Password = info.GetSingleLineValue(CONFIG_DATABASE, "PgDb6Password", "nkk6").Trim();

            MongoDbName   = info.GetSingleLineValue(CONFIG_DATABASE, "MongoDbName",   "ntss").Trim();
            MongoUser     = info.GetSingleLineValue(CONFIG_DATABASE, "MongoUser",     "nkk").Trim();
            MongoPassword = info.GetSingleLineValue(CONFIG_DATABASE, "MongoPassword", "nkk").Trim();

            // --------------------------------------------------
            // ToolsSection 読み込み
            // --------------------------------------------------
            PgDumpExe      = info.GetSingleLineValue(CONFIG_TOOLS, "PgDumpExe",      PgDumpExe).Trim();
            PsqlExe        = info.GetSingleLineValue(CONFIG_TOOLS, "PsqlExe",        PsqlExe).Trim();
            PgRestoreExe   = info.GetSingleLineValue(CONFIG_TOOLS, "PgRestoreExe",   PgRestoreExe).Trim();
            MongoDumpExe   = info.GetSingleLineValue(CONFIG_TOOLS, "MongoDumpExe",   MongoDumpExe).Trim();
            MongoImportExe = info.GetSingleLineValue(CONFIG_TOOLS, "MongoImportExe", MongoImportExe).Trim();

            // --------------------------------------------------
            // BusinessApiClient へ反映
            // --------------------------------------------------
            BusinessApiClient.BaseUri                       = BaseUri;
            BusinessApiClient.UrlEncodeFacilityHash         = FacilityHash;
            BusinessApiClient.ClientCertificateSearchValue1 = ClientCertificateSearchValue1;
            BusinessApiClient.ClientCertificateSearchValue2 = ClientCertificateSearchValue2;

            // --------------------------------------------------
            // AppLogger へ反映
            // --------------------------------------------------
            AppLogger.GetInstance().LogFolder = LogFolder;
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// 施設ハッシュ値を設定ファイルへ書き込む
        /// ログイン成功後に選択した施設のハッシュ値を永続化する場合に使用する
        /// </summary>
        /// <param name="facilityHash">保存する施設ハッシュ値</param>
        //----------------------------------------------------------------------------------------------------
        public static void SaveFacilityHash(string facilityHash)
        {
            if (!File.Exists(ConfigFilePath))
            {
                throw new FileNotFoundException(
                    string.Format("設定ファイルが見つかりません。\n{0}", ConfigFilePath),
                    ConfigFilePath);
            }

            var info = SimpleConfigReader.GetInstance();
            if (!info.Load(ConfigFilePath))
            {
                throw new ApplicationException(
                    "設定ファイルの読み込みに失敗しました。", info.Error);
            }

            info.SetValue(CONFIG_COMMON, "FacilityHash", facilityHash);
            info.Save();

            FacilityHash = facilityHash;
            BusinessApiClient.UrlEncodeFacilityHash = facilityHash;
        }

        public static void ApplyConverterRequestHeaders(HttpRequestHeaders headers)
        {
            if (headers == null)
                return;

            headers.Remove(CONVERTER_HEADER_NAME);

            if (!string.IsNullOrWhiteSpace(ConverterServerHeaderValue))
            {
                headers.TryAddWithoutValidation(
                    CONVERTER_HEADER_NAME,
                    ConverterServerHeaderValue.Trim());
            }
        }

        private static string NormalizeConverterBaseUri(string rawValue)
        {
            string value = string.IsNullOrWhiteSpace(rawValue)
                ? DEFAULT_CONVERTER_BASE_URI
                : rawValue.Trim();

            value = value.TrimEnd('/');
            if (string.IsNullOrWhiteSpace(value))
                return DEFAULT_CONVERTER_BASE_URI;

            if (value.EndsWith(CONVERTER_PATH_PREFIX, StringComparison.OrdinalIgnoreCase))
                return value;

            return value + CONVERTER_PATH_PREFIX;
        }
    }
}
