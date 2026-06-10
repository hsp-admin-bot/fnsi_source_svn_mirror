--mnt_motion_recordにインデックスを追加
CREATE INDEX IF NOT EXISTS idx_mnt_motion_record_02 ON mnt_motion_record USING btree (facility_cd, machine_type_cd, data_type);
