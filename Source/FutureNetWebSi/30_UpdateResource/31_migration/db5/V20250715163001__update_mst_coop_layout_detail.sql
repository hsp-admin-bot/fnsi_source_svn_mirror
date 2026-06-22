INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000000, 'Secom', 'rst_dial', 'S', 'med_top_del', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績連携_カルテ記録_del', '1', '<root name="セコム連携_透析実績_カルテ">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100000.hosp_pat_id"/>
<item name="発生日" value="dataset:-1100015.occur_date"/>
<item name="SEQ番号" value="dataset:-1100015.occur_time"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:1"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1103000.medical_record_text"/>
<item name="フリーワード" value="dataset:-1103000.free_word"/>
<item name="透析前体重" value="dataset:-1103000.weight_before"/>
<item name="透析後体重" value="dataset:-1103000.weight_after"/>
<item name="透析前バイタル" value="dataset:-1103000.vital_before"/>
<item name="透析後バイタル" value="dataset:-1103000.vital_after"/>
<item name="透析開始時刻" value="dataset:-1103000.rst_start_date"/>
<item name="透析終了時刻" value="dataset:-1103000.rst_end_date"/>
<item name="除水量" value="dataset:-1103000.add_total"/>
<item name="透析時間" value="dataset:-1103000.rst_running_time"/>
<item name="VA" value="dataset:-1103000.va_name"/>
<item name="目標体重" value="dataset:-1103000.target_weight"/>
<item name="血流量" value="dataset:-1103000.blood_flow"/>
<item name="透析液流量" value="dataset:-1103000.alqd_flood_vol"/>
<item name="補液量" value="dataset:-1103000.replenisher_amount"/>
<item name="抗凝固剤ワンショット量" value="dataset:-1103000.anticoagulant_oneshot"/>
<item name="抗凝固剤持続速度" value="dataset:-1103000.anticoagulant_speed"/>
<item name="抗凝固剤持続総量" value="dataset:-1103000.anticoagulant_amount"/>
<item name="指示簿指示" value="dataset:-1103000.ind_comment"/>
<item name="観察記録" value="dataset:-1103000.obs_record"/>

</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}, {"ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1100015, "fileKind": "medical", "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-1107000001, 'Secom', 'rst_dial', 'S', 'med_top_cre', '01', 'セコム連携_透析実績連携', 'セコム連携_透析実績連携_カルテ記録_cre', '1', '<root name="セコム連携_透析実績_カルテ">
  <item name="病院ID" value="dataset:-1100000.hospital_id"/>
<item name="患者ID" value="dataset:-1100000.hosp_pat_id"/>
<item name="発生日" value="$SHARED_SYSDATE:yyyy-MM-dd"/>
<item name="SEQ番号" value="$SHARED_SYSDATE:HH:mm:ss"/>
<item name="ユーザID" value="dataset:-1103000.user_id"/>
<item name="INDEX区分" value="const:5"/>
<item name="XX区分" value="dataset:-1100000.xx_type_code"/>
<item name="タイトル" value="$BLANK"/>
<item name="診療科コード" value="dataset:-1100000.course_cd1"/>
<item name="事業所コード" value="const:000"/>
<item name="入外区分" value="dataset:-1100006.in_out_class"/>
<item name="実施日" value="dataset:-1103000.treat_date"/>
<item name="未使用" value="$BLANK"/>
<item name="未使用" value="$BLANK"/>
<item name="中止フラグ" value="const:0"/>
<item name="中止日" value="$BLANK"/>
<item name="中止時刻" value="$BLANK"/>
<item name="中止ユーザ" value="$BLANK"/>
<item name="事後入力フラグ" value="const:0"/>
<item name="カルテ記録テキスト" value="dataset:-1103000.medical_record_text"/>
<item name="フリーワード" value="dataset:-1103000.free_word"/>
<item name="透析前体重" value="dataset:-1103000.weight_before"/>
<item name="透析後体重" value="dataset:-1103000.weight_after"/>
<item name="透析前バイタル" value="dataset:-1103000.vital_before"/>
<item name="透析後バイタル" value="dataset:-1103000.vital_after"/>
<item name="透析開始時刻" value="dataset:-1103000.rst_start_date"/>
<item name="透析終了時刻" value="dataset:-1103000.rst_end_date"/>
<item name="除水量" value="dataset:-1103000.add_total"/>
<item name="透析時間" value="dataset:-1103000.rst_running_time"/>
<item name="VA" value="dataset:-1103000.va_name"/>
<item name="目標体重" value="dataset:-1103000.target_weight"/>
<item name="血流量" value="dataset:-1103000.blood_flow"/>
<item name="透析液流量" value="dataset:-1103000.alqd_flood_vol"/>
<item name="補液量" value="dataset:-1103000.replenisher_amount"/>
<item name="抗凝固剤ワンショット量" value="dataset:-1103000.anticoagulant_oneshot"/>
<item name="抗凝固剤持続速度" value="dataset:-1103000.anticoagulant_speed"/>
<item name="抗凝固剤持続総量" value="dataset:-1103000.anticoagulant_amount"/>
<item name="指示簿指示" value="dataset:-1103000.ind_comment"/>
<item name="観察記録" value="dataset:-1103000.obs_record"/>
</root>
', '{"dataset": [{"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ordNo", "patId": "patId", "sqlCode": -1100000, "facilityCd": "facility_cd"}, {"key0": "key0", "patId": "patId", "sqlCode": -1100006, "facilityCd": "facility_cd"}, {"key0": "key0", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "sqlCode": -1103000, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'Secom');