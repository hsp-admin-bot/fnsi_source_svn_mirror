using System;
using System.Collections.Generic;

namespace FNSICloudConvertClient.Models
{
    /// <summary>
    /// pg_dump_config.yaml の1テーブルエントリを表すモデル
    /// </summary>
    internal class PgTableConfig
    {
        /// <summary>テーブル名</summary>
        public string Name { get; set; }

        /// <summary>整数シリアル PK のカラム名（PK マッピング対象）。null = 対象外</summary>
        public string IdColumn { get; set; }

        /// <summary>PK を共有する親テーブル名（例: pat_unique → pat_personal_main）。null = 独立 PK</summary>
        public string SharedPkTable { get; set; }

        /// <summary>ダンプ対象かどうか（false のテーブルはスキップ）</summary>
        public bool Dump { get; set; }

        /// <summary>
        /// facility_cd フィルター用 WHERE 句テンプレート。
        /// null の場合は全件対象（グローバルマスタ等）
        /// 例: "facility_cd IN (:facilityList)"
        /// </summary>
        public string WhereTemplate { get; set; }

        /// <summary>移行方向: "both" / "off2on" / "on2off"</summary>
        public string Direction { get; set; }

        /// <summary>対象 DB 名: "ntss_db4" / "ntss_db5" / "ntss_db6"</summary>
        public string Db { get; set; }

        /// <summary>
        /// PK を一体として扱う追加テーブル名一覧。
        /// 例: ord_main の seq を ord_main_restore と共有したい場合に使用。
        /// </summary>
        public List<string> PkGroupTables { get; set; } = new List<string>();

        /// <summary>
        /// シーケンス名の明示的オーバーライド。
        /// null の場合は {table}_{idColumn}_seq を使う。
        /// </summary>
        public string SeqName { get; set; }

        /// <summary>実際に使用するシーケンス名を返す</summary>
        public string ResolveSeqName()
        {
            if (!string.IsNullOrWhiteSpace(SeqName))
                return SeqName;

            if (string.IsNullOrWhiteSpace(Name) || string.IsNullOrWhiteSpace(IdColumn))
                return string.Empty;

            return string.Format("{0}_{1}_seq", Name, IdColumn);
        }

        /// <summary>独自 sequence を持つ PK マッピング対象テーブルかどうか</summary>
        public bool HasIndependentPk
        {
            get
            {
                return !string.IsNullOrWhiteSpace(IdColumn)
                    && string.IsNullOrWhiteSpace(SharedPkTable);
            }
        }
    }
}
