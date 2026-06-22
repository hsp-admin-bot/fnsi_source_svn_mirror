DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no in (-407000038);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000038, 'P_hosp', 'rst_dial', 'S', 'examination_units', '01', '検査情報(Order_Units)', '検査情報のOrder_Unitsタグを出力します。', '1', '<root>
  <Order_Units Order_UnitsID="dataset:-307073.order_units_id" Application="dataset:-307073.application" InputUserCode="dataset:-307073.input_user_code" InputUserName="dataset:-307073.input_user_name" InputTime="dataset:-307073.input_time" LastUpdateTime="dataset:-307073.last_update_time" _detail="test" _sqlCode="-307073" />
</root>
', '{"dataset": [{"key0": "-307137.key0", "ordNo": "-307137.ord_no", "patId": "-307137.pat_id", "sqlCode": -307073, "facilityCd": "-307137.facility_cd"}]}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');