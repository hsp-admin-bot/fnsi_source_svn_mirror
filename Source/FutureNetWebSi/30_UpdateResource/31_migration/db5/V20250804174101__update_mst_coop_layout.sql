DELETE FROM ntss.mst_coop_layout
WHERE ctl_no in (-11170001, -11170002, -11170003);
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11170001, 'Secom', 'karte_ord', '', 'S', 'cre', 'csv', 'セコム連携_指示変更履歴連携', 'Secom', '指示変更履歴連携', '1', '<root name="指示変更履歴電文" useSharedSysdate="true">
  <file name="カルテ記載ファイル" detail="karte_ord_all" sqlCode="-1107005"/>
</root>
', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107055, "facilityCd": "facilityCd", "is_zero_end": "true", "logTreatmentEndDate": "logTreatmentEndDate"}, {"key0": "key0", "key1": "SCM_IND_CHANGE_LOG", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107005, "fileKind": "emrnote", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', -1, '2025-06-07 13:30:11.438', '2025-06-07 13:30:11.438', 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11170002, 'Secom', 'karte_ord', '', 'S', 'upd', 'csv', 'セコム連携_指示変更履歴連携', 'Secom', '指示変更履歴連携', '1', '<root name="指示変更履歴電文" useSharedSysdate="true">
  <file name="カルテ記載ファイル" detail="karte_ord_all" sqlCode="-1107005"/>
</root>
', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107055, "facilityCd": "facilityCd", "is_zero_end": "true", "logTreatmentEndDate": "logTreatmentEndDate"}, {"key0": "key0", "key1": "SCM_IND_CHANGE_LOG", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107005, "fileKind": "emrnote", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', -1, '2025-06-07 13:30:11.438', '2025-06-07 13:30:11.438', 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11170003, 'Secom', 'karte_ord', '', 'S', 'del', 'csv', 'セコム連携_指示変更履歴連携', 'Secom', '指示変更履歴連携', '1', '<root name="指示変更履歴電文" useSharedSysdate="true">
  <file name="カルテ記載ファイル" detail="karte_ord_all" sqlCode="-1107005"/>
</root>
', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107056, "facilityCd": "facilityCd", "is_zero_end": "true", "logTreatmentEndDate": "logTreatmentEndDate"}, {"key0": "key0", "key1": "SCM_IND_CHANGE_LOG", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107005, "fileKind": "emrnote", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '0', -1, '2025-06-07 13:30:11.438', '2025-06-07 13:30:11.438', 'Secom');