-- 投薬情報
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000001;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000002;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000003;
DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000004;


INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000001, 'P_hosp', 'rst_dial', 'S', 'medicine', '01', '投薬内服繰り返し', '投薬内服繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
</root>
  ', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000002, 'P_hosp', 'rst_dial', 'S', 'medicine', '02', '投薬頓服繰り返し', '投薬頓服繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
  </root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000003, 'P_hosp', 'rst_dial', 'S', 'medicine', '03', '投薬外用繰り返し', '投薬外用繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
  </root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000004, 'P_hosp', 'rst_dial', 'S', 'medicine', '04', '投薬自己注射繰り返し', '投薬自己注射繰り返し', '1', '<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name" Count="dataset:-307009.count" Unit="dataset:-307009.unit" Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" _sqlCode="-307009"/>
  </root>
', '{"dataset": [{"key0": "-307008.key0", "ordNo": "-307008.ord_no", "sqlCode": -307009, "facilityCd": "-307008.facility_cd", "application": "-307008.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');

-- 注射情報
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

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000005, 'P_hosp', 'rst_dial', 'S', 'injection', '01', '静注', '静注', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000006, 'P_hosp', 'rst_dial', 'S', 'injection', '02', '筋注', '筋注', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000007, 'P_hosp', 'rst_dial', 'S', 'injection', '03', '皮内注', '皮内注', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000008, 'P_hosp', 'rst_dial', 'S', 'injection', '04', '皮下注', '皮下注', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000009, 'P_hosp', 'rst_dial', 'S', 'injection', '05', '点滴', '点滴', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000010, 'P_hosp', 'rst_dial', 'S', 'injection', '06', '特注', '特注', '1', '<root>
    <Order Code="dataset:-307017.code" Name="dataset:-307017.name" Count="dataset:-307017.count" Unit="dataset:-307017.unit" Cutoff="dataset:-307017.cutoff" SeqNo="dataset:-307017.seq_no" _sqlCode="-307017"/>
  </root>', '{"dataset": [{"key0": "-307016.key0", "ordNo": "-307016.ord_no", "sqlCode": -307017, "facilityCd": "-307016.facility_cd", "application": "-307016.application"}]}'::jsonb, '1', '0', 5843, '2025-04-14 16:47:34.624', current_timestamp, 'MED');