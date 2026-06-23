DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-12101001,-12102001,-12103001);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12101001, 'F_SX', 'exam_ord', '', 'S', 'cre', 'text', 'SX連携_血液検査', 'F_SX', '血液検査', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <!--  <item name="センターコード" len="6" value="const:000000"/> -->
  <!--    <item name="検査予定日" len="8" value="$SYSDATE" subMode="R"/> -->
  <!--    <item name="検査予定時刻" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/> -->
  <!--    <item name="透析前後" len="1" value="???"/> -->
  <item name="予備" len="7" value="$BLANK"/>
  <item name="科名" len="15" value="dataset:-1202003.course_hosp_cd"/>
  <item name="病棟名" len="15" value="dataset:-1202003.ward_hosp_cd"/>
  <!--    <item name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/> -->
  <!--    <item name="担当医" len="10" value="dataset:-241.disp_user_id"/> -->
  <!--    <item name="被験者ID" len="15" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <!--    <item name="処理区分" len="1" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="予備" len="6" value="$BLANK"/>
  <!--    <item name="被験者名" len="20" value="dataset:-300001.pat_name"/> -->
  <!--    <item name="性別" len="1" value="dataset:-300001.pat_sex"/> -->
  <item name="年齢区分" len="1" value="$BLANK"/>
  <item name="年齢" len="3" value="$BLANK"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <!--    <item name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/> -->
  <!--    <item name="採取日" len="8" value="dataset:-23.exam_date"/> -->
  <item name="採取時間" len="4" value="$BLANK"/>
  <item name="項目数" len="3" value="dataset:-1202007.count"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="$BLANK"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント" len="20" value="$BLANK"/>
  <item name="予備" len="74" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-1202008"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -1202003, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202007, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202008, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1202020, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', 4, '2025-06-12 12:01:39.589', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12102001, 'F_SX', 'exam_ord', '', 'S', 'upd', 'text', 'SX連携_血液検査', 'F_SX', '血液検査', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <!--  <item name="センターコード" len="6" value="const:000000"/> -->
  <!--    <item name="検査予定日" len="8" value="$SYSDATE" subMode="R"/> -->
  <!--    <item name="検査予定時刻" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/> -->
  <!--    <item name="透析前後" len="1" value="???"/> -->
  <item name="予備" len="7" value="$BLANK"/>
  <item name="科名" len="15" value="dataset:-1202003.course_hosp_cd"/>
  <item name="病棟名" len="15" value="dataset:-1202003.ward_hosp_cd"/>
  <!--    <item name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/> -->
  <!--    <item name="担当医" len="10" value="dataset:-241.disp_user_id"/> -->
  <!--    <item name="被験者ID" len="15" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <!--    <item name="処理区分" len="1" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="予備" len="6" value="$BLANK"/>
  <!--    <item name="被験者名" len="20" value="dataset:-300001.pat_name"/> -->
  <!--    <item name="性別" len="1" value="dataset:-300001.pat_sex"/> -->
  <item name="年齢区分" len="1" value="$BLANK"/>
  <item name="年齢" len="3" value="$BLANK"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <!--    <item name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/> -->
  <!--    <item name="採取日" len="8" value="dataset:-23.exam_date"/> -->
  <item name="採取時間" len="4" value="$BLANK"/>
  <item name="項目数" len="3" value="dataset:-1202007.count"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="$BLANK"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント" len="20" value="$BLANK"/>
  <item name="予備" len="74" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-1202008"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -1202003, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202007, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202008, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1202020, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', 4, '2025-06-12 12:01:39.589', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12103001, 'F_SX', 'exam_ord', '', 'S', 'del', 'text', 'SX連携_血液検査', 'F_SX', '血液検査', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <!--  <item name="センターコード" len="6" value="const:000000"/> -->
  <!--    <item name="検査予定日" len="8" value="$SYSDATE" subMode="R"/> -->
  <!--    <item name="検査予定時刻" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/> -->
  <!--    <item name="透析前後" len="1" value="???"/> -->
  <item name="予備" len="7" value="$BLANK"/>
  <item name="科名" len="15" value="dataset:-1202003.course_hosp_cd"/>
  <item name="病棟名" len="15" value="dataset:-1202003.ward_hosp_cd"/>
  <!--    <item name="入院外来区分" len="1" value="dataset:-300001.in_out_class"/> -->
  <!--    <item name="担当医" len="10" value="dataset:-241.disp_user_id"/> -->
  <!--    <item name="被験者ID" len="15" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <!--    <item name="処理区分" len="1" value="dataset:-300001.hosp_pat_id"/> -->
  <item name="予備" len="6" value="$BLANK"/>
  <!--    <item name="被験者名" len="20" value="dataset:-300001.pat_name"/> -->
  <!--    <item name="性別" len="1" value="dataset:-300001.pat_sex"/> -->
  <item name="年齢区分" len="1" value="$BLANK"/>
  <item name="年齢" len="3" value="$BLANK"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <!--    <item name="生年月日" len="8" value="dataset:-300001.pat_birthday_yyyymmdd"/> -->
  <!--    <item name="採取日" len="8" value="dataset:-23.exam_date"/> -->
  <item name="採取時間" len="4" value="$BLANK"/>
  <item name="項目数" len="3" value="dataset:-1202007.count"/>
  <item name="身長" len="4" value="$BLANK"/>
  <item name="体重" len="4" value="$BLANK"/>
  <item name="尿量" len="4" value="$BLANK"/>
  <item name="尿量（単位）" len="2" value="$BLANK"/>
  <item name="妊娠週数" len="2" value="$BLANK"/>
  <item name="透析前後" len="1" value="$BLANK"/>
  <item name="至急報告" len="1" value="$BLANK"/>
  <item name="依頼コメント" len="20" value="$BLANK"/>
  <item name="予備" len="74" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
  <occ name="明細.検査項目" len="0" detail="検査項目" sqlCode="-1202008"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -1202003, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202007, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1202008, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1202020, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-06-12 12:01:39.589', CURRENT_TIMESTAMP, 'F_SX');
