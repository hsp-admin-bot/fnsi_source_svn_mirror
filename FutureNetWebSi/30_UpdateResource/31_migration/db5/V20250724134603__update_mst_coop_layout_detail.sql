DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1111000008;
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000008, 'Secom', 'karte_ord', 'S', 'karte_ord_all', '01', 'セコム連携_指示変更履歴', 'セコム連携_指示変更履歴', '1', '<root name="指示変更履歴_カルテ記録ファイル" useSharedSysdate="true">
  <item name="病院ID" len="6" value="dataset:-1107000.hospital_id"/>
  <item name="患者ID" value="dataset:-1107000.patient_id"/>
  <item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
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
', '{"dataset": [{"ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107055, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107000, "treatDate": "treatDate", "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "content": "nullValue", "sqlCode": -1107004, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1107007, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-07-14 01:50:08.124', '2025-07-15 15:40:40.745', 'Secom');