DROP INDEX IF EXISTS idx_pat_main_01;
CREATE INDEX idx_pat_main_01
ON pat_main (facility_cd, is_del);
