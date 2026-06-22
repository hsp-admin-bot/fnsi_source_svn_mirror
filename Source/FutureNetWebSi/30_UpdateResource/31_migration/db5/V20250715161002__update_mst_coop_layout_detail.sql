DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000033;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000032;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000031;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000030;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000027;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000025;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000023;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000019;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000016;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000009;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000008;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000033, 'Secom', 'ind_dial', 'S', 'trt_item_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置項目番号" value="dataset:-1100014.e02"/>
  <item name="処置項目コード" value="dataset:-1100014.e03"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置数量" value="dataset:-1100014.e04"/>
  <item name="単位コード" value="dataset:-1100014.e05"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102002.rp_no", "e02": "-1102002.item_no", "e03": "-1102002.medi_cd", "e04": "-1102002.medi_amount", "e05": "-1102002.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', '2025-07-07 11:21:33.617', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000032, 'Secom', 'ind_dial', 'S', 'trt_unit_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置タイミング" value="const:0"/>
  <item name="処置開始日" value="dataset:-1102000.treat_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置終了日" value="dataset:-1102000.treat_date"/>
  <item name="フリーコメント1" value="$BLANK"/>
  <item name="フリーコメント2" value="$BLANK"/>
  <item name="フリーコメント3" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="診療区分コード" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102015.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', '2025-07-07 14:25:27.776', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000031, 'Secom', 'ind_dial', 'S', 'trt_header_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置ヘッダー', '1', '<root name="処置ヘッダー">
 <item name="病院ID" value="dataset:-1100000.hospital_id"/>
 <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
 <item name="発生日" value="dataset:-1100015.occur_date"/>
 <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
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
</root>', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', '2025-07-02 11:19:13.251', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000030, 'Secom', 'ind_dial', 'S', 'trt_index_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_オーダーインデックス', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:61"/>
  <item name="タイトル" value="dataset:-1102000.treat_title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
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
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "patId": "patId", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', '2025-07-08 13:51:41.312', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000027, 'Secom', 'ind_dial', 'S', 'inj_item_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号(処置番号)" value="dataset:-1102012.rp_num"/>
  <item name="薬品番号" value="dataset:-1102012.medi_num"/>
  <item name="薬品コード" value="dataset:-1102012.medi_cd"/>
  <item name="用量" value="dataset:-1102012.medi_amount"/>
  <item name="未使用" value="$BLANK"/>
  <item name="単位コード" value="dataset:-1102012.unit_convert"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102011.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1100000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "sqlCode": -1102000, "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "ctlNo": "-1102011.ctl_no", "ordNo": "-1102011.ord_no", "sortKey": "-1102011.sort_key", "sqlCode": -1102012, "facilityCd": "-1102011.facility_cd"}, {"ordNo": "-1102011.ord_no", "patId": "-1102011.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "-1102011.facility_cd"}, {"key0": "-1102011.key0", "patId": "-1102011.pat_id", "sqlCode": -1100006, "facilityCd": "-1102011.facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-30 17:17:47.452', '2025-06-30 17:17:47.452', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000025, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="RP番号" value="dataset:-1102010.rp_num"/>
  <item name="処方開始日" value="dataset:-1102000.treat_date"/>
  <item name="投与日数" value="const:1"/>
  <item name="隔日" value="const:0"/>
  <item name="処方終了日" value="dataset:-1102000.treat_date"/>
  <item name="薬品数" value="dataset:-1102010.medi_count"/>
  <item name="手技" value="dataset:-1102010.procedure_hosp_cd"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="一日回数" value="const:1"/>
  <item name="タイミング1" value="$BLANK"/>
  <item name="タイミング2" value="$BLANK"/>
  <item name="タイミング3" value="$BLANK"/>
  <item name="タイミング4" value="$BLANK"/>
  <item name="タイミング5" value="$BLANK"/>
  <item name="コメントコード" value="$BLANK"/>
  <item name="フリーコメント" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102003.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1100000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "sqlCode": -1102000, "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "ctlNo": "-1102003.ctl_no", "ordNo": "-1102003.ord_no", "sortKey": "-1102003.sort_key", "sqlCode": -1102010, "facilityCd": "-1102003.facility_cd"}, {"ordNo": "-1102003.ord_no", "patId": "-1102003.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "-1102003.facility_cd"}, {"key0": "-1102003.key0", "patId": "-1102003.pat_id", "sqlCode": -1100006, "facilityCd": "-1102003.facility_cd"}]}'::jsonb, '1', '0', -1, '2025-07-08 09:00:10.231', '2025-07-08 09:00:10.231', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000023, 'Secom', 'ind_dial', 'S', 'inj_header_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="未使用" value="$BLANK"/>
  <item name="注射種別コード" value="dataset:-1102000.shot_type"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP数" value="dataset:-1102000.rp_num_sum"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処方コメント" value="$BLANK"/>
</root>', '{"dataset": [{"key0": "-1102022.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1100000, "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "ctlNo": "-1102022.ctl_no", "ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "sqlCode": -1102000, "facilityCd": "-1102022.facility_cd"}, {"ordNo": "-1102022.ord_no", "patId": "-1102022.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "-1102022.facility_cd"}, {"key0": "-1102022.key0", "patId": "-1102022.pat_id", "sqlCode": -1100006, "facilityCd": "-1102022.facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-30 17:17:47.452', '2025-06-30 17:17:47.452', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000019, 'Secom', 'ind_dial', 'S', 'med_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_カルテ記録_del', '1', '<root name="セコム連携_透析指示_カルテ" multi="true:CRLF">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:5"/>
  <item name="XX区分" value="dataset:-1100000.xx_type_code"/>
  <item name="タイトル" value="$BLANK"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd1"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="実施日" value="dataset:-1102000.treat_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="中止日" value="$BLANK"/>
  <item name="中止時刻" value="$BLANK"/>
  <item name="中止ユーザ" value="$BLANK"/>
  <item name="事後入力フラグ" value="const:0"/>
  <item name="カルテ記録テキスト" value="dataset:-1102000.medical_record_text"/>
</root>
', '{"dataset": [{"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "-1100010.facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "-1100010.key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "-1100010.facility_cd"}, {"key0": "-1100010.key0", "ctlNo": "-1100010.ctl_no", "ordNo": "-1100010.ord_no", "patId": "-1100010.pat_id", "sqlCode": -1102000, "facilityCd": "-1100010.facility_cd"}, {"ordNo": "-1100010.ord_no", "patId": "-1100010.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "medical", "facilityCd": "-1100010.facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-24 14:35:49.849', '2025-06-30 17:17:47.452', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000016, 'Secom', 'ind_dial', 'S', 'inj_index_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:11"/>
  <item name="タイトル" value="dataset:-1102000.shot_title"/>
  <item name="診療科コード" value="dataset:-1100000.course_cd2"/>
  <item name="事業所コード" value="const:000"/>
  <item name="入外区分" value="dataset:-1100006.in_out_class"/>
  <item name="開始日" value="dataset:-1102000.treat_date"/>
  <item name="終了日" value="dataset:-1102000.treat_date"/>
  <item name="実施時刻" value="$BLANK"/>
  <item name="中止フラグ" value="const:1"/>
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
</root>', '{"dataset": [{"key0": "-1102021.key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1100000, "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "ctlNo": "-1102021.ctl_no", "ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "sqlCode": -1102000, "facilityCd": "-1102021.facility_cd"}, {"ordNo": "-1102021.ord_no", "patId": "-1102021.pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "-1102021.facility_cd"}, {"key0": "-1102021.key0", "patId": "-1102021.pat_id", "sqlCode": -1100006, "facilityCd": "-1102021.facility_cd"}]}'::jsonb, '1', '0', -1, '2025-06-30 17:17:47.452', '2025-06-30 17:17:47.452', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000009, 'Secom', 'ind_dial', 'S', 'trt_item_cre', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置項目番号" value="dataset:-1100014.e02"/>
  <item name="処置項目コード" value="dataset:-1100014.e03"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置数量" value="dataset:-1100014.e04"/>
  <item name="単位コード" value="dataset:-1100014.e05"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102002.rp_no", "e02": "-1102002.item_no", "e03": "-1102002.medi_cd", "e04": "-1102002.medi_amount", "e05": "-1102002.unit", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-06-27 14:08:24.400', '2025-07-07 11:21:33.617', 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000008, 'Secom', 'ind_dial', 'S', 'trt_unit_cre', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
  <item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
  <item name="ユーザID" value="dataset:-1102000.user_id"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e01"/>
  <item name="処置タイミング" value="const:0"/>
  <item name="処置開始日" value="dataset:-1102000.treat_date"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置終了日" value="dataset:-1102000.treat_date"/>
  <item name="フリーコメント1" value="$BLANK"/>
  <item name="フリーコメント2" value="$BLANK"/>
  <item name="フリーコメント3" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="診療区分コード" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1100015, "fileKind": "treatment", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102015.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, '2025-06-27 14:08:24.400', '2025-07-07 14:25:27.776', 'Secom');