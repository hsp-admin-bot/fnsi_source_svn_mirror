-- 項目追加
ALTER TABLE mst_facility ADD COLUMN facility_type integer;
ALTER TABLE mst_facility ADD COLUMN bulk_approve integer;
-- コメント追加
COMMENT ON COLUMN "mst_facility"."facility_type" IS E'受付・承認単位';
COMMENT ON COLUMN "mst_facility"."bulk_approve" IS E'一括承認';
--初期データ
update mst_facility
set facility_type = 1, bulk_approve = 1