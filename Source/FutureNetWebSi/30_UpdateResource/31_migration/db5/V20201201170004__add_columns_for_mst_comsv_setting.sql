ALTER TABLE ntss.mst_comsv_setting ADD treat_monitor_notification_interval int2 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_comsv_setting.treat_monitor_notification_interval IS '治療中バイタル通知間隔';

ALTER TABLE ntss.mst_comsv_setting ADD other_monitor_notification_interval int2 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_comsv_setting.other_monitor_notification_interval IS '治療外バイタル通知間隔';