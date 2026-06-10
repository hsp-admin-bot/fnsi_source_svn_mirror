DROP INDEX IF EXISTS idx_bbs_info_01;
CREATE INDEX idx_bbs_info_01 ON bbs_info USING btree (facility_cd,is_del,is_disp,kind_no,notice_fac_cal_start_date,notice_fac_cal_end_date);