-- 利用者マスタ
-- 項目追加
ALTER TABLE mst_user ADD COLUMN pat_id bigint;
-- コメント追加
COMMENT ON COLUMN "mst_user"."pat_id" IS E'システムで管理する一意な患者ID';
