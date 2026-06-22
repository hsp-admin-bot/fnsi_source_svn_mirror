DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000027;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000027, 'Secom', 'ind_dial', 'S', 'inj_item_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100014.e01"/>
  <item name="SEQ番号" value="dataset:-1100014.e02"/>
  <item name="ユーザID" value="dataset:-1100014.e03"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
  <item name="薬品番号" value="dataset:-1100014.e05"/>
  <item name="薬品コード" value="dataset:-1100014.e06"/>
  <item name="用量" value="dataset:-1100014.e07"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1100014.e08"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col6", "e05": "-1102030.col7", "e06": "-1102030.col8", "e07": "-1102030.col9", "e08": "-1102030.col11", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', 5843, '2025-07-24 22:27:41.256', current_timestamp, 'Secom');