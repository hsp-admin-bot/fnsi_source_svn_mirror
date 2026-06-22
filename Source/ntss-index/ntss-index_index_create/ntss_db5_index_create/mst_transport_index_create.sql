DROP INDEX IF EXISTS idx_mst_transport_01;
CREATE INDEX idx_mst_transport_01 ON mst_transport USING btree (facility_cd);