-- 回診記録マスタに通知対象カラム追加
ALTER TABLE
  mst_round_type
ADD COLUMN is_notification character varying(1) DEFAULT '0';

COMMENT ON COLUMN "mst_round_type"."is_notification" IS E'通知対象';