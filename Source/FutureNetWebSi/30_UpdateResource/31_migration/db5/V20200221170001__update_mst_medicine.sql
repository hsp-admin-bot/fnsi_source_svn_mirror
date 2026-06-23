
--------------------------------------------------
-- 薬剤マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_medicine ADD COLUMN unit_decimal_point integer;
ALTER TABLE mst_medicine ADD COLUMN unit_decimal_point_second integer;

-- コメント追加/変更
COMMENT ON COLUMN "mst_medicine"."unit_decimal_point" IS E'指示単位小数部桁数';
COMMENT ON COLUMN "mst_medicine"."unit_decimal_point_second" IS E'レセ単位小数部桁数';

-- 項目更新
ALTER TABLE mst_medicine ALTER COLUMN unit_converted_amount TYPE numeric;
ALTER TABLE mst_medicine ALTER COLUMN unit_converted_amount_second TYPE numeric;
ALTER TABLE mst_medicine ALTER COLUMN anticoagulant_original_quantity TYPE numeric;
ALTER TABLE mst_medicine ALTER COLUMN after_anticoagulant_quantity TYPE numeric;
