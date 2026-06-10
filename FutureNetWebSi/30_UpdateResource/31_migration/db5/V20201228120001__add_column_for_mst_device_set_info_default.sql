-- mst_device_set_info_default に列を追加する
ALTER TABLE
  mst_device_set_info_default
ADD COLUMN IF NOT EXISTS host_notification_info jsonb --ホスト報知情報
;

COMMENT ON COLUMN "mst_device_set_info_default"."host_notification_info" IS E'ホスト報知情報';

-- 初期値設定
UPDATE mst_device_set_info_default SET host_notification_info = '{}' WHERE host_notification_info IS NULL;
