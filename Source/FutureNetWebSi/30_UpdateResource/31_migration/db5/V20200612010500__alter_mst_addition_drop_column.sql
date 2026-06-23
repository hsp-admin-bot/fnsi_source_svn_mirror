-- 項目削除
ALTER TABLE mst_addition
DROP COLUMN IF EXISTS addition_class_no,
DROP COLUMN IF EXISTS week_cnt;
