DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-12103001;

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12103001, 'F_SX', 'exam_ord', '', 'S', 'del', 'text', 'SX連携_血液検査', 'F_SX', '血液検査', '1', '<root name="検査依頼">
  <item name="レコード区分" len="258" value="dataset:-1202009.value"/>
  <occ name="明細.検査項目" len="0" detail="検査項目_削除" sqlCode="-1202010"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1202009, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1202010, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1202020, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
