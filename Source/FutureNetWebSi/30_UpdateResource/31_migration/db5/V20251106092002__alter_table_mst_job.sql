-- 列の追加
ALTER TABLE mst_job
ADD COLUMN IF NOT EXISTS default_disp_settings jsonb;


-- コメント修正
COMMENT ON COLUMN "mst_job"."default_disp_settings" IS E'デフォルト表示設定';