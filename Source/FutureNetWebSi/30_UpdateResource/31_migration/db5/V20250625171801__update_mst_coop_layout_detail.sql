DELETE FROM mst_coop_layout_detail WHERE ctl_no IN (-1104000002, -1104000003, -1104000004, -1104000005, -1104000006, -1104000007, -1104000008, -1104000009, -1104000010);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000002, 'Secom', 'ind_dial', 'S', '処置依頼', '処置依頼_cre', 'セコム連携_透析指示連携', 'セコム連携_透析指示_処置依頼_cre', '1', '<root name="処置依頼">
  <file name="オーダーインデックス" detail="オーダーインデックス" sqlCode="-1102020"/>
  <file name="処置ヘッダー" detail="処置ヘッダー" sqlCode="-1102021"/>
  <file name="処置単位" detail="処置単位" sqlCode="-1102022"/>
  <file name="処置項目" detail="処置項目" sqlCode="-1102023"/>
  <file name="ファイル作成終了" detail="ファイル作成終了" sqlCode="-1102024"/>
</root>
', '{"dataset": [{"sqlCode": -1102020}, {"sqlCode": -1102021}, {"sqlCode": -1102022}, {"sqlCode": -1102023}, {"sqlCode": -1102024}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000003, 'Secom', 'ind_dial', 'S', '処置依頼', '処置依頼_del', 'セコム連携_透析指示連携', 'セコム連携_透析指示_処置依頼_del', '1', '<root name="処置依頼">
  <file name="オーダーインデックス" detail="オーダーインデックス" sqlCode="-1102020"/>
  <file name="処置ヘッダー" detail="処置ヘッダー" sqlCode="-1102021"/>
  <file name="処置単位" detail="処置単位" sqlCode="-1102022"/>
  <file name="処置項目" detail="処置項目" sqlCode="-1102023"/>
  <file name="ファイル作成終了" detail="ファイル作成終了" sqlCode="-1102024"/>
</root>
', '{"dataset": [{"sqlCode": -1102020}, {"sqlCode": -1102021}, {"sqlCode": -1102022}, {"sqlCode": -1102023}, {"sqlCode": -1102024}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000004, 'Secom', 'ind_dial', 'S', '処置単位', '処置依頼レコード_実施単位', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
  <record detail="処置単位" sqlCode="???"/>
</root>
', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000005, 'Secom', 'ind_dial', 'S', '処置項目', '処置依頼レコード_実施項目', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
  <record detail="処置項目" sqlCode="???"/>
</root>
', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000006, 'Secom', 'ind_dial', 'S', 'オーダーインデックス', 'オーダーインデックス', 'セコム連携_透析指示連携', '処置依頼ファイル_オーダーインデックス', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:5"/>
  <item name="XX区分" value="dataset:-1100000.xx_type_code"/>
  <item name="タイトル" value="$BLANK"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd1"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1102000.treat_date"/>
  <item name="終了日" value="dataset:-1102000.treat_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:0"/>
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
</root>', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1100006}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102000, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000007, 'Secom', 'ind_dial', 'S', '処置ヘッダー', '処置ヘッダー', 'セコム連携_透析指示連携', '処置依頼ファイル_処置ヘッダー', '1', '<root name="処置ヘッダー">
 <item name="病院ID" value="dataset:-1100000.hospital_id"/>
 <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
 <item name="発生日" value="dataset:-1100000.occur_date"/>
 <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
 <item name="ユーザID" value="dataset:-1102000.user_id"/>
 <item name="指示区分" value="const:0"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="依頼発生日" value="$BLANK"/>
 <item name="依頼SEQ番号" value="$BLANK"/>
 <item name="依頼ユーザID" value="$BLANK"/>
</root>', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1100006}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102000, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000008, 'Secom', 'ind_dial', 'S', '処置単位', '処置単位', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
 <item name="病院ID" value="dataset:-1100000.hospital_id"/>
 <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
 <item name="発生日" value="dataset:-1100000.occur_date"/>
 <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
 <item name="ユーザID" value="dataset:-1102000.user_id"/>
 <item name="指示区分" value="const:0"/>
 <item name="未使用" value="$BLANK"/>
 <item name="RP番号(処置番号)" value="dataset:-1102002.rp_no"/>
 <item name="処置タイミング" value="const:0"/>
 <item name="処置開始日" value="dataset:-1102000.rst_start_date"/>
 <item name="未使用" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="処置終了日" value="dataset:-1102000.rst_start_date"/>
 <item name="フリーコメント1" value="$BLANK"/>
 <item name="フリーコメント2" value="$BLANK"/>
 <item name="フリーコメント3" value="$BLANK"/>
 <item name="未使用" value="$BLANK"/>
 <item name="診療区分コード" value="$BLANK"/>
</root>', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1100006}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102002, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000009, 'Secom', 'ind_dial', 'S', '処置項目', '処置項目', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100000.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100000.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1102002.rp_no"/>
  <item name="処置項目番号" value="dataset:-1102002.medi_num"/>
  <item name="処置項目コード" value="dataset:-1102002.medi_cd"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置数量" value="dataset:-1102002.medi_amount"/>
  <item name="単位コード" value="dataset:-1102002.unit"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0,": "key0", "patId": "patId", "ctlNo,": "ctlNo", "ordNo,": "ordNo", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1100006}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"patId": "patId", "ordNo,": "ordNo", "sqlCode": -1102002, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000010, 'Secom', 'ind_dial', 'S', 'ファイル作成終了', '実施項目', 'セコム連携_透析指示連携', '処置依頼ファイル_ファイル作成終了', '1', '<root name="ファイル作成終了">
</root>', '{}'::jsonb, '1', '0', -1, '2025-06-24 10:35:38.507', '2025-06-24 10:35:38.507', 'Secom');