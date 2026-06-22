DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-11080002);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11080002, 'Secom', 'rep_dial', 'pdf', 'S', 'del', 'text', 'セコム連携_レポート連携(空ファイル)', 'Secom', 'レポート連携(空ファイル)', '1', '<root name="空ファイル">
  <item name="空" len="0" value="const:"/>
</root>
', '{"dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1108000, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-07-30 01:11:49.201', CURRENT_TIMESTAMP, 'Secom');