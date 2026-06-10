-- カラム追加
ALTER TABLE sys_data_set
ADD COLUMN IF NOT EXISTS pre_sql_info jsonb;

-- コメント修正
COMMENT ON COLUMN "sys_data_set"."pre_sql_info" IS E'事前取得データ情報';