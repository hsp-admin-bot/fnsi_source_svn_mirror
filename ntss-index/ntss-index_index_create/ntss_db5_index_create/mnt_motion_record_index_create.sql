DROP INDEX IF EXISTS idx_mnt_motion_record_03;
CREATE INDEX idx_mnt_motion_record_03 ON mnt_motion_record USING btree (facility_cd,ord_no,machine_record_cd,data_type);