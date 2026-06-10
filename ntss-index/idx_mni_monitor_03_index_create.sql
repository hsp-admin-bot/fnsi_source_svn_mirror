DROP INDEX IF EXISTS idx_mni_monitor_03;
CREATE INDEX idx_mni_monitor_03 ON mni_monitor USING btree (ord_no);