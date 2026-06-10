DROP INDEX IF EXISTS idx_mst_device_set_info_default_01;
CREATE INDEX idx_mst_device_set_info_default_01 ON mst_device_set_info_default USING btree (facility_cd);