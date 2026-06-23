DELETE FROM "ntss"."mst_coop_layout" WHERE ctl_no ='-1070004';
DELETE FROM "ntss"."mst_coop_layout" WHERE ctl_no ='-1070005';
DELETE FROM "ntss"."mst_coop_layout" WHERE ctl_no ='-1070006';
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1070006, 'nkknkk', 'rst_dial', '', 'S', 'del', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
     <item  name="処理日時" len="14" value="$SYSDATE yyyyMMddHHmmss"/>
     <item  name="処理区分" len="1" value="const:2"/>
     <item  name="指示診療No" len="10" value="dataset:-108.ord_no"/>
     <item  name="診療科コード" len="2" value="dataset:-510.in_hospital_cd_1"/>
     <item  name="医師コード" len="10" value="dataset:-112.disp_user_id"/>
     <item  name="透析番号" len="12" value="dataset:-511.coop_ord_no" padding_format="zero" padding_position="left"/>
     <item  name="ヘッダ1" len="1" value="auto:1"/>
     <item  name="ヘッダ2" len="1" value="dataset:-512.total_cnt"/>
     <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
     <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
     <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
     <item  name="透析導入日" len="8" value="dataset:-499.dialysis_start_date"/>
     <item  name="当院開始日" len="8" value="dataset:-111.start_date"/>
     <item  name="実施日" len="8" value="dataset:-505.treat_date"/>
     <item  name="入外区分" len="1" value="dataset:-513.in_out_class"/>
     <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
     <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
     <item  name="ベッド名称" len="10" value="dataset:-505.bed_name"/>
     <item  name="治療名" len="1" value="dataset:-514.treatment_cd"/>
     <item  name="透析開始時刻" len="4" value="dataset:-506.start_time4"/>
     <item  name="透析終了時刻" len="4" value="dataset:-506.end_time4"/>
     <item  name="透析実施時間" len="3" value="dataset:-506.running_time_str" padding_format="blank" padding_position="left"/>
     <item  name="ダイアライザコード" len="8" value="dataset:-505.dialyzer_cd1"/>
     <item  name="ダイアライザ名称" len="20" value="dataset:-505.dialyzer"/>
     <item  name="抗凝固剤コード" len="8" value="dataset:-505.ds_cd1"/>
     <item  name="抗凝固剤総量" len="8" value="dataset:-507.calculate_one_shot_amount" padding_format="blank" padding_position="left"/>
     <item  name="抗凝固剤単位" len="8" value="dataset:-505.anti_coagulant_one_shot_amount_unit"/>
     <item  name="透析液コード" len="8" value="dataset:-505.ds_cd"/>
     <item  name="透析液使用量" len="6" value="dataset:-508.dialysate_amount" padding_format="blank" padding_position="left"/>
     <item  name="透析液単位" len="8" value="dataset:-505.dialysate_amount_unit"/>
     <item  name="酸素吸入量" len="6" value="dataset:-509.oxygen_amount" padding_format="blank" padding_position="left"/>
     <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-504" multi="true"/>
     <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-503" multi="true"/><item  name="改行定数" len="2" value="$CRLF"/>
 </root>', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -505, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -506, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -507, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -508, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -509, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -510, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -511, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"ordNo": "ordNo", "sqlCode": -512, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -513, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -514, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -400012, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -504, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -503, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -210}, {"ordNo": "ordNo", "sqlCode": -499}, {"ordNo": "ordNo", "sqlCode": -496}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -105, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -106, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -108, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -112, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "test": 99999999, "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -111}, {"key0": "key0", "sqlCode": -515, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -517, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 19:46:08.901',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1070005, 'nkknkk', 'rst_dial', '', 'S', 'upd', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
     <item  name="処理日時" len="14" value="$SYSDATE yyyyMMddHHmmss"/>
     <item  name="処理区分" len="1" value="const:1"/>
     <item  name="指示診療No" len="10" value="dataset:-108.ord_no"/>
     <item  name="診療科コード" len="2" value="dataset:-105.in_hospital_cd_1"/>
     <item  name="医師コード" len="10" value="dataset:-112.disp_user_id"/>
     <item  name="透析番号" len="12" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"/>
     <item  name="ヘッダ1" len="1" value="auto:1"/>
     <item  name="ヘッダ2" len="1" value="dataset:-496.total_cnt"/>
     <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
     <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
     <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
     <item  name="透析導入日" len="8" value="dataset:-499.dialysis_start_date"/>
     <item  name="当院開始日" len="8" value="dataset:-111.start_date"/>
     <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
     <item  name="入外区分" len="1" value="dataset:-106.in_out_class"/>
     <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
     <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
     <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
     <item  name="治療名" len="1" value="dataset:-107.treatment_cd"/>
     <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
     <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
     <item  name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
     <item  name="ダイアライザコード" len="8" value="dataset:-11.dialyzer_cd1"/>
     <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
     <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd2"/>
     <item  name="抗凝固剤総量" len="8" value="dataset:-110.calculate_one_shot_amount" padding_format="blank" padding_position="left"/>
     <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
     <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
     <item  name="透析液使用量" len="6" value="dataset:-400012.dialysate_amount" padding_format="blank" padding_position="left"/>
     <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
     <item  name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
     <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-498" multi="true"/>
     <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-497" multi="true"/>
     <item  name="改行定数" len="2" value="$CRLF"/>
 </root>', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -400012, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -498, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -210}, {"ordNo": "ordNo", "sqlCode": -499}, {"ordNo": "ordNo", "sqlCode": -496}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -105, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -106, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -108, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -112, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -111}, {"key0": "key0", "sqlCode": -515, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -516, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -518, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 19:46:08.901',CURRENT_TIMESTAMP, '');
INSERT INTO "ntss"."mst_coop_layout" ("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1070004, 'nkknkk', 'rst_dial', '', 'S', 'cre', 'text', '日機装拡張', 'nikkiso', '透析実績(拡張)', '1', '<root name="日機装拡張(透析実績)" multi="true:CRLF">
     <item  name="処理日時" len="14" value="$SYSDATE yyyyMMddHHmmss"/>
     <item  name="処理区分" len="1" value="const:1"/>
     <item  name="指示診療No" len="10" value="dataset:-108.ord_no"/>
     <item  name="診療科コード" len="2" value="dataset:-105.in_hospital_cd_1"/>
     <item  name="医師コード" len="10" value="dataset:-112.disp_user_id"/>
     <item  name="透析番号" len="12" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"/>
     <item  name="ヘッダ1" len="1" value="auto:1"/>
     <item  name="ヘッダ2" len="1" value="dataset:-496.total_cnt"/>
     <item  name="患者番号" len="12" value="dataset:-400002.hosp_pat_id"/>
     <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
     <item  name="患者生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
     <item  name="透析導入日" len="8" value="dataset:-499.dialysis_start_date"/>
     <item  name="当院開始日" len="8" value="dataset:-111.start_date"/>
     <item  name="実施日" len="8" value="dataset:-11.treat_date"/>
     <item  name="入外区分" len="1" value="dataset:-106.in_out_class"/>
     <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag"/>
     <item  name="透析困難症のコメント" len="40" value="dataset:-400004.dial_diff_name"/>
     <item  name="ベッド名称" len="10" value="dataset:-11.bed_name"/>
     <item  name="治療名" len="1" value="dataset:-107.treatment_cd"/>
     <item  name="透析開始時刻" len="4" value="dataset:-14.start_time4"/>
     <item  name="透析終了時刻" len="4" value="dataset:-14.end_time4"/>
     <item  name="透析実施時間" len="3" value="dataset:-14.running_time_str" padding_format="blank" padding_position="left"/>
     <item  name="ダイアライザコード" len="8" value="dataset:-11.dialyzer_cd1"/>
     <item  name="ダイアライザ名称" len="20" value="dataset:-11.dialyzer"/>
     <item  name="抗凝固剤コード" len="8" value="dataset:-11.ds_cd2"/>
     <item  name="抗凝固剤総量" len="8" value="dataset:-110.calculate_one_shot_amount" padding_format="blank" padding_position="left"/>
     <item  name="抗凝固剤単位" len="8" value="dataset:-11.anti_coagulant_one_shot_amount_unit"/>
     <item  name="透析液コード" len="8" value="dataset:-11.ds_cd"/>
     <item  name="透析液使用量" len="6" value="dataset:-400012.dialysate_amount" padding_format="blank" padding_position="left"/>
     <item  name="透析液単位" len="8" value="dataset:-11.dialysate_amount_unit"/>
     <item  name="酸素吸入量" len="6" value="dataset:-400013.oxygen_amount" padding_format="blank" padding_position="left"/>
     <occ  name="医療材料" len="0" repeat="12" detail="医材" sqlCode="-498" multi="true"/>
     <occ  name="投与薬剤" len="0" repeat="15" detail="薬剤" sqlCode="-497" multi="true"/>
     <item  name="改行定数" len="2" value="$CRLF"/>
 </root>', '{"dataset": [{"key0": "key0", "ordNo": "ordNo", "sqlCode": -400013, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -400012, "facilityCd": "facilityCd"}, {"key0": "key0", "patId": "patId", "sqlCode": -400002, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -16}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -494, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -498, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -497, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -210}, {"ordNo": "ordNo", "sqlCode": -499}, {"ordNo": "ordNo", "sqlCode": -496}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -105, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -106, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -107, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -108, "facilityCd": "facilityCd", "coopVersion": "coopVersion"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -112, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -110, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -111}, {"key0": "key0", "sqlCode": -515, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -516, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "sqlCode": -518, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99990}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', 4, '2020-04-13 19:46:08.901',CURRENT_TIMESTAMP, '');
