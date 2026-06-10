ALTER TABLE mst_facility ADD COLUMN advanced_settings jsonb;
COMMENT ON COLUMN "mst_facility"."advanced_settings" IS E'拡張設定';