# 04 データベース設計文書

> **対象 DB**: PostgreSQL 17（中転 DB / convert 管理 DB）
> **スキーマ**: `public`（デフォルト）
> **管理方式**: SQL スクリプト（手動適用）

---

## 1. テーブル一覧

| テーブル名 | 用途 | 備考 |
|-----------|------|------|
| `migration_job` | 1 回の移行ジョブ管理 | |
| `migration_task` | ジョブ内の各タスク管理 | |
| `migration_task_log` | タスク実行ログ | 任意だが強く推奨 |
| `pk_mapping` | 新旧 PK 対照テーブル | 単純フラットテーブル |
| `fk_migration_config` | PG FK 刷新設定 | |
| `fk_mongo_migration_config` | Mongo FK 刷新設定 | |
| `facility_lock` | 施設ごとの並行制御ロック | |

---

## 2. 完整 DDL

### 2.1 migration_job（移行ジョブ管理）

```sql
-- =============================================================
-- migration_job: 1 回の移行ジョブを表す
-- =============================================================
CREATE TABLE migration_job (
    job_id        BIGSERIAL       PRIMARY KEY,
    job_name      TEXT            NOT NULL,
    direction     TEXT            NOT NULL CHECK (direction IN ('off2on', 'on2off')),
    source_env    TEXT,                       -- 移行元環境識別子 (例: 'offline', 'online')
    target_env    TEXT,                       -- 移行先環境識別子 (例: 'online', 'offline')
    facility_codes TEXT[]         NOT NULL,   -- 対象施設コード配列
    started_at    TIMESTAMPTZ,
    finished_at   TIMESTAMPTZ,
    status        TEXT            NOT NULL DEFAULT 'INIT'
                  CHECK (status IN ('INIT','RUNNING','DONE','FAILED')),
    note          TEXT,                       -- 備考・中断理由など
    created_at    TIMESTAMPTZ     DEFAULT NOW(),
    updated_at    TIMESTAMPTZ     DEFAULT NOW()
);

COMMENT ON TABLE migration_job IS '移行ジョブ管理テーブル。1 リクエスト = 1 レコード';
COMMENT ON COLUMN migration_job.job_id IS 'ジョブ ID（自動採番）';
COMMENT ON COLUMN migration_job.direction IS '移行方向: off2on（離線→在線）/ on2off（在線→離線）';
COMMENT ON COLUMN migration_job.facility_codes IS '対象施設コードの配列';
COMMENT ON COLUMN migration_job.status IS 'INIT:作成済 / RUNNING:実行中 / DONE:完了 / FAILED:失敗';
```

---

### 2.2 migration_task（タスク管理）

```sql
-- =============================================================
-- migration_task: ジョブ内の個別タスクを表す（最核心テーブル）
-- =============================================================
CREATE TABLE migration_task (
    task_id        BIGSERIAL       PRIMARY KEY,
    job_id         BIGINT          NOT NULL REFERENCES migration_job(job_id) ON DELETE CASCADE,
    task_name      TEXT            NOT NULL,   -- 例: 'TASK1_PG_IMPORT', 'TASK2_PK_MAPPING'
    phase          TEXT            NOT NULL,   -- PK / FK / JSON_FK / EXPORT / IMPORT / MONGO / FILE
    table_name     TEXT            NOT NULL,   -- 対象テーブル名 (コレクション名)

    -- スライス情報（断点再開用）
    slice_type     TEXT            NOT NULL DEFAULT 'FULL'
                   CHECK (slice_type IN ('FULL', 'ID_RANGE', 'TIME_RANGE')),
    slice_from     TEXT,                       -- 例: '100000' (ID) / '2005-01-01' (日付)
    slice_to       TEXT,                       -- 例: '200000' / '2010-01-01'

    sql_text       TEXT            NOT NULL DEFAULT '',  -- 実行 SQL テキスト（記録用）

    status         TEXT            NOT NULL DEFAULT 'PENDING'
                   CHECK (status IN ('PENDING','RUNNING','DONE','FAILED')),
    retry_count    INT             NOT NULL DEFAULT 0,
    max_retry      INT             NOT NULL DEFAULT 3,

    estimated_rows BIGINT,                     -- 推定処理件数
    affected_rows  BIGINT,                     -- 実際の処理件数

    started_at     TIMESTAMPTZ,
    finished_at    TIMESTAMPTZ,
    last_error     TEXT,                       -- 最後のエラーメッセージ

    created_at     TIMESTAMPTZ     DEFAULT NOW(),
    updated_at     TIMESTAMPTZ     DEFAULT NOW()
);

COMMENT ON TABLE migration_task IS 'ジョブ内のタスク管理テーブル';
COMMENT ON COLUMN migration_task.phase IS 'タスク種別: PK/FK/JSON_FK/EXPORT/IMPORT/MONGO/FILE';
COMMENT ON COLUMN migration_task.slice_type IS 'スライス方式: FULL/ID_RANGE/TIME_RANGE';
COMMENT ON COLUMN migration_task.sql_text IS '実行した SQL またはコマンドの記録（デバッグ用）';
COMMENT ON COLUMN migration_task.retry_count IS '現在のリトライ回数';
COMMENT ON COLUMN migration_task.last_error IS '最後に発生したエラーメッセージ';

-- インデックス
CREATE INDEX idx_task_job_id   ON migration_task (job_id);
CREATE INDEX idx_task_status   ON migration_task (job_id, status);
CREATE INDEX idx_task_phase    ON migration_task (job_id, phase);
```

---

### 2.3 migration_task_log（タスクログ）

```sql
-- =============================================================
-- migration_task_log: タスク実行ログ（クライアントポーリング用）
-- =============================================================
CREATE TABLE migration_task_log (
    log_id      BIGSERIAL       PRIMARY KEY,
    task_id     BIGINT          REFERENCES migration_task(task_id) ON DELETE CASCADE,
    job_id      BIGINT          NOT NULL REFERENCES migration_job(job_id) ON DELETE CASCADE,
    log_time    TIMESTAMPTZ     NOT NULL DEFAULT NOW(),
    level       TEXT            NOT NULL CHECK (level IN ('INFO','WARN','ERROR')),
    message     TEXT            NOT NULL
);

COMMENT ON TABLE migration_task_log IS 'タスク実行ログ。クライアントのオフセットポーリングに対応';
COMMENT ON COLUMN migration_task_log.log_id IS 'ログ ID（オフセットポーリングのカーソルとして使用）';
COMMENT ON COLUMN migration_task_log.job_id IS 'ジョブ単位での高速検索用';

-- インデックス（オフセットポーリング用）
CREATE INDEX idx_log_job_id    ON migration_task_log (job_id, log_id);
CREATE INDEX idx_log_task_id   ON migration_task_log (task_id);
CREATE INDEX idx_log_level     ON migration_task_log (job_id, level);
```

---

### 2.4 pk_mapping（新旧 PK 対照テーブル）

```sql
-- =============================================================
-- pk_mapping: 新旧 PK の対照マッピング（単純フラットテーブル）
-- (table_name, old_id) を複合 PK とし、table_name で区別する
-- =============================================================
CREATE TABLE pk_mapping (
    table_name  TEXT            NOT NULL,   -- 対象テーブル名
    old_id      BIGINT          NOT NULL,   -- 元の PK 値
    new_id      BIGINT          NOT NULL,   -- 新しい PK 値
    job_id      BIGINT          NOT NULL,   -- どの JOB で生成されたか
    created_at  TIMESTAMPTZ     DEFAULT NOW(),
    PRIMARY KEY (table_name, old_id)
);

COMMENT ON TABLE pk_mapping IS '新旧 PK 対照テーブル。table_name カラムで対象テーブルを区別';
COMMENT ON COLUMN pk_mapping.old_id IS '移行元（変換前）の PK 値';
COMMENT ON COLUMN pk_mapping.new_id IS '移行先（変換後）の PK 値';
COMMENT ON COLUMN pk_mapping.job_id IS '生成元 JOB ID（クリーンアップ用）';

-- インデックス
CREATE INDEX idx_pkmap_table_name ON pk_mapping (table_name);
CREATE INDEX idx_pkmap_new_id     ON pk_mapping (new_id);
CREATE INDEX idx_pkmap_job_id     ON pk_mapping (job_id);
```

---

### 2.5 fk_migration_config（PG FK 刷新設定）

```sql
-- =============================================================
-- fk_migration_config: PostgreSQL FK 刷新の設定テーブル
-- COLUMN 型（通常カラム）と JSON 型（JSONB フィールド内）を定義
-- =============================================================
CREATE TABLE fk_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    table_name      TEXT        NOT NULL,       -- FK を更新する対象テーブル
    fk_type         TEXT        NOT NULL CHECK (fk_type IN ('COLUMN', 'JSON')),
    column_name     TEXT,                       -- COLUMN 型: FK カラム名
    json_column     TEXT,                       -- JSON 型: JSONB カラム名
    json_path       TEXT,                       -- JSON 型: パス例 '{items,itemId}'
    ref_table       TEXT        NOT NULL,       -- 参照先テーブル（pk_mapping.table_name）
    execution_order INT         NOT NULL DEFAULT 0,  -- 実行順序（昇順）
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    remark          TEXT,                       -- 備考
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fk_migration_config IS 'PG テーブルの FK 刷新設定。COLUMN 型と JSON 型（JSONB）に対応';
COMMENT ON COLUMN fk_migration_config.fk_type IS 'COLUMN: 通常 FK カラム / JSON: JSONB フィールド内 FK';
COMMENT ON COLUMN fk_migration_config.json_path IS 'PostgreSQL 配列パス形式: {items,itemId}';
COMMENT ON COLUMN fk_migration_config.execution_order IS '処理順序。依存関係がある場合に制御';
COMMENT ON COLUMN fk_migration_config.enabled IS 'FALSE の場合は処理をスキップ';

-- チェック制約: COLUMN 型は column_name 必須、JSON 型は json_column + json_path 必須
ALTER TABLE fk_migration_config ADD CONSTRAINT chk_fk_column
    CHECK (
        (fk_type = 'COLUMN' AND column_name IS NOT NULL) OR
        (fk_type = 'JSON'   AND json_column IS NOT NULL AND json_path IS NOT NULL)
    );

CREATE INDEX idx_fkconfig_table ON fk_migration_config (table_name, enabled);
CREATE INDEX idx_fkconfig_order ON fk_migration_config (execution_order) WHERE enabled = TRUE;

-- データ例: COLUMN 型
INSERT INTO fk_migration_config (table_name, fk_type, column_name, ref_table)
VALUES
    ('order_detail', 'COLUMN', 'order_id', 'order_tbl'),
    ('order_detail', 'COLUMN', 'item_id',  'item_tbl'),
    ('invoice',      'COLUMN', 'user_id',  'user_tbl');

-- データ例: JSON 型
INSERT INTO fk_migration_config (table_name, fk_type, json_column, json_path, ref_table)
VALUES
    ('order_tbl', 'JSON', 'payload', '{items,itemId}', 'item_tbl'),
    ('order_tbl', 'JSON', 'payload', '{userId}',       'user_tbl');
```

---

### 2.6 fk_mongo_migration_config（Mongo FK 刷新設定）

```sql
-- =============================================================
-- fk_mongo_migration_config: MongoDB 集合的 FK 刷新配置
-- 以 dot path 格式支持顶层字段、嵌套对象、数组内字段
-- 支持多态FK（where_condition）、JSON字符串容器（field_encoding）
-- 支持执行顺序控制（execution_order）
-- =============================================================
CREATE TABLE fk_mongo_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    collection_name TEXT        NOT NULL,       -- 目标 MongoDB 集合名
    field_path      TEXT        NOT NULL,       -- dot path（见下方说明）
    field_encoding  TEXT        NOT NULL DEFAULT 'BSON'
                    CHECK (field_encoding IN ('BSON', 'JSON_STRING')),
                                                -- BSON        = MongoDB 原生结构，直接寻址
                                                -- JSON_STRING = 字段值为 JSON 字符串，需
                                                --               parse → 修改 → stringify 后写回
    ref_table_name  TEXT        NOT NULL,       -- 对应 pk_mapping.table_name
    execution_order INT         NOT NULL DEFAULT 0,  -- 执行顺序（升序）
    where_condition TEXT,                       -- 兄弟字段过滤条件（JSON格式），NULL = 无条件
                                                -- 运行时对数组元素或文档追加此条件后再刷新
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    remark          TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fk_mongo_migration_config IS 'MongoDB 集合的 FK 刷新配置。支持顶层字段、数组嵌套、多态FK、JSON字符串容器';
COMMENT ON COLUMN fk_mongo_migration_config.field_path IS
    'dot path 格式。规则：
      [] 表示数组，对数组中每个元素的指定字段刷新
      数字字符串 key 直接用点连接（无需 []）
    示例：
      up_user_id                          顶层标量字段
      ind_schedule_user_info.ind_user_id  嵌套对象字段
      ind_medi_info[].cd                  数组内字段
      ind_cond_info.5.value               数字key对象（{"5":{"value":"..."}}）
      ind_cond_info.15.value              同上，编号15';
COMMENT ON COLUMN fk_mongo_migration_config.field_encoding IS
    'BSON（默认）：字段为 MongoDB 原生 BSON 结构，直接读写。
     JSON_STRING：字段值是 JSON 字符串（如 ord_main_hst 的 ind_schedule_user_info），
                  需先 JSON.parse() 找到目标值，修改后 JSON.stringify() 写回。';
COMMENT ON COLUMN fk_mongo_migration_config.where_condition IS
    '兄弟字段过滤条件，JSON 格式，NULL = 无条件刷新所有匹配元素。
     示例（多态FK）：{"medicine_type": 1}    → 仅 medicine_type=1 的元素刷新
                     {"medicine_type": 2}    → 仅 medicine_type=2 的元素刷新
                     {"equip_type": 0}       → 仅 equip_type=0 的元素刷新
     示例（条件FK）：{"doctor_is_free": "0"} → 仅非自由文字输入时刷新';
COMMENT ON COLUMN fk_mongo_migration_config.execution_order IS '处理顺序（升序）。被引用集合先于引用集合处理';

CREATE INDEX idx_mongofk_collection ON fk_mongo_migration_config (collection_name, enabled);
CREATE INDEX idx_mongofk_order ON fk_mongo_migration_config (execution_order) WHERE enabled = TRUE;

-- ---------------------------------------------------------------------------
-- 数据示例：顶层标量 / 普通嵌套数组 / JSON字符串嵌套 / 多态FK / 条件FK
-- ---------------------------------------------------------------------------

-- 顶层标量字段
INSERT INTO fk_mongo_migration_config (collection_name, field_path, ref_table_name, execution_order) VALUES
    ('rst_history',              'ord_no',      'ord_main',          110),
    ('rst_history',              'up_user_id',  'mst_user',          100),
    ('ord_main_hst',             'ord_no',      'ord_main',          110),
    ('ord_main_hst',             'pat_id',      'pat_personal_main', 100),
    ('pat_group_detail_history', 'pat_id',      'pat_personal_main', 100),
    ('pat_group_detail_history', 'pat_group_cd','pat_group',         100);

-- BSON 数组内字段（普通FK）
INSERT INTO fk_mongo_migration_config (collection_name, field_path, ref_table_name, execution_order) VALUES
    ('pat_main_history', 'addition_info[].cd',                  'mst_addition',   100),
    ('pat_main_history', 'charge_staff_info[].staff_cd',        'mst_user',       100),
    ('pat_main_history', 'pat_group_info[].pat_group_cd',       'pat_group',      100),
    ('pat_main_history', 'taboo_allergy_info[].taboo_allergy_cd','mst_taboo_allergy',100),
    ('pat_main_history', 'infect_info[].infection_cd',          'mst_infection',  100),
    ('pat_main_history', 'implant_info[].implant_cd',           'mst_implant',    100);

-- JSON_STRING 嵌套字段（field_encoding='JSON_STRING'）
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order) VALUES
    ('ord_main_hst', 'ind_schedule_user_info.ind_user_id', 'JSON_STRING', 'mst_user', 100),
    ('ord_main_hst', 'ind_schedule_user_info.upd_user_id', 'JSON_STRING', 'mst_user', 100);

-- 多态FK（where_condition で分岐）
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, field_encoding, ref_table_name, execution_order, where_condition, remark) VALUES
    ('ord_main_hst', 'ind_medi_info[].cd', 'JSON_STRING', 'mst_medicine',     110,
     '{"medicine_type": 1}', '多态FK: medicine_type=1 → 通常薬剤'),
    ('ord_main_hst', 'ind_medi_info[].cd', 'JSON_STRING', 'mst_medicine_mix', 110,
     '{"medicine_type": 2}', '多態FK: medicine_type=2 → 調製薬剤'),
    ('ord_main_hst', 'ind_equip_info[].cd','JSON_STRING', 'mst_equipment',    110,
     '{"equip_type": 0}',    '多态FK: equip_type=0 → 器材'),
    ('ord_main_hst', 'ind_equip_info[].cd','JSON_STRING', 'mst_dialyzer',     110,
     '{"equip_type": 1}',    '多态FK: equip_type=1 → ダイアライザ');

-- 条件FK（where_condition で is_free フィルタ）
INSERT INTO fk_mongo_migration_config
    (collection_name, field_path, ref_table_name, execution_order, where_condition, remark) VALUES
    ('pat_unique_history', 'in_out_visit_history_info[].from_doctor', 'mst_user',   100,
     '{"doctor_is_free": "0"}', '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].to_doctor',   'mst_user',   100,
     '{"doctor_is_free": "0"}', '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].from_course', 'mst_course', 100,
     '{"course_is_free": "0"}', '自由入力時はFK刷新しない'),
    ('pat_unique_history', 'in_out_visit_history_info[].to_course',   'mst_course', 100,
     '{"course_is_free": "0"}', '自由入力時はFK刷新しない');
```

**field_encoding と where_condition の組み合わせ:**

| field_encoding | where_condition | 処理内容 |
|----------------|-----------------|----------|
| BSON           | NULL            | BSON フィールドを無条件刷新 |
| BSON           | JSON条件        | BSON フィールドを条件付きで刷新（配列要素の兄弟フィールドで判定） |
| JSON_STRING    | NULL            | JSON文字列をパースして無条件刷新、stringify して書き戻す |
| JSON_STRING    | JSON条件        | JSON文字列をパースして条件付きで刷新、stringify して書き戻す |


---

### 2.7 facility_lock（施設並行制御ロック）

```sql
-- =============================================================
-- facility_lock: 同一施設の重複実行防止用ロックテーブル
-- PostgreSQL の SELECT ... FOR UPDATE NOWAIT を利用
-- =============================================================
CREATE TABLE facility_lock (
    facility_cd  TEXT        PRIMARY KEY,   -- 施設コード
    locked_by    BIGINT,                    -- ロック中の JOB ID
    locked_at    TIMESTAMPTZ,               -- ロック取得時刻
    updated_at   TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE facility_lock IS '施設ごとの排他ロックテーブル。FOR UPDATE NOWAIT で競合検出';
COMMENT ON COLUMN facility_lock.locked_by IS '現在ロックを保持している JOB ID';

-- 初期データ投入（対象施設ごとに 1 行を事前 INSERT しておく）
-- INSERT INTO facility_lock (facility_cd) VALUES ('FAC001'), ('FAC002'), ...;
```

---

## 3. ER 図（ASCII）

```
┌─────────────────────────┐
│      migration_job      │
├─────────────────────────┤
│ job_id     BIGSERIAL PK │◀──────────────────────────────┐
│ job_name   TEXT         │                               │
│ direction  TEXT         │                               │
│ facility_codes TEXT[]   │                               │
│ status     TEXT         │                               │
│ started_at TIMESTAMPTZ  │                               │
│ finished_at TIMESTAMPTZ │                               │
└──────────┬──────────────┘                               │
           │ 1:N                                          │
┌──────────▼──────────────┐                               │
│      migration_task     │                               │
├─────────────────────────┤                               │
│ task_id   BIGSERIAL PK  │◀──────────────────────────┐  │
│ job_id    BIGINT FK ────┼───────────────────────────┼──┘
│ task_name TEXT          │                           │
│ phase     TEXT          │                           │
│ table_name TEXT         │                           │
│ status    TEXT          │                           │
│ retry_count INT         │                           │
│ estimated_rows BIGINT   │                           │
│ affected_rows  BIGINT   │                           │
└──────────┬──────────────┘                           │
           │ 1:N                                      │
┌──────────▼──────────────┐                           │
│    migration_task_log   │                           │
├─────────────────────────┤                           │
│ log_id   BIGSERIAL PK   │                           │
│ task_id  BIGINT FK ─────┼───────────────────────────┘
│ job_id   BIGINT FK      │
│ log_time TIMESTAMPTZ    │
│ level    TEXT           │
│ message  TEXT           │
└─────────────────────────┘


┌─────────────────────────────────┐
│           pk_mapping            │
├─────────────────────────────────┤
│ table_name  TEXT    PK          │
│ old_id      BIGINT  PK          │
│ new_id      BIGINT              │
│ job_id      BIGINT              │
│ created_at  TIMESTAMPTZ         │
└─────────────────────────────────┘
  複合 PK: (table_name, old_id)
  INDEX: table_name, new_id, job_id


┌──────────────────────────────┐
│     fk_migration_config      │
├──────────────────────────────┤
│ id            BIGSERIAL PK   │
│ table_name    TEXT           │
│ fk_type       TEXT(COLUMN/JSON)
│ column_name   TEXT           │
│ json_column   TEXT           │
│ json_path     TEXT           │
│ ref_table     TEXT ──────────┼──▶ pk_mapping.table_name
│ execution_order INT          │
│ enabled       BOOLEAN        │
└──────────────────────────────┘

┌──────────────────────────────┐
│  fk_mongo_migration_config   │
├──────────────────────────────┤
│ id             BIGSERIAL PK  │
│ collection_name TEXT         │
│ field_path      TEXT         │
│ ref_table_name  TEXT ────────┼──▶ pk_mapping.table_name
│ enabled         BOOLEAN      │
└──────────────────────────────┘

┌──────────────────────────────┐
│        facility_lock         │
├──────────────────────────────┤
│ facility_cd  TEXT PK         │
│ locked_by    BIGINT ─────────┼──▶ migration_job.job_id
│ locked_at    TIMESTAMPTZ     │
└──────────────────────────────┘
```

---

## 4. pk_mapping テーブル設計

### 4.1 単純フラットテーブル設計の採用理由

`pk_mapping` は単純フラットテーブルとして実装する（PARTITION BY LIST は採用しない）。

**理由**:
- LIST 分区はテーブルごとの分区を初期化 SQL に事前作成する必要があり、`pg_dump_config.yaml` のテーブル追加のたびに DDL 変更が必要になる
- 単純テーブル + 複合インデックス（`(table_name, old_id)` 複合 PK + `table_name` インデックス）で実用上十分なパフォーマンスを達成できる
- NTSS の移行対象テーブル数は限定的（数十テーブル）のため、分区プルーニングの恩恵は小さい

**アクセスパターンとインデックス対応**:
- 書き込み: `INSERT INTO pk_mapping (table_name, old_id, new_id, job_id)` → 複合 PK で効率的
- 読み込み: `SELECT new_id FROM pk_mapping WHERE table_name = ? AND old_id = ?` → 複合 PK でカバー
- FK 刷新: `WHERE new_id = ?` の逆引き → `idx_pkmap_new_id` でカバー
- クリーンアップ: `DELETE WHERE job_id = ?` → `idx_pkmap_job_id` でカバー

---

## 5. インデックス戦略

| テーブル | インデックス名 | カラム | 目的 |
|---------|--------------|-------|------|
| `migration_task` | `idx_task_job_id` | `job_id` | JOB 単位でタスク検索 |
| `migration_task` | `idx_task_status` | `(job_id, status)` | ステータス別タスク取得 |
| `migration_task_log` | `idx_log_job_id` | `(job_id, log_id)` | オフセットポーリング |
| `migration_task_log` | `idx_log_level` | `(job_id, level)` | レベルフィルタ検索 |
| `pk_mapping` | `idx_pkmap_new_id` | `new_id` | FK 刷新時の逆引き |
| `fk_migration_config` | `idx_fkconfig_order` | `execution_order` WHERE `enabled` | 実行順取得 |
| `fk_mongo_migration_config` | `idx_mongofk_collection` | `(collection_name, enabled)` | コレクション単位取得 |

---

## 6. データライフサイクル

| テーブル | 挿入タイミング | 削除タイミング |
|---------|-------------|-------------|
| `migration_job` | POST /jobs 実行時 | 手動（監査証跡として保持推奨） |
| `migration_task` | JOB 作成時に全タスク一括 INSERT | JOB 削除時（CASCADE） |
| `migration_task_log` | 各タスク実行中（非同期） | JOB 削除時（CASCADE） |
| `pk_mapping` | Task 2（PK マッピング生成）完了時 | JOB 正常完了（DONE）後に自動削除 |
| `fk_migration_config` | 初期設定時（SQL スクリプト投入） | 設定変更時のみ |
| `fk_mongo_migration_config` | 初期設定時（SQL スクリプト投入） | 設定変更時のみ |
| `facility_lock` | 施設コード追加時（事前登録） | 施設廃止時のみ |

### 6.1 pk_mapping の自動削除処理

```sql
-- JOB 正常完了後（DONE）に pk_mapping の当該 JOB データを削除
DELETE FROM pk_mapping WHERE job_id = :completedJobId;
```

JOB が FAILED の場合はデータを保持し、デバッグや再開再利用に活用する。

---

## 7. convert_db 初期化スクリプト構成

```
src/main/resources/db/migration/
├── V1__create_core_tables.sql          # migration_job, migration_task, migration_task_log
├── V2__create_pk_mapping.sql           # pk_mapping（単純フラットテーブル + インデックス）
├── V4__create_fk_configs.sql           # fk_migration_config, fk_mongo_migration_config
├── V5__create_facility_lock.sql        # facility_lock
└── V6__insert_initial_fk_config.sql    # FK 設定の初期データ（NTSS テーブル向け）
```

> **注意**: V3（pk_mapping 分区テーブル）と V7（converter_user テーブル）は廃止済み。
> V7 は作成不要。認証は在線生産 DB（ntss_db4）の `mst_user_authentication` テーブルを使用する。

---

## 8. 接続情報設定（application.yaml 抜粋）

```yaml
spring:
  datasource:
    # Converter 管理 DB（migration_job, pk_mapping 等が入る）
    converter:
      url: jdbc:postgresql://localhost:5432/convert_db
      username: converter_user
      password: ${CONVERTER_DB_PASSWORD}

    # 中転 DB（3 インスタンス）
    transit-db1:
      url: jdbc:postgresql://localhost:5432/transit_db_1
      username: transit_user
      password: ${TRANSIT_DB1_PASSWORD}
    transit-db2:
      url: jdbc:postgresql://localhost:5432/transit_db_2
      username: transit_user
      password: ${TRANSIT_DB2_PASSWORD}
    transit-db3:
      url: jdbc:postgresql://localhost:5432/transit_db_3
      username: transit_user
      password: ${TRANSIT_DB3_PASSWORD}

    # 在線生産 RDS（読み書き）
    online-prod:
      url: jdbc:postgresql://${RDS_HOST}:5432/prod_db
      username: prod_user
      password: ${PROD_DB_PASSWORD}

  data:
    mongodb:
      # 中転 Mongo
      transit:
        uri: mongodb://localhost:27017/transit_mongo
      # 在線生産 DocumentDB
      online:
        uri: mongodb://${DOCDB_HOST}:27017/prod_mongo?ssl=true
```
