DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no in (-407000037, -407000033, -407000034);
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000037, 'P_hosp', 'rst_dial', 'S', 'surgery_units', '01', '手術・麻酔情報(Order_Units)', '手術・麻酔情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307071.order_units_id" Application="dataset:-307071.application" InputUserCode="dataset:-307096.staff_cd" InputUserName="dataset:-307096.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="surgery" _sqlCode="-307071" />
</root>
', '{"dataset": [{"key0": "-307136.key0", "ctlNo": "ctlNo", "ordNo": "-307136.ord_no", "sqlCode": -307071, "facilityCd": "-307136.facility_cd"}, {"ordNo": "-307136.ord_no", "sqlCode": -307093}, {"key0": "-307136.key0", "ordNo": "-307136.ord_no", "patId": "-307136.pat_id", "sqlCode": -307096, "facilityCd": "-307136.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000033, 'P_hosp', 'rst_dial', 'S', 'medicine_units', '01', '投薬情報(Order_Units)', '投薬情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307008.order_units_id" Application="dataset:-307008.application" InputUserCode="dataset:-307094.staff_cd" InputUserName="dataset:-307094.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="medicine" _sqlCode="-307008" />
</root>
', '{"dataset": [{"key0": "-307131.key0", "ctlNo": "ctlNo", "ordNo": "-307131.ord_no", "sqlCode": -307008, "facilityCd": "-307131.facility_cd"}, {"ordNo": "-307131.ord_no", "sqlCode": -307093}, {"key0": "-307131.key0", "ordNo": "-307131.ord_no", "patId": "-307131.pat_id", "sqlCode": -307094, "facilityCd": "-307131.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000034, 'P_hosp', 'rst_dial', 'S', 'injection_units', '01', '注射情報(Order_Units)', '注射情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307016.order_units_id" Application="dataset:-307016.application" InputUserCode="dataset:-307095.staff_cd" InputUserName="dataset:-307095.staff_name" InputTime="dataset:-307093.rst_start_date" LastUpdateTime="dataset:-307093.up_date" _detail="injection" _sqlCode="-307016" />
</root>
', '{"dataset": [{"key0": "-307132.key0", "ctlNo": "ctlNo", "ordNo": "-307132.ord_no", "sqlCode": -307016, "facilityCd": "-307132.facility_cd"}, {"ordNo": "-307132.ord_no", "sqlCode": -307093}, {"key0": "-307132.key0", "ordNo": "-307132.ord_no", "patId": "-307132.pat_id", "sqlCode": -307095, "facilityCd": "-307132.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');