-- 項目追加
ALTER TABLE mst_comsv_setting ADD COLUMN offline_start_time smallint; --オフライン運転開始時間
ALTER TABLE mst_comsv_setting ADD COLUMN is_offline_auto_end character varying(1) DEFAULT '0';  --オフライン運転自動終了
ALTER TABLE mst_comsv_setting ADD COLUMN reload_next_pat_time character varying(4) DEFAULT '0100';  --日付変更時次患者更新時刻
ALTER TABLE mst_comsv_setting ADD COLUMN next_pat_mode smallint DEFAULT 1;  --次患者送信モード
ALTER TABLE mst_comsv_setting ADD COLUMN next_pat_mode_range smallint DEFAULT 7;  --次患者検索期間
-- コメント追加
COMMENT ON COLUMN "mst_comsv_setting"."offline_start_time" IS E'オフライン運転自動開始時間';
COMMENT ON COLUMN "mst_comsv_setting"."is_offline_auto_end" IS E'オフライン運転自動終了';
COMMENT ON COLUMN "mst_comsv_setting"."reload_next_pat_time" IS E'日付変更時次患者更新時刻';
COMMENT ON COLUMN "mst_comsv_setting"."next_pat_mode" IS E'次患者送信モード';
COMMENT ON COLUMN "mst_comsv_setting"."next_pat_mode_range" IS E'次患者検索期間';
