
DROP INDEX IF EXISTS idx_mnt_motion_record_02;

CREATE INDEX idx_mnt_motion_record_02 ON ntss.mnt_motion_record USING btree (facility_cd, machine_type_cd, data_type, ord_no);

