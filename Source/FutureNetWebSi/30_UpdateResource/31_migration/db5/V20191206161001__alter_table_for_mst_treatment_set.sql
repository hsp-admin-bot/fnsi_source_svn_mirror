-- 治療方法セットマスタ
-- 項目追加
ALTER TABLE mst_treatment_set ADD COLUMN ind_device_set_info jsonb;
-- コメント追加
COMMENT ON COLUMN "mst_treatment_set"."ind_device_set_info" IS E'装置設定';
