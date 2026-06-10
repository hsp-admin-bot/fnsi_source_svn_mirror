DROP INDEX IF EXISTS idx_mst_pat_event_data_template_01;
CREATE INDEX idx_mst_pat_event_data_template_01 ON mst_pat_event_data_template USING btree (facility_cd,is_del);