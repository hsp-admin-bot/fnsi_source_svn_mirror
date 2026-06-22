DELETE FROM ntss.mst_coop_layout
WHERE ctl_no=-12103001;

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12103001, 'F_SX', 'exam_ord', '', 'S', 'del', 'text', 'SX連携_血液検査', 'F_SX', '血液検査', '1', '<root name="検査依頼">
  <occ name="検査依頼" len="0" detail="ヘッダ情報_削除" sqlCode="-1202006"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "coopCd": "exam_ord", "sqlCode": -1202006, "facilityCd": "facilityCd"}], "dumpFileName": {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -1202020, "facilityCd": "facilityCd"}}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
