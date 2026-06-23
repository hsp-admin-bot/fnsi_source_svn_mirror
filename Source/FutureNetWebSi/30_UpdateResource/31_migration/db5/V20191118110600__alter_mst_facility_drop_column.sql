-- 項目削除
ALTER TABLE mst_facility 
DROP COLUMN IF EXISTS facility_type;

ALTER TABLE mst_facility 
DROP COLUMN IF EXISTS bulk_approve;