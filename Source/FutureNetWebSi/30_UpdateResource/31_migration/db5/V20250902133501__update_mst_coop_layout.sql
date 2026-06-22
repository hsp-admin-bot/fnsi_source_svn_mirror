DELETE FROM mst_coop_layout WHERE ctl_no IN (-4080004);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4080004, 'P_hosp', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'パナソニック 透析レポート(pdf)', 'Medicom', 'report', '1', '<rootnode></rootnode>', NULL, '1', '0', 4, '2020-05-25 18:26:36.811', CURRENT_TIMESTAMP, 'MED');