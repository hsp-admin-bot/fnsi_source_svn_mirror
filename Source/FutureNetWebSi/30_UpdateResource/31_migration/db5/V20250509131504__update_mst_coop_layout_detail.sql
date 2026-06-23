DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-407000001, -407000002, -407000003, -407000004, -407000005, -407000006, -407000007, -407000008, -407000009, -407000010, -407000011, -407000028, -407000030, -407000031, -407000032, -407000033, -407000034, -407000035, -407000036, -407000037, -407000038, -407000039, -407000040);

INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000001, 'P_hosp', 'rst_dial', 'S', 'medicine', '01', '投薬内服繰り返し', '投薬内服繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000002, 'P_hosp', 'rst_dial', 'S', 'medicine', '02', '投薬頓服繰り返し', '投薬頓服繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000003, 'P_hosp', 'rst_dial', 'S', 'medicine', '03', '投薬外用繰り返し', '投薬外用繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000004, 'P_hosp', 'rst_dial', 'S', 'medicine', '04', '投薬自己注射繰り返し', '投薬自己注射繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000005, 'P_hosp', 'rst_dial', 'S', 'injection', '01', '静注', '静注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000006, 'P_hosp', 'rst_dial', 'S', 'injection', '02', '筋注', '筋注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000007, 'P_hosp', 'rst_dial', 'S', 'injection', '03', '皮内注', '皮内注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000008, 'P_hosp', 'rst_dial', 'S', 'injection', '04', '皮下注', '皮下注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000009, 'P_hosp', 'rst_dial', 'S', 'injection', '05', '点滴', '点滴', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000010, 'P_hosp', 'rst_dial', 'S', 'injection', '06', '特注', '特注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000011, 'P_hosp', 'rst_dial', 'S', 'treatment', '01', '酸素情報 Orderタグ', '酸素情報 Orderタグ', '1', '<root>
              <Order Code="dataset:-307127.code" Name="dataset:-307127.name" Count="dataset:-307127.count" Unit="dataset:-307127.unit" Cutoff="dataset:-307127.cutoff" SeqNo="dataset:-307127.seq_no" _sqlCode="-307127"/>
              <Order_Administration/>
              <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307130.key0", "ordNo": "-307130.ord_no", "sqlCode": -307127, "facilityCd": "-307130.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000028, 'P_hosp', 'rst_dial', 'S', 'treatment', '15', '処置・人工腎臓以外', '処置・人工腎臓以外', '1', '<root>
  <Order Code="dataset:-307064.code" Name="dataset:-307064.name" Count="dataset:-307064.count" Unit="dataset:-307064.unit" Cutoff="dataset:-307064.cutoff" SeqNo="dataset:-307064.seq_no" _sqlCode="-307064"/>
  <Order_Administration/>
  <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307063.key0", "ordNo": "-307063.ord_no", "sqlCode": -307064, "facilityCd": "-307063.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000030, 'P_hosp', 'rst_dial', 'S', 'surgery', '01', '手術・麻酔', '手術・麻酔', '1', '<root>
    <Order Code="dataset:-307068.code" Name="dataset:-307068.name" Count="dataset:-307068.count" Unit="dataset:-307068.unit" Cutoff="dataset:-307068.cutoff" SeqNo="dataset:-307068.seq_no" _sqlCode="-307068"/>
    <Order_Administration/>
    <OrderUnits_Memo/>
  </root>', '{"dataset": [{"key0": "-307071.key0", "ordNo": "-307071.ord_no", "sqlCode": -307068, "facilityCd": "-307071.facility_cd", "application": "-307071.application"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000031, 'P_hosp', 'rst_dial', 'S', 'test', '01', '検査', '検査', '1', '<root>
  <Order Code="dataset:-307083.code" Name="dataset:-307083.name" Count="dataset:-307083.count" Unit="dataset:-307083.unit" Cutoff="dataset:-307083.cutoff" SeqNo="dataset:-307083.seq_no" _sqlCode="-307083"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307073.key0", "ordNo": "-307073.ord_no", "sqlCode": -307083, "coopSaveNo": "-307073.coop_save_no", "facilityCd": "-307073.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000032, 'P_hosp', 'rst_dial', 'S', 'treatment', '16', '処置・人工腎臓以外（導入期加算）', '処置・人工腎臓以外（導入期加算）', '1', '<root>
  <Order Code="dataset:-307066.code" Name="dataset:-307066.name" Count="dataset:-307066.count" Unit="dataset:-307066.unit" Cutoff="dataset:-307066.cutoff" SeqNo="dataset:-307066.seq_no" _sqlCode="-307066"/>
  <Order_Administration/>
  <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307065.key0", "ordNo": "-307065.ord_no", "sqlCode": -307066, "facilityCd": "-307065.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000033, 'P_hosp', 'rst_dial', 'S', 'medicine_units', '01', '投薬情報(Order_Units)', '投薬情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307008.order_units_id" Application="dataset:-307008.application" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307008" />
</root>
', '{"dataset": [{"key0": "-307131.key0", "ordNo": "-307131.ord_no", "sqlCode": -307008, "facilityCd": "-307131.facility_cd"}, {"ordNo": "-307131.ord_no", "sqlCode": -307093}, {"key0": "-307131.key0", "ordNo": "-307131.ord_no", "patId": "-307131.pat_id", "sqlCode": -307094, "facilityCd": "-307131.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000034, 'P_hosp', 'rst_dial', 'S', 'injection_units', '01', '注射情報(Order_Units)', '注射情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307016.order_units_id" Application="dataset:-307016.application" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307016" />
</root>
', '{"dataset": [{"key0": "-307132.key0", "ordNo": "-307132.ord_no", "sqlCode": -307016, "facilityCd": "-307132.facility_cd"}, {"ordNo": "-307132.ord_no", "sqlCode": -307093}, {"key0": "-307132.key0", "ordNo": "-307132.ord_no", "patId": "-307132.pat_id", "sqlCode": -307095, "facilityCd": "-307132.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000035, 'P_hosp', 'rst_dial', 'S', 'holiday_units', '01', '処置・人工腎臓以外(夜間・休日加算)情報(Order_Units)', '処置・人工腎臓以外(夜間・休日加算)情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_holi" Application="dataset:-307086.prescription_details_holiday" InputUserCode="dataset:-307099.staff_cd" InputUserName="dataset:-307099.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307063" />
</root>
', '{"dataset": [{"key0": "-307134.key0", "ordNo": "-307134.ord_no", "sqlCode": -307063, "facilityCd": "-307134.facility_cd"}, {"ordNo": "-307134.ord_no", "sqlCode": -307093}, {"key0": "-307134.key0", "ordNo": "-307134.ord_no", "patId": "-307134.pat_id", "sqlCode": -307099, "facilityCd": "-307134.facility_cd"}, {"key0": "-307134.key0", "ordNo": "-307134.ord_no", "sqlCode": -307086, "facilityCd": "-307134.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000036, 'P_hosp', 'rst_dial', 'S', 'dialysis_units', '01', '処置・人工腎臓以外(導入期加算)情報(Order_Units)', '処置・人工腎臓以外(導入期加算)情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307086.order_units_id_rece_dial" Application="dataset:-307086.prescription_details_dialysis" InputUserCode="dataset:-307101.staff_cd" InputUserName="dataset:-307101.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307065" />
</root>
', '{"dataset": [{"key0": "-307135.key0", "ordNo": "-307135.ord_no", "sqlCode": -307065, "facilityCd": "-307135.facility_cd"}, {"ordNo": "-307135.ord_no", "sqlCode": -307093}, {"key0": "-307135.key0", "ordNo": "-307135.ord_no", "sqlCode": -307086, "facilityCd": "-307135.facility_cd"}, {"key0": "-307135.key0", "ordNo": "-307135.ord_no", "patId": "-307135.pat_id", "sqlCode": -307101, "facilityCd": "-307135.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000037, 'P_hosp', 'rst_dial', 'S', 'surgery_units', '01', '手術・麻酔情報(Order_Units)', '手術・麻酔情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307071.order_units_id" Application="dataset:-307071.application" InputUserCode="dataset:-307096.staff_cd" InputUserName="dataset:-307096.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="surgery" _sqlCode="-307071" />
</root>
', '{"dataset": [{"key0": "-307136.key0", "ordNo": "-307136.ord_no", "sqlCode": -307071, "facilityCd": "-307136.facility_cd"}, {"ordNo": "-307136.ord_no", "sqlCode": -307093}, {"key0": "-307136.key0", "ordNo": "-307136.ord_no", "patId": "-307136.pat_id", "sqlCode": -307096, "facilityCd": "-307136.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000038, 'P_hosp', 'rst_dial', 'S', 'examination_units', '01', '検査情報(Order_Units)', '検査情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307073.order_units_id" Application="dataset:-307073.application" InputUserCode="dataset:-307073.input_user_code" InputUserName="dataset:-307073.input_user_name" InputTime="dataset:-307073.input_time" LastUpdateTime="dataset:-307073.last_update_time" _detail="test" _sqlCode="-307073" />
</root>
', '{"dataset": [{"key0": "-307137.key0", "ordNo": "-307137.ord_no", "patId": "-307137.patId", "sqlCode": -307073, "facilityCd": "-307137.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000039, 'P_hosp', 'rst_dial', 'S', 'treatment', '02', '処置・治療項目情報(Order)', '処置・治療項目情報のOrderタグを出力します。', '1', '<root>
              <Order Code="dataset:-307074.code" Name="dataset:-307074.name" Count="dataset:-307074.count" Unit="dataset:-307074.unit" Cutoff="dataset:-307074.cutoff" SeqNo="dataset:-307074.seq_no" _sqlCode="-307074"/>
              <Order_Administration/>
              <OrderUnits_Memo>dataset:-307076.order_units_memo</OrderUnits_Memo>
</root>
', '{"dataset": [{"key0": "-307138.key0", "ordNo": "-307138.ord_no", "patId": "-307138.pat_id", "sqlCode": -307074, "facilityCd": "-307138.facility_cd"}, {"key0": "-307138.key0", "ordNo": "-307138.ord_no", "patId": "-307138.pat_id", "sqlCode": -307076, "facilityCd": "-307138.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000040, 'P_hosp', 'rst_dial', 'S', 'treatment_units', '01', '処置・治療項目情報(Order_Units)', '処置・治療項目情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307086.order_units_id_treatment" Application="dataset:-307086.prescription_details_treatment" InputUserCode="dataset:-307098.staff_cd" InputUserName="dataset:-307098.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307138" />
            <Order_Units Order_UnitsID="dataset:-307086.order_units_id_oxygen" Application="dataset:-307086.prescription_details_oxygen" InputUserCode="dataset:-307097.staff_cd" InputUserName="dataset:-307097.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="treatment" _sqlCode="-307130" />
</root>
', '{"dataset": [{"key0": "-307133.key0", "ordNo": "-307133.ord_no", "sqlCode": -307086, "facilityCd": "-307133.facility_cd"}, {"ordNo": "-307133.ord_no", "sqlCode": -307093}, {"key0": "-307133.key0", "ordNo": "-307133.ord_no", "patId": "-307133.pat_id", "sqlCode": -307097, "facilityCd": "-307133.facility_cd"}, {"key0": "-307133.key0", "ordNo": "-307133.ord_no", "patId": "-307133.pat_id", "sqlCode": -307098, "facilityCd": "-307133.facility_cd"}, {"key0": "-307133.key0", "ordNo": "-307133.ord_no", "patId": "-307133.pat_id", "sqlCode": -307138, "facilityCd": "-307133.facility_cd"}, {"key0": "-307133.key0", "ordNo": "-307133.ord_no", "sqlCode": -307130, "facilityCd": "-307133.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');