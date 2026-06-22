DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no in (-1111000010);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000010, 'Secom', 'rad_ord', 'S', 'head_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_処方ヘッダー_del（コンバート）', '1', '<root name="放射線オーダ_処方ヘッダー">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="検査指示数" len="1" value="const:1"/>
  <item name="コメントコード3" len="0" value="$BLANK"/>
  <item name="フリーコメント" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="指示フラグ20" len="8" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="緊急区分" len="1" value="const:0"/>
  <item name="その他" len="0" value="$BLANK"/>
  <item name="移動方法" len="0" value="$BLANK"/>
  <item name="妊娠情報" len="0" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
