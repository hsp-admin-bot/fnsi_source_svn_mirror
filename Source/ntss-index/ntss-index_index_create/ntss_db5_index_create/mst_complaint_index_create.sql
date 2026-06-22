DROP INDEX IF EXISTS idx_mst_complaint_01;
CREATE INDEX idx_mst_complaint_01 ON mst_complaint USING btree (facility_cd,is_del);