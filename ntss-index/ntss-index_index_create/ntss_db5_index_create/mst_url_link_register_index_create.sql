DROP INDEX IF EXISTS idx_mst_url_link_register_01;
CREATE INDEX idx_mst_url_link_register_01 ON mst_url_link_register USING btree (facility_cd,url_cd,is_disp,is_del);