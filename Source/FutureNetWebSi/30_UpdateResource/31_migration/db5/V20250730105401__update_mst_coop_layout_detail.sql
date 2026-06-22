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
  <item name="予約予定日時" value="dataset:-1102031.col9"/>
  <item name="シーケンス番号" value="dataset:-1102000.coop_ord_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1102000.res_cd_comment"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1102000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"ordNo": "ordNo", "sqlCode": -1104000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102031, "facilityCd": "facility_cd", "fileSubKind": "res"}]}'::jsonb, '1', '0', 5843, '2025-07-02 17:37:53.252', current_timestamp, 'Secom');
