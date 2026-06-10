DROP INDEX IF EXISTS idx_sys_facility_01;
CREATE INDEX idx_sys_facility_01 ON sys_facility USING btree (facility_cd, prefectures_cd, is_del);