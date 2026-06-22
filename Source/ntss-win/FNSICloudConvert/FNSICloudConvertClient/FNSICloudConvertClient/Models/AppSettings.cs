namespace FNSICloudConvertClient.Models
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 接続設定（PostgreSQL / MongoDB）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class AppSettings
    {
        // --------------------------------------------------
        // PostgreSQL 接続設定
        // --------------------------------------------------
        /// <summary>ホスト名</summary>
        public string PgHost     { get; set; } = "localhost";

        /// <summary>ポート番号</summary>
        public int    PgPort     { get; set; } = 5432;

        /// <summary>データベース名</summary>
        public string PgDatabase { get; set; } = string.Empty;

        /// <summary>ユーザーID</summary>
        public string PgUserId   { get; set; } = string.Empty;

        /// <summary>パスワード</summary>
        public string PgPassword { get; set; } = string.Empty;

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// "host:port" または "host" 形式のアドレス文字列を解析して (host, port) を返す。
        /// ポート番号が含まれない場合は defaultPort を使用する。
        /// 例: "localhost:5433" → ("localhost", 5433)
        ///     "192.168.1.1"   → ("192.168.1.1", defaultPort)
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public static (string Host, int Port) ParseHostPort(string address, int defaultPort)
        {
            if (string.IsNullOrWhiteSpace(address))
                return ("localhost", defaultPort);

            int colonIdx = address.LastIndexOf(':');
            if (colonIdx > 0 && int.TryParse(address.Substring(colonIdx + 1), out int port))
                return (address.Substring(0, colonIdx), port);

            return (address, defaultPort);
        }

        //----------------------------------------------------------------------------------------------------
        /// <summary>
        /// Npgsql 接続文字列を生成する
        /// </summary>
        //----------------------------------------------------------------------------------------------------
        public string BuildPgConnectionString()
        {
            return string.Format(
                "Host={0};Port={1};Database={2};Username={3};Password={4}",
                PgHost, PgPort, PgDatabase, PgUserId, PgPassword);
        }

        // --------------------------------------------------
        // MongoDB 接続設定
        // --------------------------------------------------
        /// <summary>接続文字列</summary>
        public string MongoConnectionString { get; set; } = "mongodb://localhost:27017";

        /// <summary>データベース名</summary>
        public string MongoDatabase { get; set; } = string.Empty;

        // --------------------------------------------------
        // ファイルパス設定
        // --------------------------------------------------
        /// <summary>データ導出先フォルダ</summary>
        public string OutputPath { get; set; } = string.Empty;

        /// <summary>データ導入元フォルダ</summary>
        public string InputPath  { get; set; } = string.Empty;

        // --------------------------------------------------
        // オンプレ側設定
        // --------------------------------------------------
        /// <summary>オンプレ RDB IPアドレス</summary>
        public string OnpreRdbIpAddress    { get; set; } = string.Empty;

        /// <summary>オンプレ MongoDB IPアドレス</summary>
        public string OnpreMongoIpAddress  { get; set; } = string.Empty;

        /// <summary>FNSi物理ファイルルートフォルダ</summary>
        public string OnpreFnsiRootFolder  { get; set; } = string.Empty;

        /// <summary>オンプレ臨時フォルダ</summary>
        public string OnpreTempFolder      { get; set; } = string.Empty;

        // --------------------------------------------------
        // クラウド側設定
        // --------------------------------------------------
        /// <summary>クラウド臨時フォルダ</summary>
        public string CloudTempFolder      { get; set; } = string.Empty;
    }
}
