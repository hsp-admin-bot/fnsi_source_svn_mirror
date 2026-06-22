DELETE FROM ntss.mst_coop_layout
WHERE ctl_no in (-11110000, -11110001, -11110002, -11110003, -11110004, -11110005, -11110006, -11110007, -11110008);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11110000, 'Secom', 'rad_ord', '', 'S', 'cre', 'csv', 'セコム連携_放射線オーダー連携', 'Secom', '放射線オーダー（rootレイアウト）', '1', '<root name="放射線オーダー電文" useSharedSysdate="true">
  <file name="オーダーインデックス" detail="idx_top_cre" sqlCode="-1106001"/>
  <file name="処方ヘッダー" detail="head_top_cre" sqlCode="-1106002"/>
  <file name="実施単位" detail="ipn_top_cre" sqlCode="-1106003"/>
  <file name="画像依頼ファイル作成終了" detail="rad_finish" sqlCode="-1106004"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IDX_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106001, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_HEAD_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106002, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IPN_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106003, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"ctlNo": "ctlNo", "sqlCode": -1106004, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-07-09 22:24:56.725', CURRENT_TIMESTAMP, 'Secom');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11110001, 'Secom', 'rad_ord', '', 'S', 'del', 'csv', 'セコム連携_放射線オーダー連携', 'Secom', '放射線オーダー（rootレイアウト）', '1', '<root name="放射線オーダー電文" useSharedSysdate="true">
  <file name="オーダーインデックス" detail="idx_top_del" sqlCode="-1106001"/>
  <file name="処方ヘッダー" detail="head_top_del" sqlCode="-1106002"/>
  <file name="実施単位" detail="ipn_top_del" sqlCode="-1106003"/>
  <file name="画像依頼ファイル作成終了" detail="rad_finish" sqlCode="-1106004"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IDX_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106001, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_HEAD_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106002, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_XRAY_ORDER_SEND", "key2": "XRAY_IPN_FILE_STR", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106003, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}, {"ctlNo": "ctlNo", "sqlCode": -1106004, "facilityCd": "facilityCd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-07-09 22:24:56.725', CURRENT_TIMESTAMP, 'Secom');