-- #12061 ホスト報知のデフォルトデータのすべての施設の upper, lower, interval に空文字が設定されている場合は null に変更する。
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ap,upper}', 'null', false) WHERE host_notification_info #>> '{ap,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ap,lower}', 'null', false) WHERE host_notification_info #>> '{ap,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{vp,upper}', 'null', false) WHERE host_notification_info #>> '{vp,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{vp,lower}', 'null', false) WHERE host_notification_info #>> '{vp,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ufr,upper}', 'null', false) WHERE host_notification_info #>> '{ufr,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ufr,lower}', 'null', false) WHERE host_notification_info #>> '{ufr,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bpmi,interval}', 'null', false) WHERE host_notification_info #>> '{bpmi,interval}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ldqb,upper}', 'null', false) WHERE host_notification_info #>> '{ldqb,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ldqb,lower}', 'null', false) WHERE host_notification_info #>> '{ldqb,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{pulse,upper}', 'null', false) WHERE host_notification_info #>> '{pulse,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{pulse,lower}', 'null', false) WHERE host_notification_info #>> '{pulse,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_ave,upper}', 'null', false) WHERE host_notification_info #>> '{bp_ave,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_ave,lower}', 'null', false) WHERE host_notification_info #>> '{bp_ave,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_max,upper}', 'null', false) WHERE host_notification_info #>> '{bp_max,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_max,lower}', 'null', false) WHERE host_notification_info #>> '{bp_max,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_min,upper}', 'null', false) WHERE host_notification_info #>> '{bp_min,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{bp_min,lower}', 'null', false) WHERE host_notification_info #>> '{bp_min,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{care_i,interval}', 'null', false) WHERE host_notification_info #>> '{care_i,interval}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{na_conc,upper}', 'null', false) WHERE host_notification_info #>> '{na_conc,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{na_conc,lower}', 'null', false) WHERE host_notification_info #>> '{na_conc,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{d_bv_roc,upper}', 'null', false) WHERE host_notification_info #>> '{d_bv_roc,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{d_bv_roc,lower}', 'null', false) WHERE host_notification_info #>> '{d_bv_roc,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ip_speed,upper}', 'null', false) WHERE host_notification_info #>> '{ip_speed,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{ip_speed,lower}', 'null', false) WHERE host_notification_info #>> '{ip_speed,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{blood_flow,upper}', 'null', false) WHERE host_notification_info #>> '{blood_flow,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{blood_flow,lower}', 'null', false) WHERE host_notification_info #>> '{blood_flow,lower}' = '';

UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{dialys_temp,upper}', 'null', false) WHERE host_notification_info #>> '{dialys_temp,upper}' = '';
UPDATE mst_device_set_info_default SET host_notification_info = jsonb_set(host_notification_info, '{dialys_temp,lower}', 'null', false) WHERE host_notification_info #>> '{dialys_temp,lower}' = '';