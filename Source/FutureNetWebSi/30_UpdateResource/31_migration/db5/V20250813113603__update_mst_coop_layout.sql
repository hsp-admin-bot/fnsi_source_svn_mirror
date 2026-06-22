DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -11060100,
-11060101,
-11060102
  );
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11060100, 'Secom', 'accept', '', 'S', 'cre', 'csv', 'セコム連携_再来受付連携', 'Secom', '(仮)再来受付連携', '1', '<root name="再来受付">
  <item name="更新モード" value="const:0"/>
  <item name="予約担当者ユーザID" value="dataset:-1104004.disp_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="予約受付タイプ" value="const:0"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104001.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1104001.sequence_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1104001.reservation_code_comment"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -1104002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100003, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1104001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1104004, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -1104003, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-05-20 10:20:41.464', CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11060101, 'Secom', 'accept', '', 'S', 'upd', 'csv', 'セコム連携_再来受付連携', 'Secom', '(仮)再来受付連携', '1', '<root name="再来受付">
  <item name="更新モード" value="const:0"/>
  <item name="予約担当者ユーザID" value="dataset:-1104004.disp_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="予約受付タイプ" value="const:0"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104001.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1104001.sequence_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1104001.reservation_code_comment"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -1104002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100003, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1104001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1104004, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -1104003, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-05-20 10:20:41.464', CURRENT_TIMESTAMP, 'Secom');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-11060102, 'Secom', 'accept', '', 'S', 'del', 'csv', 'セコム連携_再来受付連携', 'Secom', '(仮)再来受付連携', '1', '<root name="再来受付">
  <item name="更新モード" value="const:1"/>
  <item name="予約担当者ユーザID" value="dataset:-1104004.disp_user_id"/>
  <item name="予約番号" value="$BLANK"/>
  <item name="診察券番号・患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="患者氏名(漢字)" value="$BLANK"/>
  <item name="患者氏名(ふりがな)" value="$BLANK"/>
  <item name="予約受付タイプ" value="const:0"/>
  <item name="登録日時" value="$BLANK"/>
  <item name="予約予定日時" value="dataset:-1104001.appointment_date"/>
  <item name="シーケンス番号" value="dataset:-1104001.sequence_no"/>
  <item name="予約枠コード+コメント" value="dataset:-1104001.reservation_code_comment"/>
</root>
', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -1104002, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100003, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1104001, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -1104004, "facilityCd": "facilityCd"}], "dumpFileName": {"ordNo": "ordNo", "sqlCode": -1104003, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, '2025-05-27 13:22:20.911', CURRENT_TIMESTAMP, 'Secom');