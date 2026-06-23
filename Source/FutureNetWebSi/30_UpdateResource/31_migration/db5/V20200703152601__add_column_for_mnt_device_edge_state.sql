-- 死活監視メール送信状況追加
ALTER TABLE
  mnt_device_edge_state
  ADD COLUMN IF NOT EXISTS send_mail_status smallint;

-- コメント修正
COMMENT ON COLUMN "mnt_device_edge_state"."send_mail_status" IS E'死活監視メール送信状況';