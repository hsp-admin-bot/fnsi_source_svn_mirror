DROP INDEX IF EXISTS idx_mst_device_edge_01;
CREATE INDEX idx_mst_device_edge_01 ON mst_device_edge USING btree (facility_cd);