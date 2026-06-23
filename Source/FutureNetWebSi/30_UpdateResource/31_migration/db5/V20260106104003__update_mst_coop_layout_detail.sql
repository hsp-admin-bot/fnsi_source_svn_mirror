DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1210100004,-1210100005,-1210100006,-1210100007);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100004, 'F_SX', 'exam_ord', 'S', 'ヘッダ情報_削除', '01', 'SX連携', '依頼送信', '1', '<root name="検査依頼">
  <item name="レコード区分" len="258" value="dataset:-1202009.value"/>
  <occ name="明細.検査項目" len="0" detail="検査項目_削除" sqlCode="-1202010"/>
</root>
', '{"dataset": [{"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "patId": "-1202006.pat_id", "sqlCode": -1202009, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "patId": "-1202006.pat_id", "sqlCode": -1202010, "facilityCd": "-1202006.facility_cd"}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100005, 'F_SX', 'exam_ord', 'S', '検査項目_削除', '検査項目_削除', 'SX連携', '依頼送信', '1', '<root name="明細詳細(検査項目)">
  <item name="詳細項目" len="258" value="dataset:-1202010.data"/>
</root>
', '{}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100006, 'F_SX', 'exam_ord', 'S', 'ヘッダ情報_削除', '02', 'SX連携', '依頼送信（コンバート）', '1', '<root name="検査依頼">
  <item name="レコード区分" len="2" value="const:O1"/>
  <item name="センターコード" len="6" value="dataset:-1202000.code"/>
  <item name="検査予定日" len="8" value="dataset:-1202001.exam_date_yyyymmdd"/>
  <item name="検査予定時刻" len="4" value="dataset:-1202002.treat_time"/>
  <item name="透析前後" len="1" value="dataset:-1202001.dialysis_kbn"/>
  <item name="予備" len="7" value="$BLANK"/>
  <item name="科名" len="15" value="dataset:-1202003.course_name"/>
  <item name="病棟名" len="15" value="dataset:-1202003.ward_name"/>
  <item name="入院外来区分" len="1" value="dataset:-1202004.in_out_class"/>
  <item name="担当医" len="10" value="dataset:-1200000.disp_user_id"/>
  <item name="被験者ID" len="15" value="dataset:-1202004.hosp_pat_id"/>
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <item name="処理区分" len="1" value="const:3"/>
  <item name="予備" len="6" value="$BLANK"/>
  <item name="被験者名" len="20" value="dataset:-1202004.pat_name_kana"/>
  <item name="性別" len="1" value="dataset:-1202004.pat_sex"/>
  <item name="年齢区分" len="1" value="$BLANK"/>
  <item name="年齢" len="3" value="$BLANK"/>
  <item name="生年月日区分" len="1" value="$BLANK"/>
  <item name="生年月日" len="6" value="dataset:-1202004.pat_birthday"/>
  <item name="採取日" len="6" value="dataset:-1202001.exam_date_yymmdd"/>
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
  <occ name="明細.検査項目" len="0" detail="検査項目_削除" sqlCode="-1202008"/>
</root>', '{"dataset": [{"key0": "-1202006.key0", "patId": "-1202006.pat_id", "sqlCode": -1200000, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "sqlCode": -1202000, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "sqlCode": -1202001, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "sqlCode": -1202002, "facilityCd": "-1202006.facility_cd"}, {"patId": "-1202006.pat_id", "sqlCode": -1202003, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "patId": "-1202006.pat_id", "sqlCode": -1202004, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "sqlCode": -1202007, "facilityCd": "-1202006.facility_cd"}, {"key0": "-1202006.key0", "ordNo": "-1202006.ord_no", "sqlCode": -1202008, "facilityCd": "-1202006.facility_cd"}], "CoopIniConvUtil": {"-1202004.pat_sex": "CONV_SEX_TO_KARTE", "-1202004.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100007, 'F_SX', 'exam_ord', 'S', '検査項目_削除', '検査項目', 'SX連携', '依頼送信（コンバート）', '1', '<root name="明細詳細(検査項目)">
  <item name="レコード区分" len="2" value="const:O2"/>
  <item name="センターコード" len="6" value="dataset:-1202000.code"/>
  <item name="検査予定日" len="8" value="dataset:-1202001.exam_date_yyyymmdd"/>
  <item name="検査予定時刻" len="4" value="dataset:-1202002.treat_time"/>
  <item name="透析前後" len="1" value="dataset:-1202001.dialysis_kbn"/>
  <item name="予備" len="7" value="$BLANK"/>
  <item name="項目コード1" len="10" value="dataset:-1202008.exam1"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード2" len="10" value="dataset:-1202008.exam2"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード3" len="10" value="dataset:-1202008.exam3"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード4" len="10" value="dataset:-1202008.exam4"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード5" len="10" value="dataset:-1202008.exam5"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード6" len="10" value="dataset:-1202008.exam6"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード7" len="10" value="dataset:-1202008.exam7"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード8" len="10" value="dataset:-1202008.exam8"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目コード9" len="10" value="dataset:-1202008.exam9"/>
  <item name="予備" len="5" value="$BLANK"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="予備" len="3" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "-1202008.key0", "sqlCode": -1202000, "facilityCd": "-1202008.facility_cd"}, {"key0": "-1202008.key0", "ordNo": "-1202008.ord_no", "sqlCode": -1202001, "facilityCd": "-1202008.facility_cd"}, {"key0": "-1202008.key0", "ordNo": "-1202008.ord_no", "sqlCode": -1202002, "facilityCd": "-1202008.facility_cd"}]}'::jsonb, '1', '0', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
