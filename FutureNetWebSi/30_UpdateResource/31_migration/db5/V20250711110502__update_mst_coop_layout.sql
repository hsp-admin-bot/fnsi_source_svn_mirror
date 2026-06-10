DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-11100002,-11100005);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100002, 'Secom', 'exam_ord', '', 'S', 'del', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_オーダーインデックス）', '1', '<root name="透析指⽰電文" useSharedSysdate="true">
  <file name="オーダーインデックス" detail="exam_idx_del" sqlCode="-1105008"/>
  <file name="検体検査" detail="exam_item_del" sqlCode="-1105009"/>
  <file name="検体検査依頼ファイル作成終了" detail="exam_finish" sqlCode="-1105010"/>
</root>', '{"dataset": [{"key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105008, "fileKind": "examind", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_KEN_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105009, "fileKind": "examsken", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105010, "fileKind": "null", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-06-19 11:08:16.349', CURRENT_TIMESTAMP, 'Secom');
