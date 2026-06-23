--------------------------------------------------
-- 職種マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_job ADD COLUMN default_authorized_authorities character varying(200);
-- コメント追加
COMMENT ON COLUMN "mst_job"."default_authorized_authorities" IS E'デフォルト権限設定';

-- 初期値導入
UPDATE mst_job set default_authorized_authorities = '' WHERE default_authorized_authorities IS NULL;
