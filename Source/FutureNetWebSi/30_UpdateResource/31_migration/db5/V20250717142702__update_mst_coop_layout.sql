DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-11170003);
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11170003, 'Secom', 'karte_ord', '', 'S', 'del', 'csv', 'セコム連携_指示変更履歴連携', 'Secom', '指示変更履歴連携', '1', '<root name="カルテ記録ファイル">
  <item name="病院ID" len="6" value="dataset:-1107000.hospital_id"/>
  <item name="患者ID" value="dataset:-1107000.patient_id"/>
  <item name="発生日" len="10" value="dataset:-1107000.occurrence_date"/>
  <item name="SEQ番号" len="8" value="dataset:-1107000.seq_number"/>
  <item name="ユーザID" len="6" value="dataset:-1107007.disp_user_id"/>
  <item name="INDEX区分" len="1" value="const:5"/>
  <item name="XX区分" len="2" value="dataset:-1107000.xx_class"/>
  <item name="タイトル" value="dataset:-1107000.title"/>
  <item name="診療科コード" len="2" value="dataset:-1107000.dept_code"/>
  <item name="事業所コード" len="3" value="const:000"/>
  <item name="入外区分" len="1" value="dataset:-1107000.in_out_class"/>
  <item name="実施日" len="10" value="dataset:-1107000.execution_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="中止フラグ" len="1" value="const:0"/>
  <item name="中止日" value="$BLANK"/>
  <item name="中止時刻" value="$BLANK"/>
  <item name="中止ユーザ" value="$BLANK"/>
  <item name="事後入力フラグ" len="1" value="const:0"/>
  <item name="カルテ記録テキスト" value="dataset:-1107004.karte_text"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "patId": "patId", "sqlCode": -1107056, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107000, "treatDate": "treatDate", "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107007, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107005, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-06-07 13:30:11.438', '2025-06-07 13:30:11.438', 'Secom');
