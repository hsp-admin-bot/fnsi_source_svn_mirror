DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-417000002,-417000003,-417000004,-1210100003);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000002, 'P_hosp', 'karte_ord', 'S', 'medical_record', '01', '問診記録(透析経過データ連携)', '問診記録(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317127.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317127.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317127.staff_name</INPUTDATA>
</root>
', '{"dataset": [{"key0": "-317123.key0", "sqlCode": -317127, "facilityCd": "-317123.facility_cd", "pat_event_cd": "-317123.pat_event_cd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000003, 'P_hosp', 'karte_ord', 'S', 'nurse_memo', '01', '看護メモ(透析経過データ連携)', '看護メモ(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317126.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317126.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317126.staff_name</INPUTDATA>
</root>
', '{"dataset": [{"key0": "-317122.key0", "sqlCode": -317126, "facilityCd": "-317122.facility_cd", "pat_event_cd": "-317122.pat_event_cd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000004, 'P_hosp', 'karte_ord', 'S', 'soap', '01', 'SOAP繰り返し(透析経過データ連携)', 'SOAP繰り返し(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317125.s</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317125.o</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317125.a</INPUTDATA>
  <INPUTDATA SeqNo="4">dataset:-317125.p</INPUTDATA>
  <INPUTDATA SeqNo="5">dataset:-317125.staff_name</INPUTDATA>
  <INPUTDATA SeqNo="6">dataset:-317125.up_date</INPUTDATA>
</root>
', '{"dataset": [{"key0": "-317121.key0", "sqlCode": -317125, "facilityCd": "-317121.facility_cd", "pat_event_cd": "-317121.pat_event_cd"}]}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100003, 'F_SX', 'exam_ord', 'S', '検査項目', '検査項目', 'SX連携', '依頼送信((※電文フォーマットはMedicomと一致しています。直接にMedicomのフォーマットを使います。))', '1', '<root name="明細詳細(検査項目)">
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
