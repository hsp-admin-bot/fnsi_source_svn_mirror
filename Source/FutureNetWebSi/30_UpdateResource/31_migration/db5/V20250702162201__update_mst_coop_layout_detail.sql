
-- 予約受付 cre
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000000;
-- 予約受付 del
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-1104000001;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000000, 'Secom', 'ind_dial', 'S', 'res_top_cre', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_予約受付_cre', '1', '<root name="セコム連携_透析指示_予約受付" multi="true:CRLF">
  <item name="更新モード" value="const:0"/>
  <item name="予約担当者ユーザID" value="dataset:-1102000.res_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="受付・予約タイプ" value="const:1"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104000.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>', '{"dataset": [{"key0": "-1102006.key0", "ctlNo": "-1102006.ctl_no", "ordNo": "-1102006.ord_no", "patId": "-1102006.pat_id", "sqlCode": -1102000, "facilityCd": "-1102006.facility_cd"}, {"key0": "-1102006.key0", "patId": "-1102006.pat_id", "sqlCode": -1100006, "facilityCd": "-1102006.facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "-1102006.facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1104000001, 'Secom', 'ind_dial', 'S', 'res_top_del', '01', 'セコム連携_透析指示連携', 'セコム連携_透析指示連携_予約受付_del', '1', '<root name="セコム連携_透析指示_予約受付" multi="true:CRLF">
  <item name="更新モード" value="const:1"/>
  <item name="予約担当者ユーザID" value="dataset:-1102000.res_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="受付・予約タイプ" value="const:1"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104000.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>', '{"dataset": [{"key0": "-1102006.key0", "ctlNo": "-1102006.ctl_no", "ordNo": "-1102006.ord_no", "patId": "-1102006.pat_id", "sqlCode": -1102000, "facilityCd": "-1102006.facility_cd"}, {"key0": "-1102006.key0", "patId": "-1102006.pat_id", "sqlCode": -1100006, "facilityCd": "-1102006.facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "-1102006.facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
