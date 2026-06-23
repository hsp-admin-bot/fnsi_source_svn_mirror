ALTER TABLE ord_material_save ADD COLUMN IF NOT EXISTS medicine_no JSON;
COMMENT ON COLUMN "ord_material_save"."medicine_no" IS '薬剤識別番号';

ALTER TABLE ord_material_save ADD COLUMN IF NOT EXISTS procedure_cd VARCHAR(255);
COMMENT ON COLUMN "ord_material_save"."procedure_cd" IS '手技コード';

ALTER TABLE ord_material_save ADD COLUMN IF NOT EXISTS timing_cd VARCHAR(255);
COMMENT ON COLUMN "ord_material_save"."timing_cd" IS '投与タイミングコード';
