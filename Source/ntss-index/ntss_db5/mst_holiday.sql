DROP INDEX IF EXISTS idx_mst_holiday_01;
CREATE INDEX idx_mst_holiday_01 ON mst_holiday USING btree (facility_cd,is_disp,class);