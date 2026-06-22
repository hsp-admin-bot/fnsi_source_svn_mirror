DROP INDEX IF EXISTS idx_mst_ward_01;
CREATE INDEX idx_mst_ward_01 ON mst_ward USING btree (facility_cd);