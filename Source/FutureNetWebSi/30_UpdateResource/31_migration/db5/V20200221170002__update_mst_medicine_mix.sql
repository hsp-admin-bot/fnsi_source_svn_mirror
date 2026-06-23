
--------------------------------------------------
-- 調製薬剤マスタ
--------------------------------------------------
-- 項目追加
ALTER TABLE mst_medicine_mix ADD COLUMN unit_decimal_point integer;

-- コメント追加/変更
COMMENT ON COLUMN "mst_medicine_mix"."unit_decimal_point" IS E'指示単位小数部桁数';
COMMENT ON TABLE "mst_medicine_mix" IS E'調製薬剤マスタ';

-- 項目更新
ALTER TABLE mst_medicine_mix ALTER COLUMN amount_unit TYPE numeric;
ALTER TABLE mst_medicine_mix ALTER COLUMN amount_ml TYPE numeric;

