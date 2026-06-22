namespace FNSICloudConvertClient.Models
{
    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// 進捗情報（UI 更新用コールバックデータ）
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public class ProgressInfo
    {
        /// <summary>対象 DB 種別</summary>
        public DbKind DbKind { get; set; }

        /// <summary>進捗率（0～100）。-1 = 更新なし（デフォルト）</summary>
        public int Percentage { get; set; } = -1;

        /// <summary>ログメッセージ</summary>
        public string Message { get; set; } = string.Empty;

        /// <summary>ファイル出力用の元ログ行（未指定時は Message を使う）</summary>
        public string RawMessage { get; set; } = string.Empty;

        /// <summary>エラーフラグ</summary>
        public bool IsError { get; set; } = false;

        /// <summary>Message がそのまま表示用の完成行であるか</summary>
        public bool IsPreformattedLogLine { get; set; } = false;

        // --------------------------------------------------
        // 件数更新用（IsCountUpdate = true の場合のみ有効）
        // --------------------------------------------------
        /// <summary>件数表示更新フラグ（true のときログ出力はスキップ）</summary>
        public bool   IsCountUpdate { get; set; }

        /// <summary>対象キー: "db4" / "db5" / "db6" / "mongo"</summary>
        public string CountKey      { get; set; } = string.Empty;

        /// <summary>総件数</summary>
        public int    CountTotal    { get; set; }

        /// <summary>処理済件数</summary>
        public int    CountDone     { get; set; }

        /// <summary>複数行の集計表示テキスト</summary>
        public string CountText     { get; set; } = string.Empty;
    }

    //----------------------------------------------------------------------------------------------------
    /// <summary>
    /// DB 種別
    /// </summary>
    //----------------------------------------------------------------------------------------------------
    public enum DbKind
    {
        /// <summary>PostgreSQL</summary>
        PostgreSql = 0,
        /// <summary>MongoDB</summary>
        MongoDb    = 1
    }
}
