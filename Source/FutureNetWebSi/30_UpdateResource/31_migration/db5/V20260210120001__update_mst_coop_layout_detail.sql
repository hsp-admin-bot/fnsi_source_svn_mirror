DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000026;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000023;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000021;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000019;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000018;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000017;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000026, 'Secom', 'rst_dial', 'S', 'inj_cancel_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射中止_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true">
  <file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_cancel_index_del" sqlCode="-1103010"/>
  <file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
  <file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103013.rp_no", "sqlCode": -1103010, "fileKind": "injection", "isCancel": "true", "maxSuffix": "-1103013.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103013.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103013.rp_no", "sqlCode": -1103011, "fileKind": "injection", "isCancel": "true", "maxSuffix": "-1103013.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "suffix": "-1103013.rp_no", "sqlCode": -1103012, "fileKind": "injection", "isCancel": "true", "maxSuffix": "-1103013.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000023, 'Secom', 'rst_dial', 'S', 'inj_item_cre', '01', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目1行_cre', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
<item name="発生日" value="dataset:-1103025.occurrence_date"/>
<item name="SEQ番号" value="dataset:-1103025.seq_no"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="指示コード" value="const:211"/>
<item name="指示サブコード1" value="const:0000000000"/>
<item name="指示サブコード2" value="const:0000000000"/>
<item name="RP番号" value="dataset:-1100014.e01"/>
<item name="薬品番号" value="dataset:-1100014.e02"/>
<item name="薬品コード" value="dataset:-1100014.e03"/>
<item name="薬品容量" value="dataset:-1100014.e04"/>
<item name="単位コード" value="dataset:-1100014.e05"/>
<item name="中止フラグ" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103002.rp_no", "e02": "-1103002.medi_no", "e03": "-1103002.medi_cd", "e04": "-1103002.amount", "e05": "-1103002.unit", "e06": "-1103002.stop_flg", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"rpNo": "-1103002.rp_no", "time": "-1103002.time", "sqlCode": -1103025}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000021, 'Secom', 'rst_dial', 'S', 'inj_item_top_cre', '01', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目_cre', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_cre" sqlCode="-1103002"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "rpNo": "-1103011.rp_no", "time": "-1103011.time", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000019, 'Secom', 'rst_dial', 'S', 'inj_index_cre', '01', 'セコム連携_透析実績連携', '注射実績ファイル_オーダーインデックス_cre', '1', '<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1103025.occurrence_date"/>
  <item name="SEQ番号" value="dataset:-1103025.seq_no"/>
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
  <item name="取消フラグ" value="$BLANK"/>
  <item name="背景色" value="$BLANK"/>
  <item name="実施予定日" value="dataset:-1103000.treat_date"/>
  <item name="実施予定時刻" value="dataset:-1103000.kur_standard_start_time"/>
  <item name="実施フラグ" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103010.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"rpNo": "-1103010.rp_no", "time": "-1103010.time", "sqlCode": -1103025}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000018, 'Secom', 'rst_dial', 'S', 'inj_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射実績_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true">
  <file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1103010"/>
  <file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
  <file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103018.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103018.rp_no", "sqlCode": -1103010, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103018.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "del", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103018.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103018.rp_no", "sqlCode": -1103011, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103018.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "suffix": "-1103018.rp_no", "sqlCode": -1103012, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103018.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000017, 'Secom', 'rst_dial', 'S', 'inj_top_cre', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射実績_cre', '1', '<root name="透析実績_注射実績" useSharedSysdate="true">
  <file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1103010"/>
  <file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1103011"/>
  <file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103004.rp_no", "sqlCode": -1103010, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103004.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"crud": "cre", "key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "rst_dial", "suffix": "-1103004.rp_no", "sqlCode": -1103011, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103004.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "suffix": "-1103004.rp_no", "sqlCode": -1103012, "fileKind": "injection", "isCancel": "false", "maxSuffix": "-1103004.max_rp_no", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');