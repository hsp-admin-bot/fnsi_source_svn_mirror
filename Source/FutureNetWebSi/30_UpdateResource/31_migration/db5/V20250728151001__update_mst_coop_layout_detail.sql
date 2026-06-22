DELETE FROM mst_coop_layout_detail
WHERE ctl_no IN (-410000001, -410000002, -410000003);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000001, 'P_hosp', 'exam_ord', 'S', '検査項目', 'pre', 'Medicom', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(pre)">
  <item name="レコード区分" len="2" key="分類属性" value="const:O2"/>
  <item name="検査機関コード" len="6" value="const:0000000"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$journal.accept_no"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam1"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分1" len="1" value="dataset:-29.exam1p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam2"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分2" len="1" value="dataset:-29.exam2p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam3"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分3" len="1" value="dataset:-29.exam3p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam4"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分4" len="1" value="dataset:-29.exam4p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam5"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分5" len="1" value="dataset:-29.exam5p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
</root>
', '{"key": {"分類属性": {"O2": "all"}}}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', '2025-05-27 13:22:19.534', 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-410000002, 'P_hosp', 'exam_ord', 'S', '検査項目', 'all', 'Medicom', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(pre)">
  <item name="レコード区分" len="2" value="const:O2"/>
  <item name="検査機関コード" len="6" value="const:0000000"/>
  <item name="依頼者KEY（日付）" len="6" value="$SYSDATE"/>
  <item name="依頼者KEY（受付番号）" len="4" value="$journal.accept_no"/>
  <item name="RSV" len="10" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam1"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分1" len="1" value="dataset:-29.exam1p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam2"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分2" len="1" value="dataset:-29.exam2p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam3"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分3" len="1" value="dataset:-29.exam3p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam4"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分4" len="1" value="dataset:-29.exam4p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="項目コード" len="17" value="dataset:-29.exam5"/>
  <item name="負荷時間" len="10" value="$BLANK"/>
  <item name="項目区分5" len="1" value="dataset:-29.exam5p"/>
  <item name="RSV" len="8" value="$BLANK"/>
  <item name="改行" len="1" value="$CRLF"/>
</root>
', '{}'::jsonb, '1', '0', 4, '2019-12-13 06:16:24.000', '2025-05-27 13:22:19.534', 'MED');
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
  <item name="改行" len="1" value="$CRLF"/>
</root>
', '{"key": {"分類属性": {"02": "all"}}}'::jsonb, '1', '0', 5843, '2019-12-13 06:16:24.000', CURRENT_TIMESTAMP, 'MED');