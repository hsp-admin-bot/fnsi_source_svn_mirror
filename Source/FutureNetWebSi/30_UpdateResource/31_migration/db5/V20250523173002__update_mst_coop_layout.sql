DELETE FROM mst_coop_layout WHERE ctl_no IN (
  -12071001, -12072001,-12073001
  );

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12073001, 'F_SX', 'rst_dial', '', 'S', 'del', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <item name="処理区分" len="1" value="const:3"/>
  <!-- <item name="担当医" len="10" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="透析導入日" len="8" value="dataset:-1201000.dialysis_start"/>
  <item name="当院開始日" len="8" value="dataset:-1201000.hospital_start"/>
  <item name="実透析実施日" len="8" value="dataset:-506.start_date8"/>
  <item name="入外区分" len="1" value="dataset:-1201001.in_out"/>
  <item name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
  <item name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
  <item name="ベッド名称" len="10" value="dataset:-1201001.bed_name"/>
  <item name="治療法（装置モード）" len="1" value="dataset:-1201001.treat_hospital_cd"/>
  <item name="治療法名称（治療項目）" len="20" value="dataset:-1201001.treatment_name"/>
  <item name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
  <item name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
  <item name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
  <item name="ダイアライザコード" len="16" value="dataset:-1201002.dialyzer_cd"/>
  <item name="ダイアライザ名称" len="20" value="dataset:-1201002.dialyzer"/>
  <item name="抗凝固剤コード" len="8" value="dataset:-1201003.code"/>
  <item name="抗凝固剤総量" len="8" value="dataset:-1201003.quantity" padding_format="blank" padding_position="left"/>
  <item name="抗凝固剤単位" len="8" value="dataset:-1201003.unit"/>
  <item name="拮抗剤コード" len="8" value="$BLANK"/>
  <item name="拮抗剤総量" len="8" value="$BLANK"/>
  <item name="拮抗剤単位" len="8" value="$BLANK"/>
  <item name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
  <!-- <item name="透析液使用量" len="6" value="dataset:-1200XXXX.XXXXX" padding_format="blank" padding_position="left"/> -->
  <!-- <item name="透析液単位" len="8" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
  <item name="医療材料コード1" len="8" value="dataset:-1201005.code1"/>
  <item name="医療材料量1" len="6" value="dataset:-1201005.quantity1"/>
  <item name="医療材料コード2" len="8" value="dataset:-1201005.code2"/>
  <item name="医療材料量2" len="6" value="dataset:-1201005.quantity2"/>
  <item name="医療材料コード3" len="8" value="dataset:-1201005.code3"/>
  <item name="医療材料量3" len="6" value="dataset:-1201005.quantity3"/>
  <item name="医療材料コード4" len="8" value="dataset:-1201005.code4"/>
  <item name="医療材料量4" len="6" value="dataset:-1201005.quantity4"/>
  <item name="医療材料コード5" len="8" value="dataset:-1201005.code5"/>
  <item name="医療材料量5" len="6" value="dataset:-1201005.quantity5"/>
  <item name="医療材料コード6" len="8" value="dataset:-1201005.code6"/>
  <item name="医療材料量6" len="6" value="dataset:-1201005.quantity6"/>
  <item name="医療材料コード7" len="8" value="dataset:-1201005.code7"/>
  <item name="医療材料量7" len="6" value="dataset:-1201005.quantity7"/>
  <item name="医療材料コード8" len="8" value="dataset:-1201005.code8"/>
  <item name="医療材料量8" len="6" value="dataset:-1201005.quantity8"/>
  <item name="医療材料コード9" len="8" value="dataset:-1201005.code9"/>
  <item name="医療材料量9" len="6" value="dataset:-1201005.quantity9"/>
  <item name="医療材料コード10" len="8" value="dataset:-1201005.code10"/>
  <item name="医療材料量10" len="6" value="dataset:-1201005.quantity10"/>
  <item name="医療材料コード11" len="8" value="dataset:-1201005.code11"/>
  <item name="医療材料量11" len="6" value="dataset:-1201005.quantity11"/>
  <item name="医療材料コード12" len="8" value="dataset:-1201005.code12"/>
  <item name="医療材料量12" len="6" value="dataset:-1201005.quantity12"/>
  <item name="患者ID" len="50" value="dataset:-400002.hosp_pat_id"/>
  <!--   <occ name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-1201004"/>  -->
  <!-- 仕様を要確認 -->
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400001}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201005, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12071001, 'F_SX', 'rst_dial', '', 'S', 'cre', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <item name="処理区分" len="1" value="const:1"/>
  <!-- <item name="担当医" len="10" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="透析導入日" len="8" value="dataset:-1201000.dialysis_start"/>
  <item name="当院開始日" len="8" value="dataset:-1201000.hospital_start"/>
  <item name="実透析実施日" len="8" value="dataset:-506.start_date8"/>
  <item name="入外区分" len="1" value="dataset:-1201001.in_out"/>
  <item name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
  <item name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
  <item name="ベッド名称" len="10" value="dataset:-1201001.bed_name"/>
  <item name="治療法（装置モード）" len="1" value="dataset:-1201001.treat_hospital_cd"/>
  <item name="治療法名称（治療項目）" len="20" value="dataset:-1201001.treatment_name"/>
  <item name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
  <item name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
  <item name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
  <item name="ダイアライザコード" len="16" value="dataset:-1201002.dialyzer_cd"/>
  <item name="ダイアライザ名称" len="20" value="dataset:-1201002.dialyzer"/>
  <item name="抗凝固剤コード" len="8" value="dataset:-1201003.code"/>
  <item name="抗凝固剤総量" len="8" value="dataset:-1201003.quantity" padding_format="blank" padding_position="left"/>
  <item name="抗凝固剤単位" len="8" value="dataset:-1201003.unit"/>
  <item name="拮抗剤コード" len="8" value="$BLANK"/>
  <item name="拮抗剤総量" len="8" value="$BLANK"/>
  <item name="拮抗剤単位" len="8" value="$BLANK"/>
  <item name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
  <!-- <item name="透析液使用量" len="6" value="dataset:-1200XXXX.XXXXX" padding_format="blank" padding_position="left"/> -->
  <!-- <item name="透析液単位" len="8" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>


  <item name="医療材料コード1" len="8" value="dataset:-1201005.code1"/>
  <item name="医療材料量1" len="6" value="dataset:-1201005.quantity1"/>
  <item name="医療材料コード2" len="8" value="dataset:-1201005.code2"/>
  <item name="医療材料量2" len="6" value="dataset:-1201005.quantity2"/>
  <item name="医療材料コード3" len="8" value="dataset:-1201005.code3"/>
  <item name="医療材料量3" len="6" value="dataset:-1201005.quantity3"/>
  <item name="医療材料コード4" len="8" value="dataset:-1201005.code4"/>
  <item name="医療材料量4" len="6" value="dataset:-1201005.quantity4"/>
  <item name="医療材料コード5" len="8" value="dataset:-1201005.code5"/>
  <item name="医療材料量5" len="6" value="dataset:-1201005.quantity5"/>
  <item name="医療材料コード6" len="8" value="dataset:-1201005.code6"/>
  <item name="医療材料量6" len="6" value="dataset:-1201005.quantity6"/>
  <item name="医療材料コード7" len="8" value="dataset:-1201005.code7"/>
  <item name="医療材料量7" len="6" value="dataset:-1201005.quantity7"/>
  <item name="医療材料コード8" len="8" value="dataset:-1201005.code8"/>
  <item name="医療材料量8" len="6" value="dataset:-1201005.quantity8"/>
  <item name="医療材料コード9" len="8" value="dataset:-1201005.code9"/>
  <item name="医療材料量9" len="6" value="dataset:-1201005.quantity9"/>
  <item name="医療材料コード10" len="8" value="dataset:-1201005.code10"/>
  <item name="医療材料量10" len="6" value="dataset:-1201005.quantity10"/>
  <item name="医療材料コード11" len="8" value="dataset:-1201005.code11"/>
  <item name="医療材料量11" len="6" value="dataset:-1201005.quantity11"/>
  <item name="医療材料コード12" len="8" value="dataset:-1201005.code12"/>
  <item name="医療材料量12" len="6" value="dataset:-1201005.quantity12"/>
  <item name="患者ID" len="50" value="dataset:-400002.hosp_pat_id"/>
  <!--   <occ name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-1201004"/>  -->
  <!-- 仕様を要確認 -->
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400001}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"patId": "patId", "sqlCode": -1201000}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201001, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201002, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201003, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201005, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-12072001, 'F_SX', 'rst_dial', '', 'S', 'upd', 'text', 'SX連携_透析実績', 'F_SX', '透析実績', '1', '<root name="透析実績" multi="true:CRLF">
  <item name="ヘッダ" len="1" value="auto:1"/>
  <item name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no"/>
  <item name="処理区分" len="1" value="const:2"/>
  <!-- <item name="担当医" len="10" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="患者ID" len="12" value="dataset:-400002.hosp_pat_id"/>
  <item name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
  <item name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
  <item name="透析導入日" len="8" value="dataset:-1201000.dialysis_start"/>
  <item name="当院開始日" len="8" value="dataset:-1201000.hospital_start"/>
  <item name="実透析実施日" len="8" value="dataset:-506.start_date8"/>
  <item name="入外区分" len="1" value="dataset:-1201001.in_out"/>
  <item name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
  <item name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
  <item name="ベッド名称" len="10" value="dataset:-1201001.bed_name"/>
  <item name="治療法（装置モード）" len="1" value="dataset:-1201001.treat_hospital_cd"/>
  <item name="治療法名称（治療項目）" len="20" value="dataset:-1201001.treatment_name"/>
  <item name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
  <item name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
  <item name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
  <item name="ダイアライザコード" len="16" value="dataset:-1201002.dialyzer_cd"/>
  <item name="ダイアライザ名称" len="20" value="dataset:-1201002.dialyzer"/>
  <item name="抗凝固剤コード" len="8" value="dataset:-1201003.code"/>
  <item name="抗凝固剤総量" len="8" value="dataset:-1201003.quantity" padding_format="blank" padding_position="left"/>
  <item name="抗凝固剤単位" len="8" value="dataset:-1201003.unit"/>
  <item name="拮抗剤コード" len="8" value="$BLANK"/>
  <item name="拮抗剤総量" len="8" value="$BLANK"/>
  <item name="拮抗剤単位" len="8" value="$BLANK"/>
  <item name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
  <!-- <item name="透析液使用量" len="6" value="dataset:-1200XXXX.XXXXX" padding_format="blank" padding_position="left"/> -->
  <!-- <item name="透析液単位" len="8" value="dataset:-1200XXXX.XXXXX"/> -->
  <item name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
  <item name="医療材料コード1" len="8" value="dataset:-1201005.code1"/>
  <item name="医療材料量1" len="6" value="dataset:-1201005.quantity1"/>
  <item name="医療材料コード2" len="8" value="dataset:-1201005.code2"/>
  <item name="医療材料量2" len="6" value="dataset:-1201005.quantity2"/>
  <item name="医療材料コード3" len="8" value="dataset:-1201005.code3"/>
  <item name="医療材料量3" len="6" value="dataset:-1201005.quantity3"/>
  <item name="医療材料コード4" len="8" value="dataset:-1201005.code4"/>
  <item name="医療材料量4" len="6" value="dataset:-1201005.quantity4"/>
  <item name="医療材料コード5" len="8" value="dataset:-1201005.code5"/>
  <item name="医療材料量5" len="6" value="dataset:-1201005.quantity5"/>
  <item name="医療材料コード6" len="8" value="dataset:-1201005.code6"/>
  <item name="医療材料量6" len="6" value="dataset:-1201005.quantity6"/>
  <item name="医療材料コード7" len="8" value="dataset:-1201005.code7"/>
  <item name="医療材料量7" len="6" value="dataset:-1201005.quantity7"/>
  <item name="医療材料コード8" len="8" value="dataset:-1201005.code8"/>
  <item name="医療材料量8" len="6" value="dataset:-1201005.quantity8"/>
  <item name="医療材料コード9" len="8" value="dataset:-1201005.code9"/>
  <item name="医療材料量9" len="6" value="dataset:-1201005.quantity9"/>
  <item name="医療材料コード10" len="8" value="dataset:-1201005.code10"/>
  <item name="医療材料量10" len="6" value="dataset:-1201005.quantity10"/>
  <item name="医療材料コード11" len="8" value="dataset:-1201005.code11"/>
  <item name="医療材料量11" len="6" value="dataset:-1201005.quantity11"/>
  <item name="医療材料コード12" len="8" value="dataset:-1201005.code12"/>
  <item name="医療材料量12" len="6" value="dataset:-1201005.quantity12"/>
  <item name="患者ID" len="50" value="dataset:-400002.hosp_pat_id"/>
  <!--   <occ name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-1201004"/>  -->
  <!-- 仕様を要確認 -->
  <item name="改行定数" len="2" value="$CRLF"/>
</root>
', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400001}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -506}, {"patId": "patId", "sqlCode": -1201000}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201001, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201002, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201003, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -1201005, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'F_SX');
