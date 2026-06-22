DROP INDEX IF EXISTS idx_mst_pat_event_category_01;
CREATE INDEX idx_mst_pat_event_category_01 ON mst_pat_event_category USING btree (facility_cd,is_del);