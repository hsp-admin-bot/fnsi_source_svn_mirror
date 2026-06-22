DELETE FROM ntss.mst_coop_layout WHERE ctl_no=-11070001;

INSERT INTO ntss.mst_coop_layout (ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-11070001, 'Secom', 'rst_dial', '', 'S', 'del', 'csv', 'セコム連携_透析実績連携', 'Secom', '透析実績連携（rootレイアウト）', '1', '<root name="透析実績電文" useSharedSysdate="true">
  <file name="処置実績" detail="trt_top_del" sqlCode="-1103017"/>
  <file name="注射実績" detail="inj_top_del" sqlCode="-1103018"/>
  <file name="カルテ記録" detail="med_top_del" sqlCode="-1100010"/>
  <file name="注射中止" detail="inj_cancel_top_del" sqlCode="-1103013"/>
</root>
', '{"dataset": [{"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103017, "facilityCd": "facility_cd", "fileSubKind": "trt_item"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103018, "facilityCd": "facility_cd", "fileSubKind": "inj_index"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "KARTE_FILE_STR", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100010, "fileKind": "medical", "facilityCd": "facilityCd", "file_extension": "txt"}, {"ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103013, "facilityCd": "facility_cd", "fileSubKind": "inj_index"}]}'::jsonb, '1', '0', 5843, '2025-07-16 14:08:48.502', CURRENT_TIMESTAMP, 'Secom');