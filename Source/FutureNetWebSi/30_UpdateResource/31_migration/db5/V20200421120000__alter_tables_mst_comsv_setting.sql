-- 項目追加
ALTER TABLE mst_comsv_setting ADD COLUMN device_timeout smallint DEFAULT 60;  --装置生存監視時間
ALTER TABLE mst_comsv_setting ADD COLUMN treat_moni_interval smallint DEFAULT 900;  --治療中モニタ通知間隔
ALTER TABLE mst_comsv_setting ADD COLUMN other_moni_interval smallint DEFAULT 3600;  --治療外モニタ通知間隔
-- コメント追加
COMMENT ON COLUMN "mst_comsv_setting"."device_timeout" IS E'装置生存監視時間';
COMMENT ON COLUMN "mst_comsv_setting"."treat_moni_interval" IS E'治療中モニタ通知間隔';
COMMENT ON COLUMN "mst_comsv_setting"."other_moni_interval" IS E'治療外モニタ通知間隔';