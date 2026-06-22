INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11070000, 'Secom', 'rst_dial', '', 'S', 'cre', 'csv', 'セコム連携_透析実績連携', 'Secom', '透析実績連携（rootレイアウト）', '1', '<root name="透析実績電文" useSharedSysdate="true">
  <file name="カルテ記録" detail="med_top_cre" sqlCode="-1100010"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100010, "fileKind": "medical", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11070001, 'Secom', 'rst_dial', '', 'S', 'del', 'csv', 'セコム連携_透析実績連携', 'Secom', '透析実績連携（rootレイアウト）', '1', '<root name="透析実績電文" useSharedSysdate="true">
  <file name="カルテ記録" detail="med_top_del" sqlCode="-1100010"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100010, "fileKind": "medical", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');

