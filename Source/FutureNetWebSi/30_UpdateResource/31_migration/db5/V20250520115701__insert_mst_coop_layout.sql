DELETE FROM mst_coop_layout WHERE ctl_no IN (
 -11100000,
 -11100001,
 -11100002,
 -11100003,
 -11100004,
 -11100005
  );

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100000, 'Secom', 'exam_ord', '', 'S', 'cre', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_オーダーインデックス）', '1', '
<root name="オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <item name="中止フラグ" value="const:0"/>
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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100001, 'Secom', 'exam_ord', '', 'S', 'upd', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_オーダーインデックス）', '1', '
<root name="オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <item name="中止フラグ" value="const:0"/>
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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100002, 'Secom', 'exam_ord', '', 'S', 'del', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_オーダーインデックス）', '1', '
<root name="オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100003, 'Secom', 'exam_ord', '', 'S', 'cre', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_検体検査）', '1', '
<root name="検体検査">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <occ name="明細.検査項目" detail="検査項目" sqlCode="-1105001"/>
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
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -1105001, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100004, 'Secom', 'exam_ord', '', 'S', 'upd', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_検体検査）', '1', '
<root name="検体検査">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <occ name="明細.検査項目" detail="検査項目" sqlCode="-1105001"/>
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
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -1105001, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11100005, 'Secom', 'exam_ord', '', 'S', 'del', 'csv', 'セコム連携_検体検査オーダ連携', 'Secom', '検体検査オーダ連携（検体検査オーダファイル_検体検査）', '1', '
<root name="検体検査">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
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
  <occ name="明細.検査項目" detail="検査項目" sqlCode="-1105001"/>
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
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1105000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -1105001, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "patId": "patId", "sqlCode": -99997}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'Secom');