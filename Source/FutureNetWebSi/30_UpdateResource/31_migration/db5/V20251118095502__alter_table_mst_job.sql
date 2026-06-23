-- 列の追加
ALTER TABLE mst_job
ADD COLUMN IF NOT EXISTS default_notification_settings jsonb;


-- コメント修正
COMMENT ON COLUMN "mst_job"."default_notification_settings" IS E'デフォルト通知設定';