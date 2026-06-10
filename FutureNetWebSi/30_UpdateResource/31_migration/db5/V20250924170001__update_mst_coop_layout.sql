DELETE FROM ntss.mst_coop_layout
WHERE ctl_no in (-11100000, -11100002, -11110000, -11110001);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100002, 'Secom', 'exam_ord', '', 'S', 'del', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_オーダーインデックス）', '1', '<root name="透析指⽰電文" useSharedSysdate="true">
<file name="オーダーインデックス" detail="exam_idx_del" sqlCode="-1105008"/>
<file name="検体検査" detail="exam_item_del" sqlCode="-1105009"/>
<file name="検体検査依頼ファイル作成終了" detail="exam_finish" sqlCode="-1105010"/>
</root>', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "exam_ord", "sqlCode": -1105008, "fileKind": "examind", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_KEN_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "exam_ord", "sqlCode": -1105009, "fileKind": "examsken", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105010, "fileKind": "null", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-09-19 11:48:58.748', CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100000, 'Secom', 'exam_ord', '', 'S', 'cre', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル）', '1', '<root name="透析指⽰電文" useSharedSysdate="true">
<file name="オーダーインデックス" detail="exam_idx_cre" sqlCode="-1105008"/>
<file name="検体検査" detail="exam_item_cre" sqlCode="-1105009"/>
<file name="検体検査依頼ファイル作成終了" detail="exam_finish" sqlCode="-1105010"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "exam_ord", "sqlCode": -1105008, "fileKind": "examind", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "EXAM_KEN_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "exam_ord", "sqlCode": -1105009, "fileKind": "examsken", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_EXAM_ORDER_SEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105010, "fileKind": "null", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-09-19 11:48:58.748', CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11110000, 'Secom', 'rad_ord', '', 'S', 'cre', 'csv', 'セコム連携_放射線オーダー連携', 'Secom', '放射線オーダー（rootレイアウト）', '1', '<root name="放射線オーダー電文" useSharedSysdate="true">
<file name="オーダーインデックス" detail="idx_top_cre" sqlCode="-1106001"/>
<file name="処方ヘッダー" detail="head_top_cre" sqlCode="-1106002"/>
<file name="実施単位" detail="ipn_top_cre" sqlCode="-1106003"/>
<file name="画像依頼ファイル作成終了" detail="rad_finish" sqlCode="-1106004"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -1106009, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"crud": "cre", "key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rad_ord", "sqlCode": -1106001, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106002, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IPN_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rad_ord", "sqlCode": -1106003, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106004, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-09-24 15:50:02.373', CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11110001, 'Secom', 'rad_ord', '', 'S', 'del', 'csv', 'セコム連携_放射線オーダー連携', 'Secom', '放射線オーダー（rootレイアウト）', '1', '<root name="放射線オーダー電文" useSharedSysdate="true">
<file name="オーダーインデックス" detail="idx_top_del" sqlCode="-1106001"/>
<file name="処方ヘッダー" detail="head_top_del" sqlCode="-1106002"/>
<file name="実施単位" detail="ipn_top_del" sqlCode="-1106003"/>
<file name="画像依頼ファイル作成終了" detail="rad_finish" sqlCode="-1106004"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rad_ord", "sqlCode": -1106001, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106002, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IPN_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rad_ord", "sqlCode": -1106003, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106004, "fileKind": "xray", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-09-24 15:50:02.373', CURRENT_TIMESTAMP, 'Secom');