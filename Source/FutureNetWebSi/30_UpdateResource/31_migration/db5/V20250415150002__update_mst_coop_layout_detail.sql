-- 処置・治療項目 不要レイアウト削除
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000011;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000012;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000013;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000014;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000015;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000016;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000017;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000018;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000019;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000020;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000021;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000022;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000023;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000024;

-- 酸素 不要レイアウト削除
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000025;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000026;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000027;

-- 医学管理科 不要レイアウト削除
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000029;

-- 修正分
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000005;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000006;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000007;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000008;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000009;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000010;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000001;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000002;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000003;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000004;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000030;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000031;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000028;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000032;


INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000005, 'P_hosp', 'rst_dial', 'S', 'injection', '01', '静注', '静注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000006, 'P_hosp', 'rst_dial', 'S', 'injection', '02', '筋注', '筋注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000007, 'P_hosp', 'rst_dial', 'S', 'injection', '03', '皮内注', '皮内注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000008, 'P_hosp', 'rst_dial', 'S', 'injection', '04', '皮下注', '皮下注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000009, 'P_hosp', 'rst_dial', 'S', 'injection', '05', '点滴', '点滴', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000010, 'P_hosp', 'rst_dial', 'S', 'injection', '06', '特注', '特注', '1', '<root>
  <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000001, 'P_hosp', 'rst_dial', 'S', 'medicine', '01', '投薬内服繰り返し', '投薬内服繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000002, 'P_hosp', 'rst_dial', 'S', 'medicine', '02', '投薬頓服繰り返し', '投薬頓服繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000003, 'P_hosp', 'rst_dial', 'S', 'medicine', '03', '投薬外用繰り返し', '投薬外用繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000004, 'P_hosp', 'rst_dial', 'S', 'medicine', '04', '投薬自己注射繰り返し', '投薬自己注射繰り返し', '1', '<root>
  <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000030, 'P_hosp', 'rst_dial', 'S', 'surgery', '01', '手術・麻酔', '手術・麻酔', '1', '<root>
    <Order Code="dataset:-307068.code" Name="dataset:-307068.name" Count="dataset:-307068.count" Unit="dataset:-307068.unit" Cutoff="dataset:-307068.cutoff" SeqNo="dataset:-307068.seq_no" _sqlCode="-307068"/>
    <Order_Administration/>
    <OrderUnits_Memo/>
  </root>', '{"dataset": [{"key0": "-307071.key0", "ordNo": "-307071.ord_no", "sqlCode": -307068, "facilityCd": "-307071.facility_cd", "application": "-307071.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000031, 'P_hosp', 'rst_dial', 'S', 'test', '01', '検査', '検査', '1', '<root>
  <Order Code="dataset:-307083.code" Name="dataset:-307083.name" Count="dataset:-307083.count" Unit="dataset:-307083.unit" Cutoff="dataset:-307083.cutoff" SeqNo="dataset:-307083.seq_no" _sqlCode="-307083"/>
<Order_Administration/>
            <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307073.key0", "ordNo": "-307073.ord_no", "sqlCode": -307083, "coopSaveNo": "-307073.coop_save_no", "facilityCd": "-307073.facility_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000028, 'P_hosp', 'rst_dial', 'S', 'treatment', '15', '処置・人工腎臓以外', '処置・人工腎臓以外', '1', '<root>
  <Order Code="dataset:-307064.code" Name="dataset:-307064.name" Count="dataset:-307064.count" Unit="dataset:-307064.unit" Cutoff="dataset:-307064.cutoff" SeqNo="dataset:-307064.seq_no" _sqlCode="-307064"/>
  <Order_Administration/>
  <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307063.key0", "ordNo": "-307063.ord_no", "sqlCode": -307064, "facilityCd": "-307063.facility_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000032, 'P_hosp', 'rst_dial', 'S', 'treatment', '16', '処置・人工腎臓以外（導入期加算）', '処置・人工腎臓以外（導入期加算）', '1', '<root>
  <Order Code="dataset:-307066.code" Name="dataset:-307066.name" Count="dataset:-307066.count" Unit="dataset:-307066.unit" Cutoff="dataset:-307066.cutoff" SeqNo="dataset:-307066.seq_no" _sqlCode="-307066"/>
  <Order_Administration/>
  <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307065.key0", "ordNo": "-307065.ord_no", "sqlCode": -307066, "facilityCd": "-307065.facility_cd"}]}'::jsonb, '1', '0', 5843, '2025-04-15 13:25:22.305', current_timestamp, 'MED');