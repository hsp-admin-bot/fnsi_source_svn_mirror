INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12071001, 'F_SX', 'rst_dial', '', 'S', 'cre', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', -1, '2025-05-12 14:04:44.865', '2025-05-12 14:04:44.865', 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12072001, 'F_SX', 'rst_dial', '', 'S', 'upd', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', -1, '2025-05-12 14:04:44.865', '2025-05-12 14:04:44.865', 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12073001, 'F_SX', 'rst_dial', '', 'S', 'del', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', -1, '2025-05-12 14:04:44.865', '2025-05-12 14:04:44.865', 'F_SX');
