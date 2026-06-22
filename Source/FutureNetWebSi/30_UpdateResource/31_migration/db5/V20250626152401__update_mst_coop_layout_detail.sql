DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (
  -1104000011,
  -1104000012,
  -1104000013,
  -1104000014,
  -1104000015,
  -1104000016,
  -1104000017,
  -1104000020,
  -1104000021,
  -1104000022,
  -1104000023,
  -1104000024,
  -1104000025,
  -1104000026,
  -1104000027
  );


INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000011, 'Secom', 'ind_dial', 'S', 'inj_top_cre', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_注射依頼_cre', '1', '<root name="透析指示_注射依頼">
  <file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_cre" sqlCode="-1102021"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_cre" sqlCode="-1102022"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_cre" sqlCode="-1102023"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_cre" sqlCode="-1102024"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102021, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102022, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102023, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102024, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "facilityCd": "facilityCd", "file_extension": "txt"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000012, 'Secom', 'ind_dial', 'S', 'inj_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示_注射依頼_del', '1', '<root name="透析指示_注射依頼">
  <file name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス" detail="inj_index_del" sqlCode="-1102021"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー" detail="inj_header_del" sqlCode="-1102022"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_top_del" sqlCode="-1102023"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1102024"/>
  <file name="セコム連携_透析指示_注射依頼ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1102025"/>
</root>', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_IDX_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102021, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_HEAD_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102022, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_RP_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102023, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "INJECT_ITEM_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102024, "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSCHESEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102025, "facilityCd": "facilityCd", "file_extension": "txt"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000013, 'Secom', 'ind_dial', 'S', 'inj_unit_top_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_cre" sqlCode="-1102003" />
</root>', '{"dataset": [{"key0": "-1102023.key0", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000024, 'Secom', 'ind_dial', 'S', 'inj_unit_top_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_del" sqlCode="-1102003" />
</root>', '{"dataset": [{"key0": "-1102023.key0", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000014, 'Secom', 'ind_dial', 'S', 'inj_item_top_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_cre" sqlCode="-1102011" />
</root>', '{"dataset": [{"key0": "-1102024.key0", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000026, 'Secom', 'ind_dial', 'S', 'inj_item_top_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_del" sqlCode="-1102011" />
</root>', '{"dataset": [{"key0": "-1102024.key0", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
	
INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000015, 'Secom', 'ind_dial', 'S', 'inj_index_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
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
  <item name="中止フラグ" value="const:0"/>
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
</root>', '{"dataset": [{"key0": "-1102021.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1100000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102000, "facilityCd": "-1102025.facility_cd"}, {"patId": "-1102021.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000016, 'Secom', 'ind_dial', 'S', 'inj_index_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102026.occur_date"/>
  <item name="SEQ番号" value="dataset:-1102026.occur_time"/>
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
</root>', '{"dataset": [{"key0": "-1102021.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1100000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102000, "facilityCd": "-1102025.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102026, "facilityCd": "-1102021.facility_cd"}, {"patId": "-1102021.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000017, 'Secom', 'ind_dial', 'S', 'inj_header_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
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
</root>', '{"dataset": [{"key0": "-1102022.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1100000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102000, "facilityCd": "-1102022.facility_cd"}, {"patId": "-1102022.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000023, 'Secom', 'ind_dial', 'S', 'inj_header_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102026.occur_date"/>
  <item name="SEQ番号" value="dataset:-1102026.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="未使用" value="$BLANK"/>
  <item name="注射種別コード" value="dataset:-1102000.shot_type"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP数" value="dataset:-1102000.rp_num_sum"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処方コメント" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102022.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1100000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102026, "facilityCd": "-1102022.facility_cd"}, {"patId": "-1102022.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000020, 'Secom', 'ind_dial', 'S', 'inj_unit_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
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
  <item name="実施時刻コード1" value="$BLANK"/>
  <item name="実施時刻コード2" value="$BLANK"/>
  <item name="実施時刻コード3" value="$BLANK"/>
  <item name="実施時刻コード4" value="$BLANK"/>
  <item name="実施時刻コード5" value="$BLANK"/>
  <item name="実施時刻コード6" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102003.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "sortKey": "-1102003.sort_key", "sqlCode": -1102010, "facilityCd": "-1102003.facility_cd"}, {"patId": "-1102003.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000025, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102026.occur_date"/>
  <item name="SEQ番号" value="dataset:-1102026.occur_time"/>
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
  <item name="実施時刻コード1" value="$BLANK"/>
  <item name="実施時刻コード2" value="$BLANK"/>
  <item name="実施時刻コード3" value="$BLANK"/>
  <item name="実施時刻コード4" value="$BLANK"/>
  <item name="実施時刻コード5" value="$BLANK"/>
  <item name="実施時刻コード6" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "sortKey": "-1102003.sort_key", "sqlCode": -1102010, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102026, "facilityCd": "-1102003.facility_cd"}, {"patId": "-1102003.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000021, 'Secom', 'ind_dial', 'S', 'inj_item_cre', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_cre', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
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
</root>', '{"dataset": [{"key0": "-1102011.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1100000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "sortKey": "-1102011.sort_key", "sqlCode": -1102012, "facilityCd": "-1102011.facility_cd"}, {"patId": "-1102011.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000027, 'Secom', 'ind_dial', 'S', 'inj_item_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102026.occur_date"/>
  <item name="SEQ番号" value="dataset:-1102026.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号(処置番号)" value="dataset:-1102012.rp_num"/>
  <item name="薬品番号" value="dataset:-1102012.medi_num"/>
  <item name="薬品コード" value="dataset:-1102012.medi_cd"/>
  <item name="用量" value="dataset:-1102012.medi_amount"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1102012.unit_convert"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1100000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "sortKey": "-1102011.sort_key", "sqlCode": -1102012, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102026, "facilityCd": "-1102011.facility_cd"}, {"patId": "-1102011.pat_id", "sqlCode": -1100006}]}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000022, 'Secom', 'ind_dial', 'S', 'inj_finish', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_ファイル作成終了', '1', '<root name="ファイル作成終了">
</root>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
