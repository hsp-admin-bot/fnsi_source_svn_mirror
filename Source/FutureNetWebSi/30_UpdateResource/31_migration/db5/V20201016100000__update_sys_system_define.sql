-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 29;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
(29, '003', '施設解約設定',
 '{
  "max_delete_limit": 1000,
  "backup_path_template_cancel": "/tmp/NTSS_backup_%FACILITY_CD%/%DATE%/%DB_NAME%_%TABLE_NAME%.csv",
  "backup_path_template_expire": "",
  "backup_path_date_format": "yyyyMMdd",
  "backup_fetch_size": 1000
  }',
'施設解約で使用する定数値を設定する。', '1', now());

DELETE FROM sys_system_define WHERE ctl_no = 30;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
(30, '003', '施設解約テーブル管理',
'{"exclude_table_list": ["mnt_facility_cancel_manage", "mst_user_authentication", "mst_facility_hash", "mst_facility"],
  "include_table_list": [{"db_class": 2, "table_name": "mst_alarm_notification", "alias_column_name": "destination_facility_cd"}],
  "priority_table_list" : [
  { "order" : 1 , "table_name" : "mnt_motion_record" },
  { "order" : 2 , "table_name" : "mst_staff_facility" },
  { "order" : 3 , "table_name" : "mnt_notification_status" },
  { "order" : 4 , "table_name" : "mst_alarm_notification" },
  { "order" : 5 , "table_name" : "mst_function_report" }]
  }',
'施設解約で個別に処理が必要なテーブルを管理する', '1', now());