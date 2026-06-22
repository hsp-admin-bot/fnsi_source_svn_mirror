package com.fnsi.cloudconverter.migration.pg;

import lombok.Data;

import java.util.List;

/**
 * PG ダンプ対象テーブル設定 (pg_dump_config.yaml の 1 テーブルエントリ)
 */
@Data
public class PgTableConfig {
    /** テーブル名 */
    private String  name;
    /** PK カラム名 */
    private String  idColumn;
    /** ダンプ対象か */
    private boolean dump = true;
    /** WHERE 句テンプレート（:facilityList プレースホルダー） */
    private String  whereTemplate;
    /** 適用方向: both / off2on / on2off */
    private String  direction = "both";
    /** ターゲット DB 名 (ntss_db5 / ntss_db6) */
    private String  db = "ntss_db5";
    /** PK を共有する親テーブル名（シーケンスを持たない場合に設定、例: pat_unique → pat_personal_main） */
    private String  sharedPkTable;

    /**
     * PK マッピング生成時にこのテーブルと一体として扱う追加テーブル名リスト。
     * 例: ord_main に [ord_main_restore] を設定すると、両テーブルの ord_no を合算して
     * 在線シーケンスから新 ID を取得し、すべて ord_main 名義で pk_mapping に登録する。
     */
    private List<String> pkGroupTables;

    /**
     * シーケンス名の明示的オーバーライド（省略時は {name}_{idColumn}_seq を自動導出）。
     * 命名規則が異なるテーブル（例: ord_material_save → ord_material_save_seq）に使用。
     */
    private String  seqName;

    /** PK マッピング対象か（idColumn が設定されている場合 true） */
    public boolean hasIdColumn() {
        return idColumn != null && !idColumn.isBlank();
    }

    /** 実際に使用するシーケンス名を返す（seqName 未指定の場合は標準命名規則で導出） */
    public String resolveSeqName() {
        if (seqName != null && !seqName.isBlank()) return seqName;
        return name + "_" + idColumn + "_seq";
    }
}
