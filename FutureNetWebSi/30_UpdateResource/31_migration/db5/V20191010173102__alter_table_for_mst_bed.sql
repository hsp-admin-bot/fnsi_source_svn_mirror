--------------------------------------------------
-- ベッドマスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_bed ADD COLUMN is_home_dialysis character varying(1) DEFAULT '0';
-- コメント追加
COMMENT ON COLUMN "mst_bed"."is_home_dialysis" IS E'在宅フラグ';
