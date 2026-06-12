-- =============================================================
-- fk_migration_config 建表脚本
-- 生成日期: 2026-03-20
-- 依据: docs/04_database.md ### 2.5 fk_migration_config
-- =============================================================

DROP TABLE IF EXISTS fk_migration_config;

CREATE TABLE fk_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    table_name      TEXT        NOT NULL,       -- 要更新 FK 的目标表
    fk_type         TEXT        NOT NULL CHECK (fk_type IN ('COLUMN', 'JSON')),
    column_name     TEXT,                       -- COLUMN 型：FK 列名（JSON 型时为 NULL）
    json_column     TEXT,                       -- JSON 型：JSONB 列名（COLUMN 型时为 NULL）
    json_path       TEXT,                       -- JSON 型：路径，格式见 COMMENT
    ref_table       TEXT        NOT NULL,       -- 引用目标表（pk_mapping.table_name）
                                                -- 主键列名由 pk_mapping 推断，无需单独配置
    execution_order INT         NOT NULL DEFAULT 0,  -- 执行顺序（升序）
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    where_template  TEXT,                       -- 多态FK过滤条件（SQL片段，NULL=无条件）
    remark          TEXT,                       -- 备注（多态FK分支说明等）
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fk_migration_config IS
    'PG テーブルの FK 刷新配置。COLUMN 型（普通列）と JSON 型（JSONB フィールド内）の両方をサポート。
     多態FK（ref_table が条件によって変わる場合）は where_template で分岐を表現し、
     同一 (table_name, fk_type, column_name/json_path) に複数行 INSERT することで対応する。';

COMMENT ON COLUMN fk_migration_config.table_name IS
    '刷新対象の PG テーブル名（スキーマ名を含まない）。
     実行時は facility_cd で絞り込んだ上で UPDATE を発行する。
     例: ord_main / ord_material_save / pat_main';

COMMENT ON COLUMN fk_migration_config.fk_type IS
    'FK の種別。
     COLUMN = 普通列の FK。column_name に列名を指定する。
              例: ord_main.up_user_id → mst_user.user_id
     JSON   = JSONB フィールド内の FK。json_column + json_path で位置を指定する。
              例: ord_main.ind_cond_info の中の {25,value} → mst_medicine.medicine_cd';

COMMENT ON COLUMN fk_migration_config.column_name IS
    'fk_type=COLUMN の場合に指定する FK 列名。fk_type=JSON の場合は NULL。
     例: user_id / supplies_cd / pat_id';

COMMENT ON COLUMN fk_migration_config.json_column IS
    'fk_type=JSON の場合に指定する JSONB 列名。fk_type=COLUMN の場合は NULL。
     例: ind_cond_info / ind_medi_info / device_set_info';

COMMENT ON COLUMN fk_migration_config.json_path IS
    'fk_type=JSON の場合に指定する PostgreSQL 配列パス形式（{key1,key2,...}）。
     規則:
       {} 内をカンマ区切りで記述。文字列キーと数字キーの両方が使用可能。
       配列型 JSONB の場合は runtime が jsonb_array_elements で展開して処理する。
     示例:
       {userId}           トップレベルの "userId" キー
       {items,itemId}     オブジェクト内ネスト: items → itemId
       {25,value}         数字文字列キー: {"25": {"value": "..."}}
       {15,value}         同上、編号 15
       {*,ind_user_id}    全キー下の ind_user_id（* = ワイルドカード）';

COMMENT ON COLUMN fk_migration_config.ref_table IS
    '引用先テーブル名。pk_mapping テーブルから主キー列名を自動推論するため、
     主キー列名の個別指定は不要。
     例: mst_user / mst_medicine / mst_medicine_mix / ord_main
     ※ 多態FK の場合は同一フィールドに対して複数行を INSERT し、
        それぞれ異なる ref_table + where_template を設定する。';

COMMENT ON COLUMN fk_migration_config.execution_order IS
    '処理順序（昇順）。FK 参照先が先に処理されるよう制御する。
     基準値:
       10  = DB4 基礎層（mst_user_authentication）
       20  = DB4 依存層（mst_user_authentication を参照するテーブル）
       100 = DB5 基礎層（mst_* / pat_main のみ参照）
       110 = DB5 依存層（ord_main.ord_no を参照するテーブル）
       200 = DB6（pat_insurance 等）';

COMMENT ON COLUMN fk_migration_config.enabled IS
    '処理対象フラグ。FALSE の場合はこの行をスキップする。
     enabled と where_template の組み合わせ:
       TRUE  + NULL        = 普通FK、全行を無条件に刷新
       TRUE  + SQL片断     = 多態FK、where_template 条件を満たす行のみ刷新
       FALSE + （任意）    = 暫定スキップ
     ※ 多態FK を enabled=FALSE で表現する旧方式は廃止。
        enabled=TRUE + where_template を使用すること（004設計方案参照）。';

COMMENT ON COLUMN fk_migration_config.where_template IS
    '多態FK の分岐条件（SQL 片断）。NULL = 無条件で全行刷新。
     非 NULL の場合、runtime が生成する UPDATE 文の WHERE 句末尾に
     "AND (<where_template>)" として追加される。

     示例（列判断）:
       supplies_class IN (''08'',''09'',''10'',''12'',''14'',''16'',''20'',''21'',''22'',''23'')
       supplies_class = ''01''

     示例（JSONB 内判断）:
       (ind_cond_info->''25''->>''medicine_type'')::int = 1
       (ind_cond_info->''25''->>''medicine_type'')::int = 2

     ⚠ セキュリティ注意:
       where_template は SQL 片断を直接結合するため SQL インジェクションリスクがある。
       このテーブルへの書き込みは DBA / 移行ツールのみに制限し、
       外部入力をそのまま格納しないこと（004設計方案 リスク欄参照）。';

COMMENT ON COLUMN fk_migration_config.remark IS
    '備考。多態FK の分岐内容、暫定スキップ理由、特殊処理など自由記述。
     例: 多態FK: medicine_type=1 → 通常薬剤
         多態FK: equip_type=0 → 器材
         DB4→DB5 クロスDB参照';

-- 检查约束：COLUMN 型需要 column_name，JSON 型需要 json_column + json_path
ALTER TABLE fk_migration_config ADD CONSTRAINT chk_fk_column
    CHECK (
        (fk_type = 'COLUMN' AND column_name IS NOT NULL) OR
        (fk_type = 'JSON'   AND json_column IS NOT NULL AND json_path IS NOT NULL)
    );

CREATE INDEX idx_fkconfig_table ON fk_migration_config (table_name, enabled);
CREATE INDEX idx_fkconfig_order ON fk_migration_config (execution_order) WHERE enabled = TRUE;
