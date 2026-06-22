DELETE FROM ntss.mst_coop_layout_detail 
WHERE ctl_no IN (
    -1107000002,
    -1107000003,
    -1107000017,
    -1107000008,
    -1107000012,
    -1107000021,
    -1107000026,
    -1107000028,
    -1107000029,
    -1107000030,
    -1107000031,
    -1107000032,
    -1107000033,
    -1107000034,
    -1107000035,
    -1107000036,
    -1107000037,
    -1107000038,
    -1107000039,
    -1107000040
);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000002, 'Secom', 'rst_dial', 'S', 'trt_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_処置実績', '1', '<root name="処置実績" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_del" sqlCode="-1103005"/>
<file name="処置ヘッダー" detail="trt_header_del" sqlCode="-1103006"/>
<file name="処置単位" detail="trt_unit_top_del" sqlCode="-1103007"/>
<file name="処置項目" detail="trt_item_top_del" sqlCode="-1103008"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1103009"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103005, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103006, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103007, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103008, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103009, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-07-17 12:22:00.639', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000003, 'Secom', 'rst_dial', 'S', 'trt_top_cre', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_処置実績', '1', '<root name="処置実績" useSharedSysdate="true">
<file name="オーダーインデックス" detail="trt_index_cre" sqlCode="-1103005"/>
<file name="処置ヘッダー" detail="trt_header_cre" sqlCode="-1103006"/>
<file name="処置単位" detail="trt_unit_top_cre" sqlCode="-1103007"/>
<file name="処置項目" detail="trt_item_top_cre" sqlCode="-1103008"/>
<file name="ファイル作成終了" detail="trt_finish" sqlCode="-1103009"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103005, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103006, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103007, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "TREAT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103008, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103009, "fileKind": "treatment", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000017, 'Secom', 'rst_dial', 'S', 'inj_top_cre', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射実績_cre', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-07-30 10:00:10.996', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000008, 'Secom', 'rst_dial', 'S', 'trt_unit_top_cre', '01', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位', '1', '<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_cre" sqlCode="-1103003"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103003, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, '2025-07-17 12:27:33.708', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000012, 'Secom', 'rst_dial', 'S', 'trt_item_top_cre', '01', 'セコム連携_透析実績連携', '処置実績ファイル_処置項目', '1', '<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_cre" sqlCode="-1103001"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103001, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, '2025-07-17 12:27:33.708', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000021, 'Secom', 'rst_dial', 'S', 'inj_item_top_cre', '01', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目_cre', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_cre" sqlCode="-1103002"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "rpNo": "-1103011.rp_no", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, '2025-07-30 10:00:10.996', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000026, 'Secom', 'rst_dial', 'S', 'inj_cancel_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射中止_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_cancel_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, '2025-08-01 15:43:21.079', current_timestamp, 'Secom');


--カルテ記録
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000028, 'Secom', 'rst_dial', 'S', 'med_top_del', '02', 'セコム連携_透析実績連携', 'セコム連携_透析実績連携_カルテ記録_del', '1', '<root name="セコム連携_透析実績_カルテ">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1103000.medical_record_text"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');


--処置実績
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000029, 'Secom', 'rst_dial', 'S', 'trt_index_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_オーダーインデックス', '1', '<root name="セコム連携_透析実績_処置実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:2"/>
<item name="XX区分" value="const:61"/>
<item name="タイトル" value="dataset:-1103000.treat_title"/>
<item name="診療科コード" value="dataset:-1100000.course_cd2"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="開始日" value="dataset:-1103000.treat_date"/>
<item name="終了日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止ユーザID" value="$BLANK"/>
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
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000030, 'Secom', 'rst_dial', 'S', 'trt_header_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置ヘッダー', '1', '<root name="処置ヘッダー">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103000.treatment_req_date"/>
<item name="依頼SEQ番号" value="dataset:-1103000.treatment_req_seq_no"/>
<item name="依頼ユーザID" value="dataset:-1103000.treatment_req_user_id"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000031, 'Secom', 'rst_dial', 'S', 'trt_unit_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位', '1', '<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_cre" sqlCode="-1103003"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103003, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000032, 'Secom', 'rst_dial', 'S', 'trt_unit_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位', '1', '<root name="処置単位">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置タイミング" value="const:0"/>
<item name="処置開始日" value="dataset:-1103000.rst_start_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="処置終了日" value="dataset:-1103000.rst_start_date"/>
<item name="フリーコメント1" value="$BLANK"/>
<item name="フリーコメント2" value="$BLANK"/>
<item name="フリーコメント3" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="診療区分コード" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103003.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000033, 'Secom', 'rst_dial', 'S', 'trt_item_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置項目', '1', '<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_cre" sqlCode="-1103001"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103001, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000034, 'Secom', 'rst_dial', 'S', 'trt_item_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置項目', '1', '<root name="処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示区分" value="const:1"/>
<item name="未使用" value="$BLANK"/>
<item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
<item name="処置項目番号" value="dataset:-1100014.e02"/>
<item name="処置項目コード" value="dataset:-1100014.e03"/>
<item name="未使用" value="$BLANK"/>
<item name="処置数量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103001.rp_no", "e02": "-1103001.item_no", "e03": "-1103001.hosp_cd", "e04": "-1103001.amount", "e05": "-1103001.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');


--注射実績
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000035, 'Secom', 'rst_dial', 'S', 'inj_top_del', '02', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射実績_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000036, 'Secom', 'rst_dial', 'S', 'inj_index_del', '02', 'セコム連携_透析実績連携', '注射実績ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e01"/>
<item name="実施日付" value="dataset:-1103000.rst_start_date"/>
<item name="実施時刻" value="dataset:-1103000.rst_start_time"/>
<item name="実施終了日" value="$BLANK"/>
<item name="実施終了時刻" value="$BLANK"/>
<item name="実施内容" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="IN TAKE" value="$BLANK"/>
<item name="OUTPUT" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103000.injection_req_date"/>
<item name="依頼SEQ番号" value="dataset:-1103000.injection_req_seq_no"/>
<item name="依頼ユーザID" value="dataset:-1103000.injection_req_user_id"/>
<item name="中止フラグ" value="const:0"/>
<item name="取消フラグ" value="const:1"/>
<item name="背景色" value="$BLANK"/>
<item name="実施予定日" value="dataset:-1103000.treat_date"/>
<item name="実施予定時刻" value="dataset:-1103000.kur_standard_start_time"/>
<item name="実施フラグ" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103010.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-07-30 17:12:03.624', current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000037, 'Secom', 'rst_dial', 'S', 'inj_item_top_del', '02', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_del" sqlCode="-1103002"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "rpNo": "-1103011.rp_no", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000038, 'Secom', 'rst_dial', 'S', 'inj_item_del', '02', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e01"/>
<item name="薬品番号" value="dataset:-1100014.e02"/>
<item name="薬品コード" value="dataset:-1100014.e03"/>
<item name="薬品容量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="中止フラグ" value="const:1"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103002.rp_no", "e02": "-1103002.medi_no", "e03": "-1103002.medi_cd", "e04": "-1103002.amount", "e05": "-1103002.unit", "e06": "-1103002.stop_flg", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');


INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000039, 'Secom', 'rst_dial', 'S', 'inj_cancel_top_del', '02', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射中止_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
<file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_cancel_index_del" sqlCode="-1103010"/>
<file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
<file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000040, 'Secom', 'rst_dial', 'S', 'inj_cancel_index_del', '02', 'セコム連携_透析実績連携', '注射中止ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103022.col3"/>
<item name="SEQ番号" value="dataset:-1103022.col4"/>
<item name="ユーザID" value="dataset:-1103022.col5"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1103022.col9"/>
<item name="実施日付" value="dataset:-1103022.col10"/>
<item name="実施時刻" value="dataset:-1103022.col11"/>
<item name="実施終了日" value="$BLANK"/>
<item name="実施終了時刻" value="$BLANK"/>
<item name="実施内容" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="実施値１" value="$BLANK"/>
<item name="IN TAKE" value="$BLANK"/>
<item name="OUTPUT" value="$BLANK"/>
<item name="依頼発生日" value="dataset:-1103022.col19"/>
<item name="依頼SEQ番号" value="dataset:-1103022.col20"/>
<item name="依頼ユーザID" value="dataset:-1103022.col21"/>
<item name="中止フラグ" value="const:1"/>
<item name="取消フラグ" value="$BLANK"/>
<item name="背景色" value="$BLANK"/>
<item name="実施予定日" value="dataset:-1103022.col25"/>
<item name="実施予定時刻" value="dataset:-1103022.col26"/>
<item name="実施フラグ" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103022, "facilityCd": "facility_cd", "fileSubKind": "inj_index", "conditionValue": "-1103010.rp_no", "conditionTargetColNo": 8}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');