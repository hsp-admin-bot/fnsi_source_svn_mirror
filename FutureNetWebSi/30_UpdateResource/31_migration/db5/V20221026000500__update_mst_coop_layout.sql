delete from mst_coop_layout where ctl_no in ('-1070001', '-1070002', '-1070003');
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070002, 'nkknkk', 'rst_dial', '', 'S', 'upd', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400011.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-107.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-110.calculate_one_shot_amount" padding_format="blank" padding_position="left"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-114.dialysate_amount" padding_format="blank" padding_position="left"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
    <occ  name="医療材料" len="0" repeat="108" detail="医材" sqlCode="-498"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-497"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root> ', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -498, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070001, 'nkknkk', 'rst_dial', '', 'S', 'cre', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400011.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-107.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-110.calculate_one_shot_amount" padding_format="blank" padding_position="left"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-114.dialysate_amount" padding_format="blank" padding_position="left"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
    <occ  name="医療材料" len="0" repeat="108" detail="医材" sqlCode="-498"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-497"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -114, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -498, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070003, 'nkknkk', 'rst_dial', '', 'S', 'del', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-505.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-513.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
    <item  name="ベッド名称" len="10" value="dataset:-505.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-514.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-506.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-506.end_time4"/>
    <item  name="透析実施時間" len="3" value="dataset:-506.running_time_str" padding_format="blank" padding_position="left"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-505.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-505.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-505.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-507.calculate_one_shot_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-505.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-505.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-508.dialysate_amount" padding_format="blank" padding_position="left"/>
    <item  name="透析液単位" len="8" value="dataset:-505.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="dataset:-509.oxygen_amount" padding_format="blank" padding_position="left"/>
    <occ  name="医療材料" len="0" repeat="108" detail="医材" sqlCode="-504"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-503"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -509, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -505, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -506, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -507, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -508, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -513, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -514, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -400011}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -504, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -503, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', CURRENT_TIMESTAMP);
