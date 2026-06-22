DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000028;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000032;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000029;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000033;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000024;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000025;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000026;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000027;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000028, 'Secom', 'ind_dial', 'S', 'trt_unit_top_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
  <record detail="trt_unit_del" sqlCode="-1102030"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "trt_unit"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000032, 'Secom', 'ind_dial', 'S', 'trt_unit_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102028.treatment_send_day"/>
  <item name="SEQ番号" value="dataset:-1102028.treatment_seq_no"/>
  <item name="ユーザID" value="dataset:-1102028.treatment_user_id"/>
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
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col8", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"patId": "pat_id", "sqlCode": -1102028}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000029, 'Secom', 'ind_dial', 'S', 'trt_item_top_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
  <record detail="trt_item_del" sqlCode="-1102030"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "trt_item"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000033, 'Secom', 'ind_dial', 'S', 'trt_item_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102028.treatment_send_day"/>
  <item name="SEQ番号" value="dataset:-1102028.treatment_seq_no"/>
  <item name="ユーザID" value="dataset:-1102028.treatment_user_id"/>
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
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col8", "e02": "-1102030.col9", "e03": "-1102030.col10", "e04": "-1102030.col12", "e05": "-1102030.col13", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"patId": "pat_id", "sqlCode": -1102028}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000024, 'Secom', 'ind_dial', 'S', 'inj_unit_top_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_del" sqlCode="-1102030"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "inj_unit"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000025, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102028.injection_send_day"/>
  <item name="SEQ番号" value="dataset:-1102028.injection_seq_no"/>
  <item name="ユーザID" value="dataset:-1102028.injection_user_id"/>
  <item name="RP番号" value="dataset:-1100014.e01"/>
  <item name="処方開始日" value="dataset:-1102000.treat_date"/>
  <item name="投与日数" value="const:1"/>
  <item name="隔日" value="const:0"/>
  <item name="処方終了日" value="dataset:-1102000.treat_date"/>
  <item name="薬品数" value="dataset:-1100014.e02"/>
  <item name="手技" value="dataset:-1100014.e03"/>
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
</root>
', '{"dataset": [{"key0": "-1102003.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"e01": "-1102030.col6", "e02": "-1102030.col11", "e03": "-1102030.col12", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "patId": "-1102003.pat_id", "sqlCode": -1100006, "facilityCd": "-1102003.facility_cd"}, {"patId": "-1102003.pat_id", "sqlCode": -1102028}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000026, 'Secom', 'ind_dial', 'S', 'inj_item_top_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_del" sqlCode="-1102030"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102030, "facilityCd": "facility_cd", "fileSubKind": "inj_item"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000027, 'Secom', 'ind_dial', 'S', 'inj_item_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102028.injection_send_day"/>
  <item name="SEQ番号" value="dataset:-1102028.injection_seq_no"/>
  <item name="ユーザID" value="dataset:-1102028.injection_user_id"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="薬品番号" value="dataset:-1100014.e02"/>
  <item name="薬品コード" value="dataset:-1100014.e03"/>
  <item name="用量" value="dataset:-1100014.e04"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1100014.e05"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col6", "e02": "-1102030.col7", "e03": "-1102030.col8", "e04": "-1102030.col9", "e05": "-1102030.col11", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"patId": "-1102021.pat_id", "sqlCode": -1102028}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');