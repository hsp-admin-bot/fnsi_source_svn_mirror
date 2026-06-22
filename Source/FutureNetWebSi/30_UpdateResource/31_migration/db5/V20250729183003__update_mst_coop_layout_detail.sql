-- 予約受付
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000001;
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000001, 'Secom', 'ind_dial', 'S', 'res_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_予約受付_del', '1', '<root name="セコム連携_透析指示_予約受付">
  <item name="更新モード" value="const:1"/>
  <item name="予約担当者ユーザID" value="dataset:-1102031.col2"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="受付・予約タイプ" value="const:1"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104000.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "res"}]}'::jsonb, '1', '0', 5843, '2025-07-02 17:37:53.252', current_timestamp, 'Secom');

-- 処置依頼
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1104000030, -1104000031, -1104000032, -1104000033);


INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000032, 'Secom', 'ind_dial', 'S', 'trt_unit_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位', '1', '<root name="処置単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100014.e01"/>
  <item name="SEQ番号" value="dataset:-1100014.e02"/>
  <item name="ユーザID" value="dataset:-1100014.e03"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
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
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col8", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', 5843, '2025-07-24 22:27:41.256', current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000033, 'Secom', 'ind_dial', 'S', 'trt_item_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目', '1', '<root name="処置項目">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100014.e01"/>
  <item name="SEQ番号" value="dataset:-1100014.e02"/>
  <item name="ユーザID" value="dataset:-1100014.e03"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP番号(処置番号)" value="dataset:-1100014.e04"/>
  <item name="処置項目番号" value="dataset:-1100014.e05"/>
  <item name="処置項目コード" value="dataset:-1100014.e06"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処置数量" value="dataset:-1100014.e07"/>
  <item name="単位コード" value="dataset:-1100014.e08"/>
  <item name="未使用" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col8", "e05": "-1102030.col9", "e06": "-1102030.col10", "e07": "-1102030.col12", "e08": "-1102030.col13", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', 5843, '2025-07-24 22:27:41.256', current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000030, 'Secom', 'ind_dial', 'S', 'trt_index_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_オーダーインデックス', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102031.col3"/>
  <item name="SEQ番号" value="dataset:-1102031.col4"/>
  <item name="ユーザID" value="dataset:-1102031.col5"/>
  <item name="INDEX区分" value="const:2"/>
  <item name="XX区分" value="const:61"/>
  <item name="タイトル" value="dataset:-1102000.treat_title"/>
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
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "trt_index"}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000031, 'Secom', 'ind_dial', 'S', 'trt_header_del', '01', 'セコム連携_透析指示連携', '処置依頼ファイル_処置ヘッダー', '1', '<root name="処置ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102031.col3"/>
  <item name="SEQ番号" value="dataset:-1102031.col4"/>
  <item name="ユーザID" value="dataset:-1102031.col5"/>
  <item name="指示区分" value="const:0"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="依頼発生日" value="$BLANK"/>
  <item name="依頼SEQ番号" value="$BLANK"/>
  <item name="依頼ユーザID" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1102000, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "trt_header"}]}'::jsonb, '1', '0', -1, '2025-06-30 16:08:51.714', current_timestamp, 'Secom');

-- 注射依頼
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1104000016, -1104000023, -1104000025, -1104000027);

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000025, 'Secom', 'ind_dial', 'S', 'inj_unit_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位1行_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100014.e01"/>
  <item name="SEQ番号" value="dataset:-1100014.e02"/>
  <item name="ユーザID" value="dataset:-1100014.e03"/>
  <item name="RP番号" value="dataset:-1100014.e04"/>
  <item name="処方開始日" value="dataset:-1102000.treat_date"/>
  <item name="投与日数" value="const:1"/>
  <item name="隔日" value="const:0"/>
  <item name="処方終了日" value="dataset:-1102000.treat_date"/>
  <item name="薬品数" value="dataset:-1100014.e05"/>
  <item name="手技" value="dataset:-1100014.e06"/>
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
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col6", "e05": "-1102030.col11", "e06": "-1102030.col12", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', 5843, '2025-07-24 22:27:41.256', current_timestamp, 'Secom');
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
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"e01": "-1102030.col3", "e02": "-1102030.col4", "e03": "-1102030.col5", "e04": "-1102030.col6", "e05": "-1102030.col7", "e06": "-1102030.col8", "e07": "-1102030.col9", "e08": "-1102030.col11", "e09": "''''", "e10": "''''", "sqlCode": -1100014}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"patId": "-1102021.pat_id", "sqlCode": -1102028}]}'::jsonb, '1', '0', 5843, '2025-07-24 22:27:41.256', current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000016, 'Secom', 'ind_dial', 'S', 'inj_index_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102031.col3"/>
  <item name="SEQ番号" value="dataset:-1102031.col4"/>
  <item name="ユーザID" value="dataset:-1102031.col5"/>
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
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "inj_index"}]}'::jsonb, '1', '0', -1, '2025-06-30 17:17:47.452', current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000023, 'Secom', 'ind_dial', 'S', 'inj_header_del', '01', 'セコム連携_透析指示連携', '注射依頼ファイル_注射ヘッダー_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_注射ヘッダー">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102031.col3"/>
  <item name="SEQ番号" value="dataset:-1102031.col4"/>
  <item name="ユーザID" value="dataset:-1102031.col5"/>
  <item name="未使用" value="$BLANK"/>
  <item name="注射種別コード" value="dataset:-1102000.shot_type"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="RP数" value="dataset:-1102000.rp_num_sum"/>
  <item name="未使用" value="$BLANK"/>
  <item name="未使用" value="$BLANK"/>
  <item name="処方コメント" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "inj_header"}]}'::jsonb, '1', '0', -1, '2025-06-30 17:17:47.452', current_timestamp, 'Secom');

-- カルテ記録
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000019;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000019, 'Secom', 'ind_dial', 'S', 'med_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_カルテ記録_del', '1', '<root name="セコム連携_透析指示_カルテ">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1102031.col3"/>
  <item name="SEQ番号" value="dataset:-1102031.col4"/>
  <item name="ユーザID" value="dataset:-1102031.col5"/>
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
  <item name="カルテ記録テキスト" value="dataset:-1102031.col20"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd", "sharedSysdate": "$SHARED_SYSDATE:yyyyMMddHHmmss"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "med"}]}'::jsonb, '1', '0', -1, '2025-06-24 14:35:49.849', current_timestamp, 'Secom');