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
  { "order" : 5 , "table_name" : "mst_function_report" }],
  "rems_cancel_target_table_list" : ["mst_selector", "mst_alarm_notification", "mst_m_notice"],
  "fnsi_cancel_exclude_table_list" : [
    "mst_facility_hash","mst_user_authentication","sys_signin_manager",
    "mni_monitor","mnt_client_connect","mnt_device_edge_manage",
    "mnt_find_machine","mnt_gathering_manage","mnt_machine_state",
    "mnt_motion_record","mnt_notification_message","mnt_notification_status",
    "mst_alarm_notification","mst_bed","mst_destination_group",
    "mst_device_edge","mst_facility_setting","mst_m_notice",
    "mst_machine","mst_notification_message","mst_self_measure_result",
    "mst_user","mst_personal_user","sys_notification_list",
    "sys_facility","sal_subscription_manage"
  ]
  }',
'施設解約で個別に処理が必要なテーブルを管理する', '1', now());