DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (
-1104000002,
-1104000003,
-1104000004,
-1104000005,
-1104000011,
-1104000012,
-1104000013,
-1104000014,
-1104000034,
-1104000035,
-1104000036,
-1104000037,
-1104000038,
-1104000039,
-1104000040,
-1104000041,
-1104000042,
-1104000043,
-1104000044,
-1104000045,
-1104000046,
-1104000047
  );

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000002, 'Secom', 'ind_dial', 'S', 'trt_top_cre', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_処置依頼', '1', '<root name="処置依頼" useSharedSysdate="true">
  <file name="オーダーインデックス" detail="trt_index_cre" sqlCode="-1102016"/>
  <file name="処置ヘッダー" detail="trt_header_cre" sqlCode="-1102017"/>
  <file name="処置単位" detail="trt_unit_top_cre" sqlCode="-1102018"/>
  <file name="処置項目" detail="trt_item_top_cre" sqlCode="-1102019"/>
  <file name="ファイル作成終了" detail="trt_finish" sqlCode="-1102020"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102016, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102017, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102018, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102019, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102020, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-06-26 23:35:08.627', current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000003, 'Secom', 'ind_dial', 'S', 'trt_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_処置依頼', '1', '<root name="処置依頼" useSharedSysdate="true">
  <file name="オーダーインデックス" detail="trt_index_del" sqlCode="-1102016"/>
  <file name="処置ヘッダー" detail="trt_header_del" sqlCode="-1102017"/>
  <file name="処置単位" detail="trt_unit_top_del" sqlCode="-1102018"/>
  <file name="処置項目" detail="trt_item_top_del" sqlCode="-1102019"/>
  <file name="ファイル作成終了" detail="trt_finish" sqlCode="-1102020"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102016, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102017, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102018, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102019, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102020, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-06-26 23:35:08.627', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000004, 'Secom', 'ind_dial', 'S', 'trt_unit_top_cre', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
  <record detail="trt_unit_cre" sqlCode="-1102015"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102015, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-27 14:08:24.400', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000005, 'Secom', 'ind_dial', 'S', 'trt_item_top_cre', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
  <record detail="trt_item_cre" sqlCode="-1102002"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-27 14:08:24.400', current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000011, 'Secom', 'ind_dial', 'S', 'inj_top_cre', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_注射依頼_cre', '1', '<root name="透析指示_注射依頼" useSharedSysdate="true">
  <file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1102021"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_cre" sqlCode="-1102022"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_cre" sqlCode="-1102023"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1102024"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102021, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102022, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102023, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102024, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-06-26 23:43:00.020', current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000012, 'Secom', 'ind_dial', 'S', 'inj_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_注射依頼_del', '1', '<root name="透析指示_注射依頼" useSharedSysdate="true">
  <file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1102021"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_del" sqlCode="-1102022"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_del" sqlCode="-1102023"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1102024"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102021, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102022, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102023, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1102024, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-06-26 23:43:00.020', current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000013, 'Secom', 'ind_dial', 'S', 'inj_unit_top_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_cre" sqlCode="-1102003" />
</root>', '{"dataset": [{"crud": "cre", "key0": "-1102023.key0", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "coopCd": "ind_dial", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}', '1', '0', -1, '2025-07-08 15:03:27.649', CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000014, 'Secom', 'ind_dial', 'S', 'inj_item_top_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_cre" sqlCode="-1102011" />
</root>', '{"dataset": [{"crud": "cre", "key0": "-1102024.key0", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "coopCd": "ind_dial", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}', '1', '0', -1, '2025-07-08 15:03:27.649', CURRENT_TIMESTAMP, 'Secom');

-- 予約受付
INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000034, 'Secom', 'ind_dial', 'S', 'res_top_del', '02', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_予約受付_del', '1', '<root name="セコム連携_透析指示_予約受付" multi="true:CRLF">
  <item name="更新モード" value="const:1"/>
  <item name="予約担当者ユーザID" value="dataset:-1102000.res_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="受付・予約タイプ" value="const:1"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104000.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>', '{"dataset": [{"key0": "-1102006.key0", "ctlNo": "-1102006.ctl_no", "ordNo": "-1102006.ord_no", "patId": "-1102006.pat_id", "sqlCode": -1102000, "facilityCd": "-1102006.facility_cd"}, {"key0": "-1102006.key0", "patId": "-1102006.pat_id", "sqlCode": -1100006, "facilityCd": "-1102006.facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "-1102006.facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');

-- 注射依頼
INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000035, 'Secom', 'ind_dial', 'S', 'inj_index_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:11"/>
  <item name="タイトル" value="dataset:-1102000.shot_title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1102000.treat_date"/>
  <item name="終了日" value="dataset:-1102000.treat_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102021.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1100000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "patId": "-1102021.pat_id", "sqlCode": -1100006, "facilityCd": "-1102021.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000036, 'Secom', 'ind_dial', 'S', 'inj_header_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="未使用" value="$BLANK"/>
  <item name="注射種別コード" value="dataset:-1102000.shot_type"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP数" value="dataset:-1102000.rp_num_sum"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処方コメント" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102022.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1100000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "patId": "-1102022.pat_id", "sqlCode": -1100006, "facilityCd": "-1102022.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000037, 'Secom', 'ind_dial', 'S', 'inj_unit_top_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_del" sqlCode="-1102003" />
</root>', '{"dataset": [{"crud": "del", "key0": "-1102023.key0", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "coopCd": "ind_dial", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000038, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号" value="dataset:-1102010.rp_num"/>
  <item name="処方開始日" value="dataset:-1102000.treat_date"/>
  <item name="投与日数" value="const:1"/>
  <item name="隔日" value="const:0"/>
  <item name="処方終了日" value="dataset:-1102000.treat_date"/>
  <item name="薬品数" value="dataset:-1102010.medi_count"/>
  <item name="手技" value="dataset:-1102010.procedure_hosp_cd"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="一日回数" value="const:1"/>
  <item name="タイミング1" value="$BLANK"/>
  <item name="タイミング2" value="$BLANK"/>
  <item name="タイミング3" value="$BLANK"/>
  <item name="タイミング4" value="$BLANK"/>
  <item name="タイミング5" value="$BLANK"/>
  <item name="コメントコード" value="$BLANK"/>
  <item name="フリーコメント" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102003.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "sortKey": "-1102003.sort_key", "sqlCode": -1102010, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "patId": "-1102003.pat_id", "sqlCode": -1100006, "facilityCd": "-1102003.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000039, 'Secom', 'ind_dial', 'S', 'inj_item_top_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_del" sqlCode="-1102011" />
</root>', '{"dataset": [{"crud": "del", "key0": "-1102024.key0", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "coopCd": "ind_dial", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000040, 'Secom', 'ind_dial', 'S', 'inj_item_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号(処置番号)" value="dataset:-1102012.rp_num"/>
  <item name="薬品番号" value="dataset:-1102012.medi_num"/>
  <item name="薬品コード" value="dataset:-1102012.medi_cd"/>
  <item name="用量" value="dataset:-1102012.medi_amount"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1102012.unit_convert"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102011.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1100000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "sortKey": "-1102011.sort_key", "sqlCode": -1102012, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "patId": "-1102011.pat_id", "sqlCode": -1100006, "facilityCd": "-1102011.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

-- 処置依頼
INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000041, 'Secom', 'ind_dial', 'S', 'trt_index_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_オーダーインデックス', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:61"/>
  <item name="タイトル" value="dataset:-1102000.treat_title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1102000.treat_date"/>
  <item name="終了日" value="dataset:-1102000.treat_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000042, 'Secom', 'ind_dial', 'S', 'trt_header_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置ヘッダー', '1', '<root name="処置ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="依頼発生日" value="$BLANK"/>
  <item name="依頼SEQ番号" value="$BLANK"/>
  <item name="依頼ユーザID" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, current_timestamp, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000043, 'Secom', 'ind_dial', 'S', 'trt_unit_top_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
  <record detail="trt_unit_del" sqlCode="-1102015"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102015, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000044, 'Secom', 'ind_dial', 'S', 'trt_unit_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置タイミング" value="const:0"/>
  <item name="処置開始日" value="dataset:-1102000.treat_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置終了日" value="dataset:-1102000.treat_date"/>
  <item name="フリーコメント1" value="$BLANK"/>
  <item name="フリーコメント2" value="$BLANK"/>
  <item name="フリーコメント3" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="診療区分コード" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102015.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000045, 'Secom', 'ind_dial', 'S', 'trt_item_top_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
  <record detail="trt_item_del" sqlCode="-1102002"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000046, 'Secom', 'ind_dial', 'S', 'trt_item_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置項目番号" value="dataset:-1100014.e02"/>
  <item name="処置項目コード" value="dataset:-1100014.e03"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置数量" value="dataset:-1100014.e04"/>
  <item name="単位コード" value="dataset:-1100014.e05"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102002.rp_no", "e02": "-1102002.item_no", "e03": "-1102002.medi_cd", "e04": "-1102002.medi_amount", "e05": "-1102002.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

-- カルテ記録
INSERT INTO mst_coop_layout_detail 
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000047, 'Secom', 'ind_dial', 'S', 'med_top_del', '02', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_カルテ記録_del', '1', '<root name="セコム連携_透析指示_カルテ" >
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:5"/>
  <item name="XX区分" value="dataset:-1100000.xx_type_code"/>
  <item name="タイトル" value="$BLANK"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd1"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="実施日" value="dataset:-1102000.treat_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="中止日" value="$BLANK"/>
  <item name="中止時刻" value="$BLANK"/>
  <item name="中止ユーザ" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="カルテ記録テキスト" value="dataset:-1102000.medical_record_text"/>
</root>
', '{"dataset": [{"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "-1100010.facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "-1100010.key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "-1100010.facility_cd"}, {"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "-1100010.ord_no", "patId": "-1100010.pat_id", "sqlCode": -1102000, "facilityCd": "-1100010.facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

