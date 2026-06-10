UPDATE sys_system_define
SET VALUE
        = jsonb_set(VALUE, '{rems_cancel_target_table_list}', '["mst_alarm_notification", "mst_m_notice"]' )
WHERE ctl_no = 30;
UPDATE sys_system_define
SET VALUE
        = jsonb_set(VALUE, '{fnsi_cancel_exclude_table_list}', '[
    "mst_facility_hash","mst_user_authentication","sys_signin_manager",
    "mni_monitor","mnt_client_connect","mnt_device_edge_manage",
    "mnt_find_machine","mnt_gathering_manage","mnt_machine_state",
    "mnt_motion_record","mnt_notification_message","mnt_notification_status",
    "mst_alarm_notification","mst_bed","mst_destination_group",
    "mst_device_edge","mst_facility_setting","mst_m_notice",
    "mst_machine","mst_notification_message","mst_self_measure_result",
    "mst_user","mst_personal_user","sys_notification_list",
    "sys_facility","sal_subscription_manage"
  ]' )
WHERE ctl_no = 30;
