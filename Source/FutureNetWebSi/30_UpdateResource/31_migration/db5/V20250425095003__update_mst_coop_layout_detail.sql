DELETE FROM mst_coop_layout_detail
WHERE ctl_no IN (-417000002, -417000003, -417000004);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000002, 'P_hosp', 'karte_ord', 'S', 'medical_record', '01', '問診記録(透析経過データ連携)', '問診記録(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317127.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317127.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317127.staff_name</INPUTDATA>
</root>
', '{
  "dataset": [
    {
      "key0": "-317123.key0",
      "sqlCode": -317127,
      "facilityCd": "-317123.facilityCd",
      "pat_event_cd": "-317123.pat_event_cd"
    }
  ]
}'::jsonb, '1', '0', -1, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000003, 'P_hosp', 'karte_ord', 'S', 'nurse_memo', '01', '看護メモ(透析経過データ連携)', '看護メモ(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317126.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317126.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317126.staff_name</INPUTDATA>
</root>
', '{
  "dataset": [
    {
      "key0": "-317122.key0",
      "sqlCode": -317126,
      "facilityCd": "-317122.facilityCd",
      "pat_event_cd": "-317122.pat_event_cd"
    }
  ]
}'::jsonb, '1', '0', -1, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000004, 'P_hosp', 'karte_ord', 'S', 'soap', '01', 'SOAP繰り返し(透析経過データ連携)', 'SOAP繰り返し(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317125.s</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317125.o</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317125.a</INPUTDATA>
  <INPUTDATA SeqNo="4">dataset:-317125.p</INPUTDATA>
  <INPUTDATA SeqNo="5">dataset:-317125.staff_name</INPUTDATA>
  <INPUTDATA SeqNo="6">dataset:-317125.up_date</INPUTDATA>
</root>
', '{
  "dataset": [
    {
      "key0": "-317121.key0",
      "sqlCode": -317125,
      "facilityCd": "-317121.facilityCd",
      "pat_event_cd": "-317121.pat_event_cd"
    }
  ]
}'::jsonb, '1', '0', -1, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');