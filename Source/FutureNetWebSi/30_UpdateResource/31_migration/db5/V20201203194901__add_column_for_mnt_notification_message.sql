--mnt_notification_messageに列を追加する
ALTER TABLE
  mnt_notification_message
ADD COLUMN IF NOT EXISTS notification_no int8 --通知定義番号
;

COMMENT ON COLUMN "mnt_notification_message"."notification_no" IS E'通知定義番号';

