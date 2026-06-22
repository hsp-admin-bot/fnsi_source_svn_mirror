DROP INDEX IF EXISTS idx_mst_coop_distribute_01;
CREATE INDEX idx_mst_coop_distribute_01 ON mst_coop_distribute USING btree (facility_cd,is_del);