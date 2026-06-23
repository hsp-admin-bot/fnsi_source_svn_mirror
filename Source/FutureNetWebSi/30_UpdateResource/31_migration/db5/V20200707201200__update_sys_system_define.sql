-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 29;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
(29, '003', '施設解約設定',
 '{
  "max_delete_limit": 1000,
  "expiration": 120,
  "exclude_table_list": [
    "mnt_facility_cancel_manage"
  ],
  "backup_path_template": "/tmp/NTSS_backup_%DATE%/%FACILITY_CD%/%DB_NAME%_%TABLE_NAME%.csv",
  "backup_path_date_format": "yyyyMMdd",
  "backup_fetch_size": 1000
  }',
'施設解約で使用する定数値を設定する。', '1', '2016/06/26')