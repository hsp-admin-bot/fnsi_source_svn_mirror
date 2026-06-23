-- 項目削除
ALTER TABLE mst_medicine_mix
DROP COLUMN IF EXISTS use_start_date,
DROP COLUMN IF EXISTS use_end_date;
