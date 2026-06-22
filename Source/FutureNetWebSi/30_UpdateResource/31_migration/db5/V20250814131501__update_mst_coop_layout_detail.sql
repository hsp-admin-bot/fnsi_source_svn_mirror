DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1107000010;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000010, 'Secom', 'rst_dial', 'S', 'trt_unit_cre', '01', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位', '1', '<root name="処置単位">
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
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103003.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-07-30 18:33:19.963', CURRENT_TIMESTAMP, 'Secom');
