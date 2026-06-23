delete from "mst_coop_layout" where "facility_cd" = 'N_hosp' and "coop_cd" = 'ind_dial';
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040001, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:A"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="透析種別" len="1" value="dataset:-102.param11"/>
    <item  name="透析コース" len="6" value="dataset:-102.param12"/>
    <item  name="透析パターン" len="6" value="dataset:-102.param13"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="dataset:-13.va3"/>
    <item  name="部位" len="6" value="dataset:-13.va_direct"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="dataset:-102.param07"/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param09"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '0', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040002, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:U"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="透析種別" len="1" value="dataset:-102.param11"/>
    <item  name="透析コース" len="6" value="dataset:-102.param12"/>
    <item  name="透析パターン" len="6" value="dataset:-102.param13"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="dataset:-13.va3"/>
    <item  name="部位" len="6" value="dataset:-13.va_direct"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="dataset:-102.param07"/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param09"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '0', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040003, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:D"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="dataset:-102.param04"/>
    <item  name="保険コード01" len="3" value="dataset:-32.pi1"/>
    <item  name="保険コード02" len="3" value="dataset:-32.pi2"/>
    <item  name="保険コード03" len="3" value="dataset:-32.pi3"/>
    <item  name="保険コード04" len="3" value="dataset:-32.pi4"/>
    <item  name="保険コード05" len="3" value="dataset:-32.pi5"/>
    <item  name="透析種別" len="1" value="dataset:-102.param11"/>
    <item  name="透析コース" len="6" value="dataset:-102.param12"/>
    <item  name="透析パターン" len="6" value="dataset:-102.param13"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-102.param02"/>
    <item  name="加算" len="6" value="dataset:-102.param05"/>
    <item  name="加算世代番号" len="1" value="dataset:-102.param06"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="dataset:-13.va3"/>
    <item  name="部位" len="6" value="dataset:-13.va_direct"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="dataset:-102.param07"/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="dataset:-102.param09"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '0', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040004, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:A"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="透析種別" len="1" value="const:2"/>
    <item  name="透析コース" len="6" value="$BLANK"/>
    <item  name="透析パターン" len="6" value="$BLANK"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-13.bed_cd1"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="$BLANK"/>
    <item  name="部位" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="const:Futurenet "/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '1', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040005, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:U"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="透析種別" len="1" value="const:2"/>
    <item  name="透析コース" len="6" value="$BLANK"/>
    <item  name="透析パターン" len="6" value="$BLANK"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-13.bed_cd1"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="$BLANK"/>
    <item  name="部位" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="const:Futurenet "/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '1', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3040006, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)', '1', '<root name="透析予約">
    <item  name="コマンド名" len="8" value="const:C-DSDIRE"/>
    <item  name="処理区分" len="1" value="const:D"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
    <item  name="患者氏名" len="40" value="$BLANK"/>
    <item  name="患者カナ名" len="20" value="$BLANK"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <item  name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
    <item  name="情報区分" len="1" value="$BLANK"/>
    <item  name="指示診療科" len="2" value="dataset:-11.course_cd"/>
    <item  name="指示医師" len="10" value="dataset:-102.param03"/>
    <item  name="指示医師世代番号" len="1" value="const:0"/>
    <item  name="保険コード01" len="3" value="$BLANK"/>
    <item  name="保険コード02" len="3" value="$BLANK"/>
    <item  name="保険コード03" len="3" value="$BLANK"/>
    <item  name="保険コード04" len="3" value="$BLANK"/>
    <item  name="保険コード05" len="3" value="$BLANK"/>
    <item  name="透析種別" len="1" value="const:2"/>
    <item  name="透析コース" len="6" value="$BLANK"/>
    <item  name="透析パターン" len="6" value="$BLANK"/>
    <item  name="開始日" len="8" value="dataset:-102.param05"/>
    <item  name="終了日" len="8" value="dataset:-102.param06"/>
    <item  name="透析日" len="8" value="dataset:-13.dialysis_date"/>
    <item  name="透析時間" len="4" value="dataset:-13.treatment_time4"/>
    <item  name="透析導入日" len="8" value="dataset:-13.dialysis_start_date"/>
    <item  name="実施場所" len="6" value="dataset:-13.bed_cd1"/>
    <item  name="加算" len="6" value="$BLANK"/>
    <item  name="加算世代番号" len="1" value="$BLANK"/>
    <item  name="ベッド予約番号" len="13" value="const:0000000000000"/>
    <item  name="使用ベッド" len="6" value="const:000000"/>
    <item  name="ベッド予約時間帯" len="1" value="dataset:-13.kur_cd1"/>
    <item  name="ブラッドアクセス" len="6" value="$BLANK"/>
    <item  name="部位" len="6" value="$BLANK"/>
    <item  name="ＤＷ" len="4" value="dataset:-34.dw"/>
    <item  name="血液浄化法" len="6" value="dataset:-13.treatment_cd"/>
    <item  name="血液浄化法世代番号" len="1" value="const:0"/>
    <item  name="依頼オーダ番号" len="16" value="dataset:-102.param01"/>
    <item  name="実施オーダ番号" len="16" value="const:0000000000000000"/>
    <item  name="進捗" len="2" value="const:AA"/>
    <item  name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
    <item  name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
    <item  name="新規登録日" len="8" value="$BLANK"/>
    <item  name="新規登録時間" len="6" value="$BLANK"/>
    <item  name="更新日" len="8" value="dataset:-13.update_ymd"/>
    <item  name="更新時間" len="6" value="dataset:-13.update_hms"/>
    <item  name="更新端末" len="10" value="const:Futurenet "/>
    <item  name="更新者" len="10" value="dataset:-102.param08"/>
    <item  name="更新者世代番号" len="1" value="const:0"/>
    <item  name="予備" len="30" value="$BLANK"/>
    <occ  name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -11}, {"patId": "patId", "sqlCode": -102}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -13}, {"ordNo": "ordNo", "sqlCode": -34}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -204}]}', '1', '1', 4, '2020-05-20 10:53:24.901', '2020-05-20 10:53:27.525');
