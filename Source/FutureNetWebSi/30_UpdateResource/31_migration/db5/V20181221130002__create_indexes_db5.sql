-- インデックス削除（装置モニタデータ）
DROP INDEX IF EXISTS idx_mni_monitor_01;

-- インデックス追加（装置モニタデータ）
CREATE INDEX idx_mni_monitor_01 ON mni_monitor (facility_cd,machine_type_cd,machine_serial,occur_date);

-- インデックス削除（装置動作記録）
DROP INDEX IF EXISTS idx_mnt_motion_record_01;

-- インデックス追加（装置動作記録）
CREATE INDEX idx_mnt_motion_record_01 ON mnt_motion_record (facility_cd,machine_type_cd);
