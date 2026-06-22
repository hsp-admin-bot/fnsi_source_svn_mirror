DROP INDEX IF EXISTS idx_mst_user_01;
CREATE INDEX idx_mst_user_01 ON mst_user USING btree (facility_cd,pat_id,is_disp,is_del);