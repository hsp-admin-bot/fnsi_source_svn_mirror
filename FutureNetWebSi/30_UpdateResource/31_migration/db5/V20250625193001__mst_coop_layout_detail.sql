DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-1104000019, -1104000018);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000019, 'Secom', 'ind_dial', 'S', 'med_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_カルテ記録_del', '1', '<root name="セコム連携_透析指示_カルテ" multi="true:CRLF">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
</root>', '{"dataset": [{"key0": "-1102009.key0", "ctlNo": "-1102009.ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "-1102009.facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "-1102009.key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "-1102009.facility_cd"}, {"sqlCode": -1102000}]}'::jsonb, '1', '0', -1, '2025-06-24 14:35:49.849', CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000018, 'Secom', 'ind_dial', 'S', 'med_top_cre', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_カルテ記録_cre', '1', '<root name="セコム連携_透析指示_カルテ" multi="true:CRLF">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <item name="中止フラグ" value="const:0"/>
  <item name="中止日" value="$BLANK"/>
  <item name="中止時刻" value="$BLANK"/>
  <item name="中止ユーザ" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="カルテ記録テキスト" value="dataset:-1102000.medical_record_text"/>
</root>', '{"dataset": [{"key0": "-1102009.key0", "ctlNo": "-1102009.ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "-1102009.facility_cd", "sharedSysdate":"$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "-1102009.key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "-1102009.facility_cd"}, {"sqlCode": -1102000}]}'::jsonb, '1', '0', -1, '2025-06-24 14:35:49.849', CURRENT_TIMESTAMP, 'Secom');
