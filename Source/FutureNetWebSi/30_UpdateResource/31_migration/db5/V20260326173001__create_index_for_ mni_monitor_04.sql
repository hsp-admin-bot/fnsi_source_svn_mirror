DROP INDEX IF EXISTS idx_mni_monitor_04;
CREATE INDEX idx_mni_monitor_04
ON mni_monitor (facility_cd, ord_no, is_del, data_type);