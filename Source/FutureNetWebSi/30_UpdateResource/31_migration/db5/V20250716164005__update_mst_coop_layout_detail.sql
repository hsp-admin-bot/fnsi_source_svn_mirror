DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-1208100001);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1208100001, 'F_SX', 'rep_dial', 'S', 'report', '05', 'SX連携', '透析レポート', '1', '<root><REPORT STARTDATE="dataset:-400006.start_date8a" STARTTIME="dataset:-400006.start_date6a" DATETIMEVALUE="dataset:-400006.start_date14" BEDNAME="dataset:-400006.bed_name" DIALYSIS_NO="dataset:-400006.dialysis_no" EDITION="dataset:-400006.edition" UPDATE_DATETIME="dataset:-400006.up_date" /></root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -400006}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
