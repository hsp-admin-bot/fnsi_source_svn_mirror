DROP INDEX IF EXISTS idx_mst_addition_01;
CREATE INDEX idx_mst_addition_01 ON mst_addition USING btree (facility_cd,is_del);