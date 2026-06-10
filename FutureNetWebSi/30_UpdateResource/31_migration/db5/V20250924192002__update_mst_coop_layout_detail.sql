DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1110200003, -1111000009);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1110200003, 'Secom', 'exam_ord', 'S', 'exam_idx_del', '02', 'セコム連携_検体検査オーダ連携_オーダーインデックス_削除', 'セコム連携_検体検査オーダ連携_オーダーインデックス_削除(コンバート)', '1', '<root name="オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1105000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:20"/>
  <item name="タイトル" value="dataset:-1105000.title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1105000.reg_exam_date"/>
  <item name="終了日" value="dataset:-1105000.reg_exam_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="中止ユーザID" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1111000009, 'Secom', 'rad_ord', 'S', 'idx_top_del', '02', 'セコム連携_放射線オーダ', 'セコム連携_放射線オーダ_オーダーインデックス_del（コンバート）', '1', '<root name="放射線オーダ_オーダーインデックス">
  <item name="病院ID" len="6" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" len="12" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" len="10" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" len="8" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" len="6" value="dataset:-1106000.user_id"/>
  <item name="INDEX区分" len="1" value="const:2"/>
  <item name="XX区分" len="2" value="const:30"/>
  <item name="タイトル" len="60" value="dataset:-1106000.title"/>
  <item name="診療科コード" len="3" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" len="3" value="const:000"/>
  <item name="入外区分" len="1" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" len="10" value="dataset:-1106000.reg_rad_date"/>
  <item name="終了日" len="10" value="dataset:-1106000.reg_rad_date"/>
  <item name="実施時刻" len="8" value="$BLANK"/>
  <item name="中止フラグ" len="1" value="const:1"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="中止ユーザID" len="6" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="事後入力フラグ" len="1" value="const:0"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
  <item name="未使用" len="0" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1106000, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');