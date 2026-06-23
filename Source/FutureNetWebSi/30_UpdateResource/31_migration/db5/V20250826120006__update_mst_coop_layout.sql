DELETE FROM mst_coop_layout
WHERE ctl_no IN (-11080001);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11080001, 'Secom', 'rep_dial', 'pdf', 'S', 'cre', 'pdf', 'セコム連携_レポート連携(PDF)', 'Secom', 'レポート連携(PDF)', '1', '<rootnode></rootnode>', NULL, '1', '0', -1, '2025-07-30 01:11:49.194', CURRENT_TIMESTAMP, 'Secom');