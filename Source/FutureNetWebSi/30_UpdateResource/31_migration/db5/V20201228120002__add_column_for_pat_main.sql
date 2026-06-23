-- pat_main に列を追加する
ALTER TABLE
  pat_main
ADD COLUMN IF NOT EXISTS host_notification_info jsonb --ホスト報知情報
;

COMMENT ON COLUMN "pat_main"."host_notification_info" IS E'ホスト報知情報';

-- 初期値設定
UPDATE pat_main SET host_notification_info = '{}' WHERE host_notification_info IS NULL;
