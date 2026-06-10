DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-3040001, -3040002, -3040003, -3040004, -3040005, -3040006, -3040007, -3040008, -3040009, -3040010, -3040011, -3040012, -3070001, -3070002, -3070003, -3070004, -3070005, -3070006, -3070007, -3070008, -3070009, -3070010, -3070011, -3070012);

INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040001, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040002, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040003, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}]}'::jsonb, '1', '0', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040004, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040005, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040006, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, '2020-05-20 10:53:24.901', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040007, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040008, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040009, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver1)/TSHPlus', '1', '<root name="透析予約">
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="dataset:-102.ind_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="dataset:-102.dialysis_type"/>
  <item name="透析コース" len="6" value="dataset:-102.dialysis_course"/>
  <item name="透析パターン" len="6" value="dataset:-102.dialysis_pattern"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="dataset:-102.va3"/>
  <item name="部位" len="6" value="dataset:-102.va_direct"/>
  <item name="ＤＷ" len="4" value="dataset:-102.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040010, 'N_hosp', 'ind_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:A"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040011, 'N_hosp', 'ind_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="dataset:-600202.dialysis_date"/>
  <item name="透析時間" len="4" value="dataset:-600200.treatment_start_time"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="dataset:-600200.bed_reservation_time"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="指示詳細" sqlCode="-204"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "U", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "patId": "patId", "sqlCode": -204, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "HR", "ordNo": "ordNo", "sqlCode": -600200, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3040012, 'N_hosp', 'ind_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '詳細指示(Ver2)/Standard', '1', '<root name="透析予約">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSDIRE"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSDIRE"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="$JOURNAL.coop_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="指示診療科" len="2" value="dataset:-102.ind_course"/>
  <item name="指示医師" len="10" value="dataset:-102.ind_doctor"/>
  <item name="指示医師世代番号" len="1" value="const:0"/>
  <item name="保険コード01" len="3" value="$BLANK"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="透析種別" len="1" value="const:2"/>
  <item name="透析コース" len="6" value="$BLANK"/>
  <item name="透析パターン" len="6" value="$BLANK"/>
  <item name="開始日" len="8" value="dataset:-102.start_date_regular"/>
  <item name="終了日" len="8" value="dataset:-102.end_date_regular"/>
  <item name="透析日" len="8" value="$BLANK"/>
  <item name="透析時間" len="4" value="$BLANK"/>
  <item name="透析導入日" len="8" value="dataset:-600202.dialysis_start_date"/>
  <item name="実施場所" len="6" value="dataset:-600202.bed_cd1"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="ベッド予約番号" len="13" value="const:0000000000000"/>
  <item name="使用ベッド" len="6" value="const:000000"/>
  <item name="ベッド予約時間帯" len="1" value="$BLANK"/>
  <item name="ブラッドアクセス" len="6" value="$BLANK"/>
  <item name="部位" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600202.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600202.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="依頼オーダ番号" len="16" value="dataset:-102.ord_no"/>
  <item name="実施オーダ番号" len="16" value="const:0000000000000000"/>
  <item name="進捗" len="2" value="const:AA"/>
  <item name="血液浄化方法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化方法　医事世代コード" len="1" value="$BLANK"/>
  <item name="新規登録日" len="8" value="$BLANK"/>
  <item name="新規登録時間" len="6" value="$BLANK"/>
  <item name="更新日" len="8" value="dataset:-600202.update_ymd"/>
  <item name="更新時間" len="6" value="dataset:-600202.update_hms"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "D", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -600202, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070001, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070002, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070003, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/Standard', '1', '<root name="透析実績(Ver1)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070004, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070005, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070006, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/TSHPlus', '1', '<root name="透析実績(Ver2)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, '2020-05-19 17:01:48.871', CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070007, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070008, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-11.treatment_cd"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"patId": "patId", "sqlCode": -32}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "1"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070009, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver1)/TSHPlus', '1', '<root name="透析実績(Ver1)">
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-102.implementation_place"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v1"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.insurance_code_01"/>
  <item name="保険コード02" len="3" value="dataset:-102.insurance_code_02"/>
  <item name="保険コード03" len="3" value="dataset:-102.insurance_code_03"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="dataset:-102.addition"/>
  <item name="加算世代番号" len="1" value="dataset:-102.addition_generation_no"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-102.blood_purification_method"/>
  <item name="血液浄化法世代番号" len="1" value="dataset:-102.blood_purification_generation_no"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-102.updater"/>
  <item name="更新者世代番号" len="1" value="dataset:-102.updater_generation_no"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "1"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070010, 'N_hosp', 'rst_dial', '', 'S', 'cre', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:Y"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070011, 'N_hosp', 'rst_dial', '', 'S', 'upd', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:U"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="dataset:-14.start_date8"/>
  <item name="実施開始時間" len="4" value="dataset:-14.start_date6"/>
  <item name="実施終了日" len="8" value="dataset:-14.end_date8"/>
  <item name="実施終了時間" len="4" value="dataset:-14.end_date6"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="dataset:-33.weight_before"/>
  <item name="後体重" len="5" value="dataset:-33.weight_after"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="dataset:-600303.dw"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
  <occ name="項目詳細" len="5" detail="実績詳細" sqlCode="-202"/>
  <occ name="コメント詳細" len="5" detail="コメント" sqlCode="-203"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"ordNo": "ordNo", "sqlCode": -14}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"ordNo": "ordNo", "sqlCode": -33}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -202, "facilityCd": "facilityCd", "messageType": "2"}, {"ordNo": "ordNo", "patId": "patId", "sqlCode": -203, "facilityCd": "facilityCd", "messageType": "2"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');
INSERT INTO mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-3070012, 'N_hosp', 'rst_dial', '', 'S', 'del', 'text', 'NEC', 'MEGA', '透析実績（Ver2)/Standard', '1', '<root name="透析実績(Ver2)">
  <item name="送信先ID" len="6" value="$BLANK"/>
  <item name="送信元ID" len="6" value="$BLANK"/>
  <item name="処理コマンド" len="8" value="const:C-DSEXEC"/>
  <item name="受信結果" len="6" value="$BLANK"/>
  <item name="データ長" len="6" value="$LENGTH-32"/>
  <item name="コマンド名" len="8" value="const:C-DSEXEC"/>
  <item name="処理区分" len="1" value="const:D"/>
  <item name="病院コード" len="2" value="const:01"/>
  <item name="患者番号" len="10" value="dataset:-600001.hosp_pat_id" padding_format="zero" padding_position="left"/>
  <item name="患者氏名" len="40" value="$BLANK"/>
  <item name="患者カナ名" len="20" value="$BLANK"/>
  <item name="予備" len="30" value="$BLANK"/>
  <item name="オーダ番号" len="16" value="dataset:-600303.rst_ord_no"/>
  <item name="情報区分" len="1" value="$BLANK"/>
  <item name="実施開始日" len="8" value="$BLANK"/>
  <item name="実施開始時間" len="4" value="$BLANK"/>
  <item name="実施終了日" len="8" value="$BLANK"/>
  <item name="実施終了時間" len="4" value="$BLANK"/>
  <item name="実施場所" len="6" value="dataset:-11.bed_cd1"/>
  <item name="実施診療科" len="2" value="dataset:-102.rst_del_course"/>
  <item name="実施医師" len="10" value="dataset:-102.rst_doctor_v2"/>
  <item name="実施医師世代番号" len="1" value="dataset:-102.rst_doctor_generation_no"/>
  <item name="保険コード01" len="3" value="dataset:-102.own_medi_code"/>
  <item name="保険コード02" len="3" value="$BLANK"/>
  <item name="保険コード03" len="3" value="$BLANK"/>
  <item name="保険コード04" len="3" value="$BLANK"/>
  <item name="保険コード05" len="3" value="$BLANK"/>
  <item name="加算" len="6" value="$BLANK"/>
  <item name="加算世代番号" len="1" value="$BLANK"/>
  <item name="前体重" len="5" value="const:00000"/>
  <item name="後体重" len="5" value="const:00000"/>
  <item name="心胸比" len="4" value="const:0000"/>
  <item name="心電図" len="6" value="$BLANK"/>
  <item name="ＤＷ" len="4" value="const:0000"/>
  <item name="血液浄化法" len="6" value="dataset:-600304.treatment_cd_coop"/>
  <item name="血液浄化法世代番号" len="1" value="const:0"/>
  <item name="指示オーダ番号" len="16" value="dataset:-600303.ind_ord_no"/>
  <item name="血液浄化法　医事コード" len="6" value="$BLANK"/>
  <item name="血液浄化法 医事世代コード" len="1" value="$BLANK"/>
  <item name="更新端末" len="10" value="dataset:-102.update_terminal"/>
  <item name="更新者" len="10" value="dataset:-600017.disp_user_id"/>
  <item name="更新者世代番号" len="1" value="const:0"/>
  <item name="予備" len="30" value="$BLANK"/>
</root>
', '{"dataset": [{"patId": "patId", "sqlCode": -600001}, {"crud": "C", "key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "patId": "patId", "sqlCode": -102, "facilityCd": "facilityCd", "coopVersion": "coopVersion", "messageType": "2"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -11, "facilityCd": "facilityCd"}, {"key0": "key0", "ctlNo": "ctlNo", "ordNo": "ordNo", "sqlCode": -600303, "facilityCd": "facilityCd"}, {"key0": "key0", "ordNo": "ordNo", "sqlCode": -600304, "facilityCd": "facilityCd"}, {"key0": "key0", "sqlCode": -600020, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"key0": "key0", "sqlCode": -600021, "facilityCd": "facilityCd", "is_zero_end": "true"}, {"ctlNo": "ctlNo", "sqlCode": -600017}]}'::jsonb, '1', '1', 4, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'HR');