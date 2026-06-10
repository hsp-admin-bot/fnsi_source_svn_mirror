--------------------------------------------------
-- ベッドレイアウトマスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_status_map_bed_layout ADD COLUMN is_home_dialysis character varying(1) DEFAULT '0';
-- コメント追加
COMMENT ON COLUMN "mst_status_map_bed_layout"."is_home_dialysis" IS E'在宅フラグ';
