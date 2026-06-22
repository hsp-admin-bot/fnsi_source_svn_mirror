DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1110100001;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1110100001, 'Secom', 'exam_ord', 'S', 'exam_item_cre', '01', 'セコム連携_検体検査オーダ連携_検体検査', 'セコム連携_検体検査オーダ連携_検体検査', '1', '<root name="検体検査">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1105000.user_id"/>
  <item name="緊急区分" value="const:0"/>
  <item name="感染症コード1" value="$BLANK"/>
  <item name="感染症コード2" value="$BLANK"/>
  <item name="感染症コード3" value="$BLANK"/>
  <item name="感染症コード4" value="$BLANK"/>
  <item name="感染症コード5" value="$BLANK"/>
  <item name="コメントコード1" value="$BLANK"/>
  <item name="コメントコード2" value="$BLANK"/>
  <item name="コメントコード3" value="$BLANK"/>
  <item name="フリーコメント1" value="$BLANK"/>
  <item name="フリーコメント2" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="項目数" value="dataset:-1105000.exam_set_cnt"/>
  <item name="検体項目" value="dataset:-1105001.item_in_hospital_cd"/>
  <item name="汎用フラグ1" value="dataset:-1105000.exam_timing_flag"/>
  <item name="汎用フラグ2" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="汎用データ1" value="$BLANK"/>
  <item name="汎用データ2" value="$BLANK"/>
  <item name="汎用データ3" value="$BLANK"/>
  <item name="汎用データ4" value="$BLANK"/>
  <item name="汎用データ5" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105001, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
