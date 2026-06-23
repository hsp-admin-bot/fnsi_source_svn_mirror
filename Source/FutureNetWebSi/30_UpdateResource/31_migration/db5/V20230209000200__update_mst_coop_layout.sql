delete from "mst_coop_layout" where "ctl_no" in(-1040003);
INSERT INTO "ntss"."mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (-1040003, 'nkknkk', 'ind_dial', '', 'S', 'del', 'text', '日機装標準', 'nikkiso', '透析予約', '1', '<root name="日機装標準(透析予約)" multi="true:CRLF">
    <item  name="ヘッダ" len="1" value="auto:1"/>
    <item  name="オーダ番号" len="8" value="$JOURNAL.coop_ord_no" padding_format="zero" padding_position="left"/>
    <item  name="処理区分" len="1" value="const:3"/>
    <item  name="担当医" len="10" value="dataset:-952.disp_user_id"/>
    <item  name="患者ID" len="12" value="dataset:-400001.hosp_pat_id12"/>
    <item  name="患者氏名" len="20" value="dataset:-400001.pat_name"/>
    <item  name="生年月日" len="8" value="dataset:-400001.pat_birthday8"/>
    <item  name="透析導入日" len="8" value="dataset:-132.dialysis_start_date"/>
    <item  name="当院開始日" len="8" value="dataset:-132.hospital_start_date"/>
    <item  name="透析実施日" len="8" value="dataset:-131.dialysis_date"/>
    <item  name="入外区分" len="1" value="dataset:-400001.in_out_class"/>
    <item  name="透析困難症有無" len="1" value="dataset:-400001.dial_diff_com_info_flag_test"/>
    <item  name="透析困難症コメント" len="40" value="dataset:-400004.dial_diff_name"/>
    <item  name="ベッド名称" len="10" value="dataset:-131.bed_name"/>
    <item  name="治療項目コード" len="1" value="dataset:-131.treatment_cd"/>
    <item  name="治療項目名称" len="20" value="dataset:-131.treatment_name"/>
    <item  name="透析開始時刻" len="4" value="dataset:-131.start_time"/>
    <item  name="透析終了時刻" len="4" value="dataset:-131.end_time" padding_format="zero" padding_position="left"/>
    <item  name="透析実施時間" len="3" value="dataset:-131.dialysis_time_m" padding_format="blank" padding_position="left"/>
    <item  name="ダイアライザコード" len="16" value="dataset:-131.dialyzer_cd1"/>
    <item  name="ダイアライザ名称" len="20" value="dataset:-131.dialyzer"/>
    <item  name="抗凝固剤コード" len="8" value="dataset:-661.medi_cd1"/>
    <item  name="抗凝固剤総量" len="8" value="dataset:-661.medi_amount" padding_format="blank" padding_position="left"/>
    <item  name="抗凝固剤単位" len="8" value="dataset:-661.medi_unit"/>
    <item  name="拮抗剤コード" len="8" value="$BLANK"/>
    <item  name="拮抗剤総量" len="8" value="$BLANK"/>
    <item  name="拮抗剤単位" len="8" value="$BLANK"/>
    <item  name="透析液コード" len="8" value="dataset:-131.dialysate_cd1"/>
    <item  name="透析液使用量" len="6" value="dataset:-502.dialysate_amount" padding_format="blank" padding_position="left"/>
    <item  name="透析液単位" len="8" value="dataset:-131.dialysate_amount_unit"/>
    <item  name="酸素吸入量" len="6" value="$BLANK"/>
    <occ  name="医療材料" len="0" repeat="12" detail="医療材料del" sqlCode="-191" />
    <occ  name="投与薬剤" len="0" repeat="15" detail="投与薬剤del" sqlCode="-181" multi="true"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -400001}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -661, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -131}, {"ordNo": "ordNo", "sqlCode": -13}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -952, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -852, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -181, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -502, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -191, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -400014}, {"patId": "patId", "sqlCode": -400004, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -132, "facilityCd": "facilityCd"}], "dumpFileName": {"ctlNo": "ctlNo", "sqlCode": -99992}, "CoopIniConvUtil": {"-400001.in_out_class": "CONV_INOUT_TO_KARTE"}}', '1', '0', -4, '2022-07-04 05:09:15.054',CURRENT_TIMESTAMP, '');
