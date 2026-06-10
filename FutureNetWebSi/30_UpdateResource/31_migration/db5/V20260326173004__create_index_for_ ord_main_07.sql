DROP INDEX IF EXISTS idx_ord_main_07;
CREATE INDEX idx_ord_main_07
ON ord_main (facility_cd, pat_id, rst_start_date DESC)
INCLUDE (rst_treatment_cd, rst_weight_info)
WHERE is_del = '0';