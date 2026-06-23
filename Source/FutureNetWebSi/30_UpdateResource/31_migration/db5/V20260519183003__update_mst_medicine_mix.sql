ALTER TABLE mst_medicine_mix
ADD COLUMN IF NOT EXISTS medicine_set_num int4 DEFAULT 1,
ADD COLUMN IF NOT EXISTS unit_second varchar DEFAULT NULL;
