DROP INDEX IF EXISTS idx_mst_bed_01;
CREATE INDEX idx_mst_bed_01 ON mst_bed USING btree (facility_cd,machine_no,bed_no);