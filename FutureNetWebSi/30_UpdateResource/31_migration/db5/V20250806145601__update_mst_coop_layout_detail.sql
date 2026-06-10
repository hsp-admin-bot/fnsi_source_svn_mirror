DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (
-1107000023,-1107000024
  );

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000023, 'Secom', 'rst_dial', 'S', 'inj_item_cre', '01', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目1行_cre', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
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
  <item name="中止フラグ" value="const:0"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103002.rp_no", "e02": "-1103002.medi_no", "e03": "-1103002.medi_cd", "e04": "-1103002.amount", "e05": "-1103002.unit", "e06": "-1103002.stop_flg", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-07-30 17:12:03.624', CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000024, 'Secom', 'rst_dial', 'S', 'inj_item_del', '01', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100014.e01"/>
  <item name="SEQ番号" value="dataset:-1100014.e02"/>
  <item name="ユーザID" value="dataset:-1100014.e03"/>
  <item name="指示コード" value="const:211"/>
  <item name="指示サブコード1" value="const:0000000000"/>
  <item name="指示サブコード2" value="const:0000000000"/>
  <item name="RP番号" value="dataset:-1100014.e04"/>
  <item name="薬品番号" value="dataset:-1100014.e05"/>
  <item name="薬品コード" value="dataset:-1100014.e06"/>
  <item name="薬品容量" value="dataset:-1100014.e07"/>
  <item name="単位コード" value="dataset:-1100014.e08"/>
  <item name="中止フラグ" value="const:1"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103021.col3", "e02": "-1103021.col4", "e03": "-1103021.col5", "e04": "-1103021.col9", "e05": "-1103021.col10", "e06": "-1103021.col11", "e07": "-1103021.col12", "e08": "-1103021.col13", "e09": "-1103021.col14", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-07-30 14:47:47.273', CURRENT_TIMESTAMP, 'Secom');