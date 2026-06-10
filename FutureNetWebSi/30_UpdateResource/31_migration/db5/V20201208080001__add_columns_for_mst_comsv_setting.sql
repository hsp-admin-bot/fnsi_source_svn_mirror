ALTER TABLE ntss.mst_comsv_setting DROP COLUMN treat_monitor_notification_interval;
ALTER TABLE ntss.mst_comsv_setting DROP COLUMN other_monitor_notification_interval;

ALTER TABLE ntss.mst_comsv_setting ADD treat_realtime_monito_interval int2 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_comsv_setting.treat_realtime_monito_interval IS '治療中リアルタイムモニタ通知間隔';

ALTER TABLE ntss.mst_comsv_setting ADD other_realtime_monito_interval int2 NULL DEFAULT 0;
COMMENT ON COLUMN ntss.mst_comsv_setting.other_realtime_monito_interval IS '治療外リアルタイムモニタ通知間隔';