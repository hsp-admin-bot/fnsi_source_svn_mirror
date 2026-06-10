ALTER TABLE mst_facility
DROP COLUMN IF EXISTS retention_period;
ALTER TABLE mst_facility
ADD COLUMN retention_period INTEGER DEFAULT 0;

COMMENT ON COLUMN "mst_facility"."retention_period" IS E'データ保持期間';