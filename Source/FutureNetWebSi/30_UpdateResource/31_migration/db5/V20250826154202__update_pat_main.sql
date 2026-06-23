-- #12061 患者情報のすべての患者データのホスト報知情報の upper, lower, interval に空文字が設定されている場合は null に変更する。
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ap,upper}', 'null', false) WHERE host_notification_info #>> '{ap,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ap,lower}', 'null', false) WHERE host_notification_info #>> '{ap,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{vp,upper}', 'null', false) WHERE host_notification_info #>> '{vp,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{vp,lower}', 'null', false) WHERE host_notification_info #>> '{vp,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ufr,upper}', 'null', false) WHERE host_notification_info #>> '{ufr,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ufr,lower}', 'null', false) WHERE host_notification_info #>> '{ufr,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bpmi,interval}', 'null', false) WHERE host_notification_info #>> '{bpmi,interval}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ldqb,upper}', 'null', false) WHERE host_notification_info #>> '{ldqb,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ldqb,lower}', 'null', false) WHERE host_notification_info #>> '{ldqb,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{pulse,upper}', 'null', false) WHERE host_notification_info #>> '{pulse,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{pulse,lower}', 'null', false) WHERE host_notification_info #>> '{pulse,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_ave,upper}', 'null', false) WHERE host_notification_info #>> '{bp_ave,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_ave,lower}', 'null', false) WHERE host_notification_info #>> '{bp_ave,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_max,upper}', 'null', false) WHERE host_notification_info #>> '{bp_max,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_max,lower}', 'null', false) WHERE host_notification_info #>> '{bp_max,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_min,upper}', 'null', false) WHERE host_notification_info #>> '{bp_min,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{bp_min,lower}', 'null', false) WHERE host_notification_info #>> '{bp_min,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{care_i,interval}', 'null', false) WHERE host_notification_info #>> '{care_i,interval}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{na_conc,upper}', 'null', false) WHERE host_notification_info #>> '{na_conc,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{na_conc,lower}', 'null', false) WHERE host_notification_info #>> '{na_conc,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{d_bv_roc,upper}', 'null', false) WHERE host_notification_info #>> '{d_bv_roc,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{d_bv_roc,lower}', 'null', false) WHERE host_notification_info #>> '{d_bv_roc,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ip_speed,upper}', 'null', false) WHERE host_notification_info #>> '{ip_speed,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{ip_speed,lower}', 'null', false) WHERE host_notification_info #>> '{ip_speed,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{blood_flow,upper}', 'null', false) WHERE host_notification_info #>> '{blood_flow,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{blood_flow,lower}', 'null', false) WHERE host_notification_info #>> '{blood_flow,lower}' = '';

UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{dialys_temp,upper}', 'null', false) WHERE host_notification_info #>> '{dialys_temp,upper}' = '';
UPDATE pat_main SET host_notification_info = jsonb_set(host_notification_info, '{dialys_temp,lower}', 'null', false) WHERE host_notification_info #>> '{dialys_temp,lower}' = '';