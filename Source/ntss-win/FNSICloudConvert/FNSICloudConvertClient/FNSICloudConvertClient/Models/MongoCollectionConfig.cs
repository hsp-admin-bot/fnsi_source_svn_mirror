namespace FNSICloudConvertClient.Models
{
    /// <summary>
    /// mongo_dump_config.yaml の 1 コレクション定義
    /// </summary>
    internal class MongoCollectionConfig
    {
        /// <summary>コレクション名</summary>
        public string Name { get; set; }

        /// <summary>ダンプ対象かどうか（false = スキップ）</summary>
        public bool Dump { get; set; }

        /// <summary>
        /// 施設フィルターに使用するフィールド名（null = 全件対象）
        /// 例: "facility_cd"
        /// </summary>
        public string FilterField { get; set; }
    }
}
