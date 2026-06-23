-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 30;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
(30, '003', '施設解約テーブル管理',
'{"exclude_table_list": ["mnt_facility_cancel_manage", "mst_user_authentication", "mst_facility_hash", "mst_facility"],
  "include_table_list": [
     {"db_class": 2, "table_name": "pat_name_identification", "alias_column_name": "facility_cd_src"}],
  "priority_table_list" : [
  { "order" : 1 , "table_name" : "mnt_motion_record" },
  { "order" : 2 , "table_name" : "mnt_notification_status" },
  { "order" : 3 , "table_name" : "mnt_notification_message" },
  { "order" : 4 , "table_name" : "mst_alarm_notification" },
  { "order" : 5 , "table_name" : "mst_complaint" },
  { "order" : 6 , "table_name" : "mst_comp_treatment" },
  { "order" : 7 , "table_name" : "mst_device_set_info_default" },
  { "order" : 8 , "table_name" : "mst_destination_group" },
  { "order" : 9 , "table_name" : "mst_function_report" },
  { "order" : 10 , "table_name" : "mst_monitor_graph" },
  { "order" : 11 , "table_name" : "mst_pat_list_layout" },
  { "order" : 12 , "table_name" : "mst_printer" },
  { "order" : 13 , "table_name" : "mst_report" },
  { "order" : 14 , "table_name" : "mst_round_type" },
  { "order" : 15 , "table_name" : "mst_staff_facility" },
  { "order" : 16 , "table_name" : "mst_status_map_bed_layout" },
  { "order" : 17 , "table_name" : "mst_treatment_status_layout" },
  { "order" : 18 , "table_name" : "mst_weight" },
  { "order" : 19 , "table_name" : "mst_weight_scale" },
  { "order" : 20 , "table_name" : "mst_wheel_chair" },
  { "order" : 21 , "table_name" : "pat_treatment_pattern" }]
  }',
'施設解約で個別に処理が必要なテーブルを管理する', '1', '2020/08/20 10:00:00');