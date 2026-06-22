DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -11040013,
-11040014,
-11040015
  );

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11040015, 'Secom', 'ind_dial', '', 'S', 'del', 'csv', 'セコム連携_透析指示連携', 'Secom', '透析指示連携（rootレイアウト）', '1', '<root name="透析指⽰電文">
  <file name="予約受付" detail="予約受付" sqlCode="-1102006"/>
  <file name="処置依頼" detail="処置依頼" sqlCode="-1102007"/>
  <file name="注射依頼" detail="注射依頼" sqlCode="-1102008"/>
  <file name="カルテ記録" detail="カルテ記録" sqlCode="-1102009"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102006, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1102007, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1102008, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102009, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11040014, 'Secom', 'ind_dial', '', 'S', 'upd', 'csv', 'セコム連携_透析指示連携', 'Secom', '透析指示連携（rootレイアウト）', '1', '<root name="透析指⽰電文">
  <file name="予約受付" detail="予約受付" sqlCode="-1102006"/>
  <file name="処置依頼" detail="処置依頼" sqlCode="-1102007"/>
  <file name="注射依頼" detail="注射依頼" sqlCode="-1102008"/>
  <file name="カルテ記録" detail="カルテ記録" sqlCode="-1102009"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102006, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1102007, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1102008, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102009, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11040013, 'Secom', 'ind_dial', '', 'S', 'cre', 'csv', 'セコム連携_透析指示連携', 'Secom', '透析指示連携（rootレイアウト）', '1', '<root name="透析指⽰電文">
  <file name="予約受付" detail="予約受付" sqlCode="-1102006"/>
  <file name="カルテ記録" detail="カルテ記録" sqlCode="-1102009"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "SCHE_FILE_NAME", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102006, "facilityCd": "facilityCd", "file_extension": "csv"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "KARTE_FILE_STR", "ctlNo": "ctlNo", "patId": "patId", "sqlCode": -1102009, "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');