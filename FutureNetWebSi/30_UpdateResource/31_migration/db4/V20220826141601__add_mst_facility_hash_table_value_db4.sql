ALTER TABLE
  mst_facility_hash
ADD COLUMN
  value varchar(3)
;
COMMENT ON COLUMN "mst_facility_hash"."value" IS '値';
