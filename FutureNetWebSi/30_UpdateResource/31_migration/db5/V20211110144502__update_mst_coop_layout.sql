delete from "mst_coop_layout" where "ctl_no" in (-1070001,-1070002,-1070003,-1070004,-1070005,-1070006);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070006, 'nkknkk', 'rst_dial', '', 'S', 'del', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
    <item  name="処理日時" len="14" value="$SYSDATE"/>
    <item  name="処理区分" len="1" value="const:2"/>
    <item  name="指示診療No" len="10" value="$BLANK"/>
    <item  name="診療科コード" len="2" value="$BLANK"/>
    <item  name="医師コード" len="10" value="dataset:-11.charge1_name"/>
    <item  name="透析番号" len="12" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left"/>
    <item  name="ヘッダ1" len="1" value="auto:1"/>
    <item  name="ヘッダ2" len="1" value="dataset:-496.total_cnt"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="8" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495" multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}, {"ordNo": "ordNo", "sqlCode": -496}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '1', 4, '2020-04-13 19:46:08.901', '2020-04-13 19:46:12.519');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070005, 'nkknkk', 'rst_dial', '', 'S', 'upd', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
    <item  name="処理日時" len="14" value="$SYSDATE"/>
    <item  name="処理区分" len="1" value="const:1"/>
    <item  name="指示診療No" len="10" value="$BLANK"/>
    <item  name="診療科コード" len="2" value="$BLANK"/>
    <item  name="医師コード" len="10" value="dataset:-11.charge1_name"/>
    <item  name="透析番号" len="12" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left"/>
    <item  name="ヘッダ1" len="1" value="auto:1"/>
    <item  name="ヘッダ2" len="1" value="dataset:-496.total_cnt"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="8" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495" multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}, {"ordNo": "ordNo", "sqlCode": -496}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '1', 4, '2020-04-13 19:46:08.901', '2020-04-13 19:46:12.519');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070004, 'nkknkk', 'rst_dial', '', 'S', 'cre', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
    <item  name="処理日時" len="14" value="$SYSDATE"/>
    <item  name="処理区分" len="1" value="const:1"/>
    <item  name="指示診療No" len="10" value="$BLANK"/>
    <item  name="診療科コード" len="2" value="$BLANK"/>
    <item  name="医師コード" len="10" value="dataset:-11.charge1_name"/>
    <item  name="透析番号" len="12" value="$JOURNAL.ord_no" padding_format="zero" padding_position="left"/>
    <item  name="ヘッダ1" len="1" value="auto:1"/>
    <item  name="ヘッダ2" len="1" value="dataset:-496.total_cnt"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="8" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495" multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}, {"ordNo": "ordNo", "sqlCode": -496}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '1', 4, '2020-04-13 19:46:08.901', '2020-04-13 19:46:12.519');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070003, 'nkknkk', 'rst_dial', '', 'S', 'del', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', '2020-04-13 17:14:58.009');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070002, 'nkknkk', 'rst_dial', '', 'S', 'upd', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', '2020-04-13 17:14:58.009');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-1070001, 'nkknkk', 'rst_dial', '', 'S', 'cre', 'text', '日機装標準', 'nikkiso', '透析実績(標準)', '1', '<root name="日機装標準(透析実績)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="患者番号" len="12" value="dataset:-400001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="$BLANK"/>
    <item  name="当院開始日" len="8" value="$BLANK"/>
    <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
    <item  name="透析困難症のコメント" len="40" value="dataset:-16.cd"/>
    <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
    <item  name="治療名" len="1" value="dataset:-11.treatment_cd"/>
    <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
    <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
    <item  name="透析実施時間" len="3" value="$BLANK"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-11.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-11.anti_coagulant_total_amount"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
    <item  name="透析液使用量" len="6" value="dataset:-11.dialysate_amount"/>
    <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-494"/>
    <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-495"  multi="true"/>
    <item  name="改行定数" len="2" value="$CRLF"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"ordNo": "ordNo", "sqlCode": -11}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"ordNo": "ordNo", "sqlCode": -494}, {"ordNo": "ordNo", "sqlCode": -495}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99991}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 17:14:53.55', '2020-04-13 17:14:58.009');
