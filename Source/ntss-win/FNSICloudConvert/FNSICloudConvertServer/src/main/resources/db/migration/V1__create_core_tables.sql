-- =============================================================
-- 01: convert_db の最終スキーマ作成
--   migration_job / migration_task / migration_task_log
--   pk_mapping / facility_lock
--   fk_migration_config / fk_mongo_migration_config
-- =============================================================

DROP TABLE IF EXISTS flyway_schema_history CASCADE;

CREATE TABLE IF NOT EXISTS migration_job (
    job_id         BIGSERIAL       PRIMARY KEY,
    job_name       TEXT            NOT NULL,
    direction      TEXT            NOT NULL CHECK (direction IN ('off2on', 'on2off')),
    source_env     TEXT,
    target_env     TEXT,
    facility_codes TEXT[]          NOT NULL,
    status         TEXT            NOT NULL DEFAULT 'INIT'
                   CHECK (status IN ('INIT','RUNNING','DONE','FAILED')),
    note           TEXT,
    job_params     TEXT,
    started_at     TIMESTAMPTZ,
    finished_at    TIMESTAMPTZ,
    created_at     TIMESTAMPTZ     DEFAULT NOW(),
    updated_at     TIMESTAMPTZ     DEFAULT NOW()
);

COMMENT ON TABLE  migration_job IS '移行ジョブ管理テーブル';
COMMENT ON COLUMN migration_job.direction IS 'off2on(離線→在線) / on2off(在線→離線)';
COMMENT ON COLUMN migration_job.status IS 'INIT / RUNNING / DONE / FAILED';
COMMENT ON COLUMN migration_job.facility_codes IS '対象施設コード配列';
COMMENT ON COLUMN migration_job.job_params IS 'JOB 作成時のリクエストパラメータ（JSON）: uploadIds / seqStartMap など';

CREATE TABLE IF NOT EXISTS migration_task (
    task_id        BIGSERIAL       PRIMARY KEY,
    job_id         BIGINT          NOT NULL REFERENCES migration_job(job_id) ON DELETE CASCADE,
    task_name      TEXT            NOT NULL,
    phase          TEXT            NOT NULL,
    table_name     TEXT            NOT NULL DEFAULT '',
    slice_type     TEXT            NOT NULL DEFAULT 'FULL'
                   CHECK (slice_type IN ('FULL','ID_RANGE','TIME_RANGE')),
    slice_from     TEXT,
    slice_to       TEXT,
    sql_text       TEXT            NOT NULL DEFAULT '',
    status         TEXT            NOT NULL DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','RUNNING','DONE','FAILED')),
    retry_count    INT             NOT NULL DEFAULT 0,
    max_retry      INT             NOT NULL DEFAULT 3,
    estimated_rows BIGINT,
    affected_rows  BIGINT,
    started_at     TIMESTAMPTZ,
    finished_at    TIMESTAMPTZ,
    last_error     TEXT,
    created_at     TIMESTAMPTZ     DEFAULT NOW(),
    updated_at     TIMESTAMPTZ     DEFAULT NOW()
);

COMMENT ON TABLE  migration_task IS 'ジョブ内タスク管理テーブル';
COMMENT ON COLUMN migration_task.phase IS 'PK / FK / JSON_FK / EXPORT / IMPORT / MONGO / FILE';
COMMENT ON COLUMN migration_task.sql_text IS '実行 SQL またはコマンド（デバッグ用）';

CREATE INDEX IF NOT EXISTS idx_task_job_id ON migration_task (job_id);
CREATE INDEX IF NOT EXISTS idx_task_status ON migration_task (job_id, status);
CREATE INDEX IF NOT EXISTS idx_task_phase  ON migration_task (job_id, phase);

CREATE TABLE IF NOT EXISTS migration_task_log (
    log_id       BIGSERIAL       PRIMARY KEY,
    task_id      BIGINT          REFERENCES migration_task(task_id) ON DELETE CASCADE,
    job_id       BIGINT          NOT NULL REFERENCES migration_job(job_id) ON DELETE CASCADE,
    log_time     TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    level        TEXT            NOT NULL CHECK (level IN ('INFO','WARN','ERROR')),
    message      TEXT            NOT NULL,
    thread_name  TEXT
);

COMMENT ON TABLE  migration_task_log IS 'タスク実行ログ（クライアントのオフセットポーリング用）';
COMMENT ON COLUMN migration_task_log.log_id IS 'オフセットポーリングのカーソル';
COMMENT ON COLUMN migration_task_log.thread_name IS 'サーバーログ表示用のスレッド名';

CREATE INDEX IF NOT EXISTS idx_log_job_id  ON migration_task_log (job_id, log_id);
CREATE INDEX IF NOT EXISTS idx_log_task_id ON migration_task_log (task_id);
CREATE INDEX IF NOT EXISTS idx_log_level   ON migration_task_log (job_id, level);

CREATE TABLE IF NOT EXISTS pk_mapping (
    table_name  TEXT            NOT NULL,
    old_id      BIGINT          NOT NULL,
    new_id      BIGINT          NOT NULL,
    job_id      BIGINT          NOT NULL,
    created_at  TIMESTAMPTZ     DEFAULT NOW(),
    PRIMARY KEY (table_name, old_id)
);

COMMENT ON TABLE  pk_mapping IS '新旧 PK 対照テーブル（table_name で対象テーブルを区別）';
COMMENT ON COLUMN pk_mapping.old_id IS '移行元（変換前）PK 値';
COMMENT ON COLUMN pk_mapping.new_id IS '移行先（変換後）PK 値';
COMMENT ON COLUMN pk_mapping.job_id IS '生成元 JOB ID（クリーンアップ用）';

CREATE INDEX IF NOT EXISTS idx_pkmap_table_name ON pk_mapping (table_name);
CREATE INDEX IF NOT EXISTS idx_pkmap_new_id ON pk_mapping (new_id);
CREATE INDEX IF NOT EXISTS idx_pkmap_job_id ON pk_mapping (job_id);

CREATE TABLE IF NOT EXISTS facility_lock (
    facility_cd  TEXT        PRIMARY KEY,
    locked_by    BIGINT,
    locked_at    TIMESTAMPTZ,
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  facility_lock IS '施設ごとの排他ロックテーブル（FOR UPDATE NOWAIT）';
COMMENT ON COLUMN facility_lock.locked_by IS '現在ロックを保持している JOB ID';

CREATE TABLE IF NOT EXISTS fk_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    table_name      TEXT        NOT NULL,
    fk_type         TEXT        NOT NULL CHECK (fk_type IN ('COLUMN', 'JSON')),
    column_name     TEXT,
    json_column     TEXT,
    json_path       TEXT,
    ref_table       TEXT        NOT NULL,
    execution_order INT         NOT NULL DEFAULT 0,
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    where_template  TEXT,
    where_column  TEXT,
    remark          TEXT,
    encrypt_flag    BOOLEAN,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chk_fk_column CHECK (
        (fk_type = 'COLUMN' AND column_name IS NOT NULL) OR
        (fk_type = 'JSON' AND json_column IS NOT NULL AND json_path IS NOT NULL)
    )
);

COMMENT ON TABLE  fk_migration_config IS 'PG テーブルの FK 刷新設定。COLUMN 型・JSON 型（JSONB）対応';
COMMENT ON COLUMN fk_migration_config.fk_type IS 'COLUMN: 通常 FK 列 / JSON: JSONB フィールド内 FK';
COMMENT ON COLUMN fk_migration_config.json_path IS 'PostgreSQL 配列パス形式: {items,itemId}';
COMMENT ON COLUMN fk_migration_config.ref_table IS '参照先テーブル名（pk_mapping.table_name に対応）。主键列名は pk_mapping から推論';
COMMENT ON COLUMN fk_migration_config.execution_order IS '処理順序。依存関係がある場合に制御';
COMMENT ON COLUMN fk_migration_config.enabled IS 'FALSE のときスキップ';
COMMENT ON COLUMN fk_migration_config.where_template IS '多態FK過滤条件（SQL片段）。非 NULL 時は UPDATE の WHERE 句末尾に追加。
  NULL          = 無条件（全行対象）
  例（JSON 内） : (ind_cond_info->''25''->>''medicine_type'')::int = 1';

COMMENT ON COLUMN fk_migration_config.where_column IS '多態FK過滤条件（SQL片段）。非 NULL 時は UPDATE の WHERE 句末尾に追加。
  NULL          = 無条件（全行対象）
  例（列判断）  : supplies_class IN (''08'',''09'',''10'')';

COMMENT ON COLUMN fk_migration_config.encrypt_flag IS '暗号化';


CREATE INDEX IF NOT EXISTS idx_fkconfig_table ON fk_migration_config (table_name, enabled);
CREATE INDEX IF NOT EXISTS idx_fkconfig_order ON fk_migration_config (execution_order) WHERE enabled = TRUE;

CREATE TABLE IF NOT EXISTS fk_mongo_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    collection_name TEXT        NOT NULL,
    field_path      TEXT        NOT NULL,
    ref_table_name  TEXT        NOT NULL,
    field_encoding  TEXT        NOT NULL DEFAULT 'BSON'
                     CHECK (field_encoding IN ('BSON', 'JSON_STRING')),
    execution_order INT         NOT NULL DEFAULT 0,
    where_condition TEXT,
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    remark          TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE  fk_mongo_migration_config IS 'MongoDB 集合の FK 刷新設定。BSON / JSON_STRING をサポート';
COMMENT ON COLUMN fk_mongo_migration_config.field_path IS 'dot path。[] = 配列要素、* = 任意 key。例: items[].item_id / ind_cond_info.*.value';
COMMENT ON COLUMN fk_mongo_migration_config.field_encoding IS 'BSON = MongoDB ネイティブ構造 / JSON_STRING = 文字列 JSON を parse→更新→stringify';
COMMENT ON COLUMN fk_mongo_migration_config.execution_order IS '処理順序。100 = 基礎参照、110 = ord_main 依存、200 = DB6 参照';
COMMENT ON COLUMN fk_mongo_migration_config.where_condition IS '兄弟フィールド条件(JSON)。例: {"medicine_type":1}';

CREATE INDEX IF NOT EXISTS idx_mongofk_collection ON fk_mongo_migration_config (collection_name, enabled);
CREATE INDEX IF NOT EXISTS idx_mongofk_order ON fk_mongo_migration_config (execution_order) WHERE enabled = TRUE;
