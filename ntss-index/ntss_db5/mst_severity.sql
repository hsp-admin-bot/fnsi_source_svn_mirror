DROP INDEX IF EXISTS idx_mst_severity_01;
CREATE INDEX idx_mst_severity_01 ON mst_severity USING btree (facility_cd);