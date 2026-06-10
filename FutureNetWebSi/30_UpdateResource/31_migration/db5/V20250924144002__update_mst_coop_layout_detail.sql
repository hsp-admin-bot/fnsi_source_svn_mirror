DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no in (-1111000008);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000008, 'Secom', 'rad_ord', 'S', 'ipn_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_実施単位_del', '1', '<root name="放射線オーダ_実施単位">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="指示順" len="1" value="const:1"/>
  <item name="部位コード" len="4" value="dataset:-1106000.part_cd"/>
  <item name="修飾コード5" len="15" value="dataset:-1106000.mod_cd"/>
  <item name="方向コード5" len="15" value="dataset:-1106000.direction_cd"/>
  <item name="手技コード5" len="15" value="dataset:-1106000.procedure_cd"/>
  <item name="フリーコメント1" len="0" value="$BLANK"/>
  <item name="フリーコメント2" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
