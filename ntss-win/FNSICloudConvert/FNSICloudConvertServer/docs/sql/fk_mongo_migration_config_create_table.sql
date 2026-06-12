-- =============================================================
-- fk_mongo_migration_config 建表脚本
-- 生成日期: 2026-03-24
-- 依据: docs/04_database.md ### 2.6 fk_mongo_migration_config
-- =============================================================

DROP TABLE IF EXISTS fk_mongo_migration_config;

CREATE TABLE fk_mongo_migration_config (
    id              BIGSERIAL   PRIMARY KEY,
    collection_name TEXT        NOT NULL,       -- 目标 MongoDB 集合名
    field_path      TEXT        NOT NULL,       -- dot path（见下方 COMMENT）
    field_encoding  TEXT        NOT NULL DEFAULT 'BSON'
                    CHECK (field_encoding IN ('BSON', 'JSON_STRING')),
                                                -- BSON        = MongoDB 原生结构，直接寻址
                                                -- JSON_STRING = 字段值为 JSON 字符串，需
                                                --               parse → 修改 → stringify 后写回
    ref_table_name  TEXT        NOT NULL,       -- 对应 pk_mapping.table_name
    execution_order INT         NOT NULL DEFAULT 0,  -- 执行顺序（升序）
    where_condition TEXT,                       -- 兄弟字段过滤条件（JSON格式），NULL = 无条件
    enabled         BOOLEAN     NOT NULL DEFAULT TRUE,
    remark          TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

COMMENT ON TABLE fk_mongo_migration_config IS 'MongoDB 集合的 FK 刷新配置。支持顶层字段、数组嵌套、多态FK、JSON字符串容器';

COMMENT ON COLUMN fk_mongo_migration_config.field_path IS
    'dot path 格式。规則：
      []  表示数组，对数组中每个元素的指定字段刷新
      *   通配符，表示对象的任意 key（用于数字字符串 key 等不定 key 的遍历）
      数字字符串 key 直接用点连接（无需 []）
    示例：
      up_user_id                          顶层标量字段
      ind_schedule_user_info.ind_user_id  JSON_STRING 内嵌套对象字段
      ind_medi_info[].cd                  JSON_STRING 内数组元素字段
      ind_cond_info.5.value               JSON_STRING 内数字 key 对象（{"5":{"value":"..."}}）
      ind_cond_info.*.ind_user_id         JSON_STRING 内所有 key 下的 ind_user_id
      ind_device_set_info.*.ind_user_id   JSON_STRING 内任意设备类别 key 下的 ind_user_id';

COMMENT ON COLUMN fk_mongo_migration_config.field_encoding IS
    'BSON（默认）：字段为 MongoDB 原生 BSON 结构，直接读写。
     JSON_STRING：字段值是 JSON 字符串（如 ord_main_hst 的各嵌套字段），
                  需先 JSON.parse() 找到目标值，修改后 JSON.stringify() 写回。';

COMMENT ON COLUMN fk_mongo_migration_config.where_condition IS
    '数组元素内的兄弟字段过滤条件，JSON 格式，NULL = 无条件刷新所有匹配元素。
     示例（多态FK）：{"medicine_type": 1}    → 仅 medicine_type=1 的元素刷新
                     {"medicine_type": 2}    → 仅 medicine_type=2 的元素刷新
                     {"equip_type": 0}       → 仅 equip_type=0 的元素刷新
     示例（条件FK）：{"doctor_is_free": "0"} → 仅非自由文字输入时刷新';

COMMENT ON COLUMN fk_mongo_migration_config.execution_order IS
    '処理順序（昇順）。参考基準：
      100 = mst_* / pat_personal_main 等基础表引用
      110 = ord_main.ord_no 引用
      200 = DB6 テーブル引用（pat_insurance 等）';

CREATE INDEX idx_mongofk_collection ON fk_mongo_migration_config (collection_name, enabled);
CREATE INDEX idx_mongofk_order      ON fk_mongo_migration_config (execution_order) WHERE enabled = TRUE;
