DROP INDEX IF EXISTS idx_ord_main_05;
CREATE INDEX idx_ord_main_05
ON ord_main (facility_cd, treat_date, is_del);