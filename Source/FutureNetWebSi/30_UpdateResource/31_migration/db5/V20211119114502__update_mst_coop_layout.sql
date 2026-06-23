delete from "mst_coop_layout" where "ctl_no" in (-3070006,-3070005,-3070004,-3070003,-3070002,-3070001);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070003, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver1)', '1', ' <root name="透析実績(Ver1)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:D"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="$BLANK"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="$BLANK"/>
    <item  name="更新者" len="10" value="dataset:-102.param18"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param19"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070002, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver1)', '1', ' <root name="透析実績(Ver1)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:U"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="$BLANK"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="$BLANK"/>
    <item  name="更新者" len="10" value="dataset:-102.param18"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param19"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070001, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver1)', '1', ' <root name="透析実績(Ver1)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:Y"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="$BLANK"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="$BLANK"/>
    <item  name="更新者" len="10" value="dataset:-102.param18"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param19"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '0', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070004, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver2)', '1', ' <root name="透析実績(Ver2)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:Y"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="const:0000"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="dataset:-102.param17"/>
    <item  name="更新者" len="10" value="$JOURNAL.user_id"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070005, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver2)', '1', ' <root name="透析実績(Ver2)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:U"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="const:0000"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="dataset:-102.param17"/>
    <item  name="更新者" len="10" value="$JOURNAL.user_id"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3070006, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver2)', '1', ' <root name="透析実績(Ver2)">
    <item  name="コマンド名" len="8" value="const:C-DSEXEC"/>
    <item  name="処理区分" len="1" value="const:D"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="実施開始日" len="8" value="dataset:-14.start_date8"/>
    <item  name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
    <item  name="実施終了日" len="8" value="dataset:-14.end_date8"/>
    <item  name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
    <item  name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
    <item  name="実施診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="実施医師" len="10" value="dataset:-102.param03"/>
    <item  name="実施医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="前体重" len="5" value="dataset:-33.weight_before"/>
    <item  name="後体重" len="5" value="dataset:-33.weight_after"/>
    <item  name="心胸比" len="4" value="const:0000"/>
    <item  name="心電図" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-11.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="指示オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="血液浄化法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
    <item  name="更新端末" len="10" value="dataset:-102.param17"/>
    <item  name="更新者" len="10" value="$JOURNAL.user_id"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="実績詳細"  sqlCode="-202"/>
    <occ  name="コメント詳細" len="5" detail="コメント"  sqlCode="-203"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"patId": "patId", "sqlCode": -102}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "sqlCode": -202}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203}]}', '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP);
