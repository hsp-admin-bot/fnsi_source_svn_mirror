DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1110200001,-1110200002);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1110200001, 'Secom', 'exam_ord', 'S', 'exam_item_del', '01', 'セコム連携_検体検査オーダ連携_検体検査_削除', 'セコム連携_検体検査オーダ連携_検体検査_削除', '1', '<root name="検体検査">
  <item name="病院ID" value="dataset:-1105005.hospital_id"/>
  <item name="患者ID" value="dataset:-1105005.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1105005.occur_date"/>
  <item name="SEQ番号" value="dataset:-1105005.occur_time"/>
  <item name="ユーザID" value="dataset:-1105005.user_id"/>
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
  <item name="項目数" value="dataset:-1105005.exam_set_cnt"/>
  <item name="検査項目" value="dataset:-1105005.item_in_hospital_cd"/>
  <item name="汎用フラグ1" value="dataset:-1105005.exam_timing_flag"/>
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
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105005, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1110200002, 'Secom', 'exam_ord', 'S', 'exam_idx_del', '01', 'セコム連携_検体検査オーダ連携_オーダーインデックス_削除', 'セコム連携_検体検査オーダ連携_オーダーインデックス_削除', '1', '<root name="オーダーインデックス">
  <item name="病院ID" value="dataset:-1105004.hospital_id"/>
  <item name="患者ID" value="dataset:-1105004.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1105004.occur_date"/>
  <item name="SEQ番号" value="dataset:-1105004.occur_time"/>
  <item name="ユーザID" value="dataset:-1105004.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:20"/>
  <item name="タイトル" value="dataset:-1105004.title"/>
  <item name="診療科コード" value="dataset:-1105004.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1105004.in_out_class"/>
  <item name="開始日" value="dataset:-1105004.reg_exam_date"/>
  <item name="終了日" value="dataset:-1105004.reg_exam_date"/>
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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105004, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');
