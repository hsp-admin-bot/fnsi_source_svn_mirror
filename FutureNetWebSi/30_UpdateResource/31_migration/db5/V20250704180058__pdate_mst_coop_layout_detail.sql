DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1210100001,-1210100002,-1210100003);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100001, 'F_SX', 'exam_ord', 'S', '検査項目', 'pre', 'SX連携', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(検査項目)">
  <item name="レコード区分" len="2" value="const:O2"/>
  <item name="センターコード" len="6" value="const:CENTER"/>
  <item name="検査予定日" len="8" value="const:20010401"/>
  <item name="検査予定時刻" len="4" value="const:1000"/>
  <item name="透析前後" len="1" value="const:1"/>
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
</root>', '{"key": {"分類属性": {"O2": "all"}}}'::jsonb, '1', '1', 4, '2025-06-12 12:01:39.544', CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1210100002, 'F_SX', 'exam_ord', 'S', '検査項目', 'all', 'SX連携', '依頼送信 ※送信：preとallの設定無効', '1', '<root name="明細詳細(検査項目)">
  <item name="レコード区分" len="2" value="const:O2"/>
  <item name="センターコード" len="6" value="const:CENTER"/>
  <item name="検査予定日" len="8" value="const:20010401"/>
  <item name="検査予定時刻" len="4" value="const:1000"/>
  <item name="透析前後" len="1" value="const:1"/>
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
</root>', '{}'::jsonb, '1', '1', 4, '2025-06-12 12:01:39.544', CURRENT_TIMESTAMP, 'F_SX');
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
', '{"dataset": [{"key0": "-1202008.key0", "sqlCode": -1202000, "facilityCd": "-1202008.facilityCd"}, {"key0": "-1202008.key0", "ordNo": "-1202008.ordNo", "sqlCode": -1202001, "facilityCd": "-1202008.facilityCd"}, {"key0": "-1202008.key0", "ordNo": "-1202008.ordNo", "sqlCode": -1202002, "facilityCd": "-1202008.facilityCd"}]}'::jsonb, '1', '0', 4, '2025-06-12 12:01:39.544', CURRENT_TIMESTAMP, 'F_SX');
