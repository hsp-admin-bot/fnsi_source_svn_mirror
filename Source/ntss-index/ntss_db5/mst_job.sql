DROP INDEX IF EXISTS idx_mst_job_01;
CREATE INDEX idx_mst_job_01 ON mst_job USING btree (facility_cd,is_disp,is_del);