-- 列の追加
ALTER TABLE sys_notification
ADD COLUMN IF NOT EXISTS help character varying;

-- コメント修正
COMMENT ON COLUMN "sys_notification"."help" IS E'通知内容説明';