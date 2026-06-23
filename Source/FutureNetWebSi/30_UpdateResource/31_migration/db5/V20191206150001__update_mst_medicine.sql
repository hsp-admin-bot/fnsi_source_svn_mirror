
--------------------------------------------------
-- 薬剤マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_medicine ADD COLUMN is_exchange character varying(1) DEFAULT '0';

-- コメント追加/変更
COMMENT ON COLUMN "mst_medicine"."is_exchange" IS E'換算フラグ';
COMMENT ON COLUMN "mst_medicine"."unit" IS E'指示単位';
COMMENT ON COLUMN "mst_medicine"."unit_second" IS E'レセ単位';
COMMENT ON COLUMN "mst_medicine"."unit_converted_amount" IS E'指示単位換算量';
COMMENT ON COLUMN "mst_medicine"."unit_converted_amount_second" IS E'レセ単位換算量';
COMMENT ON COLUMN "mst_medicine"."anticoagulant_original_quantity" IS E'指示基準量';
COMMENT ON COLUMN "mst_medicine"."after_anticoagulant_quantity" IS E'ML基準量';
