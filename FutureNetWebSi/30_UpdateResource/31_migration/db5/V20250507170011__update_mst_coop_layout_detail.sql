DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-409000001, -410000001, -410000002, -410000003, -417000002, -417000003, -417000004);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-409000001, 'P_hosp', 'exam_rst', 'R', '検査結果', 'all', 'Medicom', '検査結果受信', '1', '<root name="検査結果項目">
    <item  name="項目コード" len="17" col="$journal.detail.pat_exam_main.exam_result_info.item_cd" type="string"/>
    <item  name="検査結果値" len="8" col="$journal.detail.pat_exam_main.exam_result_info.result" type="string"/>
    <item  name="検査値形態" len="1" col="$journal.detail.pat_exam_main.exam_result_info.hl" type="string"/>
    <item  name="結果コメント１" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd1" type="string"/>
    <item  name="結果コメント２" len="3" col="$journal.detail.pat_exam_main.exam_result_info.com_cd2" type="string"/>
</root>', '{}'::jsonb, '1', '0', -1, '2020-05-26 10:52:13.579', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000001, 'P_hosp', 'exam_ord', 'S', '検査項目', 'pre', 'Medicom', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(pre)">
    <item  name="レコード区分" len="2" key="分類属性" value="const:O2"/>
    <item  name="検査機関コード" len="6" value="const:0000000"/>
    <item  name="依頼者KEY（日付）" len="6" value="$SYSDATE"/>
    <item  name="依頼者KEY（受付番号）" len="4" value="$journal.accept_no"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam1"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分1" len="1" value="dataset:-29.exam1p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam2"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分2" len="1" value="dataset:-29.exam2p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam3"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分3" len="1" value="dataset:-29.exam3p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam4"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分4" len="1" value="dataset:-29.exam4p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam5"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分5" len="1" value="dataset:-29.exam5p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="改行" len="1" value="$CR"/>
</root>', '{"key": {"分類属性": {"O2": "all"}}}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000002, 'P_hosp', 'exam_ord', 'S', '検査項目', 'all', 'Medicom', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(pre)">
    <item  name="レコード区分" len="2" value="const:O2"/>
    <item  name="検査機関コード" len="6" value="const:0000000"/>
    <item  name="依頼者KEY（日付）" len="6" value="$SYSDATE"/>
    <item  name="依頼者KEY（受付番号）" len="4" value="$journal.accept_no"/>
    <item  name="RSV" len="10" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam1"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分1" len="1" value="dataset:-29.exam1p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam2"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分2" len="1" value="dataset:-29.exam2p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam3"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分3" len="1" value="dataset:-29.exam3p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam4"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分4" len="1" value="dataset:-29.exam4p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="項目コード" len="17" value="dataset:-29.exam5"/>
    <item  name="負荷時間" len="10" value="$BLANK"/>
    <item  name="項目区分5" len="1" value="dataset:-29.exam5p"/>
    <item  name="RSV" len="8" value="$BLANK"/>
    <item  name="改行" len="1" value="$CR"/>
</root>', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000003, 'P_hosp', 'exam_ord', 'S', '検査項目', '検査項目', 'Medicom検査オーダ', '検査オーダ', '1', '<root name="明細詳細(検査項目)">
  <item name="レコード区分" len="2" key="分類属性" value="const:O2"/>
  <item name="検査機関コード" len="6" value="dataset:-310010.exam_institution_cd"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE" subMode="R"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$JOURNAL.accept_no" padding_format="zero" padding_position="left"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="項目コード1" len="17" value="dataset:-310010.exam1"/>
  <item name="負荷時間1" len="10" value="$BLANK"/>
  <item name="項目区分1" len="1" value="dataset:-310010.exam1p"/>
  <item name="RSV1" len="8" value="$BLANK"/>
  <item name="項目コード2" len="17" value="dataset:-310010.exam2"/>
  <item name="負荷時間2" len="10" value="$BLANK"/>
  <item name="項目区分2" len="1" value="dataset:-310010.exam2p"/>
  <item name="RSV2" len="8" value="$BLANK"/>
  <item name="項目コード3" len="17" value="dataset:-310010.exam3"/>
  <item name="負荷時間3" len="10" value="$BLANK"/>
  <item name="項目区分3" len="1" value="dataset:-310010.exam3p"/>
  <item name="RSV3" len="8" value="$BLANK"/>
  <item name="項目コード4" len="17" value="dataset:-310010.exam4"/>
  <item name="負荷時間4" len="10" value="$BLANK"/>
  <item name="項目区分4" len="1" value="dataset:-310010.exam4p"/>
  <item name="RSV4" len="8" value="$BLANK"/>
  <item name="項目コード5" len="17" value="dataset:-310010.exam5"/>
  <item name="負荷時間5" len="10" value="$BLANK"/>
  <item name="項目区分5" len="1" value="dataset:-310010.exam5p"/>
  <item name="RSV5" len="8" value="$BLANK"/>
  <item name="RSV" len="48" value="$BLANK"/>
  <item name="改行" len="1" value="$CR"/>
</root>
', '{"key": {"分類属性": {"02": "all"}}}'::jsonb, '1', '0', 5843, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000002, 'P_hosp', 'karte_ord', 'S', 'medical_record', '01', '問診記録(透析経過データ連携)', '問診記録(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317127.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317127.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317127.staff_name</INPUTDATA>
</root>
', '{"dataset": [{"ordNo": "-317123.ordNo", "sqlCode": -317127, "facilityCd": "-317123.facilityCd", "pat_event_cd": "-317123.pat_event_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-417000003, 'P_hosp', 'karte_ord', 'S', 'nurse_memo', '01', '看護メモ(透析経過データ連携)', '看護メモ(透析経過データ連携)', '1', '<root>
  <INPUTDATA SeqNo="1">dataset:-317126.e01</INPUTDATA>
  <INPUTDATA SeqNo="2">dataset:-317126.up_date</INPUTDATA>
  <INPUTDATA SeqNo="3">dataset:-317126.staff_name</INPUTDATA>
</root>
', '{"dataset": [{"ordNo": "-317122.ordNo", "sqlCode": -317126, "facilityCd": "-317122.facilityCd", "pat_event_cd": "-317122.pat_event_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');
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
', '{"dataset": [{"ordNo": "-317121.ordNo", "sqlCode": -317125, "facilityCd": "-317121.facilityCd", "pat_event_cd": "-317121.pat_event_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-07 17:58:19.424', CURRENT_TIMESTAMP, 'MED');