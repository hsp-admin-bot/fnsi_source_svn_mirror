DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-1107000026, -1107000027);

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000026, 'Secom', 'rst_dial', 'S', 'inj_cancel_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績_注射中止_del', '1', '<root name="透析実績_注射実績" useSharedSysdate="true" updateSharedSysdate="true">
  <file name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス" detail="inj_cancel_index_del" sqlCode="-1103010"/>
  <file name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_top_del" sqlCode="-1103011"/>
  <file name="セコム連携_透析実績_注射実績ファイル_ファイル作成終了" detail="inj_finish" sqlCode="-1103012"/>
</root>
', '{"dataset": [{"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_IDX_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103010, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "INJECT_ITEM_FILE_STR", "rpNo": "-1103004.rp_no", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103011, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}, {"key0": "key0", "key1": "SCM_DIALYSISSEND", "key2": "NULL", "time": "$SHARED_SYSDATE:yyyy/MM/dd HH:mm:ss", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1103012, "fileKind": "injection", "facilityCd": "facilityCd", "file_extension": "txt"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000027, 'Secom', 'rst_dial', 'S', 'inj_cancel_index_del', '01', 'セコム連携_透析実績連携', '注射中止ファイル_オーダーインデックス_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_オーダーインデックス">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
  <item name="患者ID" value="dataset:-1100006.hosp_pat_id"/>
  <item name="発生日" value="dataset:-1100015.occur_date"/>
  <item name="SEQ番号" value="dataset:-1100015.occur_time"/>
  <item name="ユーザID" value="dataset:-1103000.user_id"/>
  <item name="指示コード" value="const:211"/>
  <item name="指示サブコード1" value="const:0000000000"/>
  <item name="指示サブコード2" value="const:0000000000"/>
  <item name="RP番号" value="dataset:-1100014.e01"/>
  <item name="実施日付" value="dataset:-1103000.rst_start_date"/>
  <item name="実施時刻" value="dataset:-1103000.rst_start_time"/>
  <item name="実施終了日" value="$BLANK"/>
  <item name="実施終了時刻" value="$BLANK"/>
  <item name="実施内容" value="$BLANK"/>
  <item name="実施値１" value="$BLANK"/>
  <item name="実施値１" value="$BLANK"/>
  <item name="IN TAKE" value="$BLANK"/>
  <item name="OUTPUT" value="$BLANK"/>
  <item name="依頼発生日" value="dataset:-1103000.injection_req_date"/>
  <item name="依頼SEQ番号" value="dataset:-1103000.injection_req_seq_no"/>
  <item name="依頼ユーザID" value="dataset:-1103000.injection_req_user_id"/>
  <item name="中止フラグ" value="const:1"/>
  <item name="取消フラグ" value="$BLANK"/>
  <item name="背景色" value="$BLANK"/>
  <item name="実施予定日" value="dataset:-1103000.treat_data"/>
  <item name="実施予定時刻" value="dataset:-1103000.kur_standard_start_time"/>
  <item name="実施フラグ" value="$BLANK"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1100015, "fileKind": "injection", "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "pat_id", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"e01": "-1103010.rp_no", "e02": "''''", "e03": "''''", "e04": "''''", "e05": "''''", "e06": "''''", "e07": "''''", "e08": "''''", "e09": "''''", "e10": "''''", "sqlCode": -1100014}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');