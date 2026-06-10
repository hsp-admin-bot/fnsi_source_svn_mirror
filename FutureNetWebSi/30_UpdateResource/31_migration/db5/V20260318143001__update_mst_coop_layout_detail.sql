DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000037;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000039;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000043;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1104000045;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000031;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000033;
DELETE FROM ntss.mst_coop_layout_detail WHERE ctl_no=-1107000037;

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000037, 'Secom', 'ind_dial', 'S', 'inj_unit_top_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_実施単位_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_実施単位">
<record name="セコム連携_透析指示_注射依頼ファイル_実施単位" detail="inj_unit_del" sqlCode="-1102003" />
</root>', '{"dataset": [{"crud": "del", "key0": "-1102023.key0", "time": "dummy", "ctlNo": "-1102023.ctl_no", "ordNo": "-1102023.ord_no", "patId": "-1102023.pat_id", "coopCd": "ind_dial", "sqlCode": -1102003, "facilityCd": "-1102023.facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000039, 'Secom', 'ind_dial', 'S', 'inj_item_top_del', '02', 'セコム連携_透析指示連携', '注射依頼ファイル_処置項目_del', '1', '<root name="セコム連携_透析指示_注射依頼ファイル_処置項目">
<record name="セコム連携_透析指示_注射依頼ファイル_処置項目" detail="inj_item_del" sqlCode="-1102011" />
</root>', '{"dataset": [{"crud": "del", "key0": "-1102024.key0", "time": "dummy", "ctlNo": "-1102024.ctl_no", "ordNo": "-1102024.ord_no", "patId": "-1102024.pat_id", "coopCd": "ind_dial", "sqlCode": -1102011, "facilityCd": "-1102024.facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000043, 'Secom', 'ind_dial', 'S', 'trt_unit_top_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置単位_del', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施単位">
<record detail="trt_unit_del" sqlCode="-1102015"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "time": "dummy", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102015, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1104000045, 'Secom', 'ind_dial', 'S', 'trt_item_top_del', '02', 'セコム連携_透析指示連携', '処置依頼ファイル_処置項目_del', '1', '<root name="セコム連携_透析指示_処置依頼ファイル_実施項目">
<record detail="trt_item_del" sqlCode="-1102002"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "time": "dummy", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "ind_dial", "sqlCode": -1102002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000031, 'Secom', 'rst_dial', 'S', 'trt_unit_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置単位_del', '1', '<root name="セコム連携_透析実績_処置実績ファイル_処置単位">
<record detail="trt_unit_del" sqlCode="-1103003"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "time": "dummy", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103003, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000033, 'Secom', 'rst_dial', 'S', 'trt_item_top_del', '02', 'セコム連携_透析実績連携', '処置実績ファイル_処置項目_del', '1', '<root name="セコム連携_透析実績_処置実績ファイル_実施項目">
<record detail="trt_item_del" sqlCode="-1103001"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "time": "dummy", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103001, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');
INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version) VALUES(-1107000037, 'Secom', 'rst_dial', 'S', 'inj_item_top_del', '02', 'セコム連携_透析実績連携', '注射実績ファイル_処置項目_del', '1', '<root name="セコム連携_透析実績_注射実績ファイル_処置項目">
<record name="セコム連携_透析実績_注射実績ファイル_処置項目" detail="inj_item_del" sqlCode="-1103002"/>
</root>
', '{"dataset": [{"crud": "del", "key0": "key0", "rpNo": "-1103011.rp_no", "time": "dummy", "ctlNo": "ctl_no", "ordNo": "ord_no", "patId": "pat_id", "coopCd": "rst_dial", "sqlCode": -1103002, "facilityCd": "facility_cd"}]}'::jsonb, '1', '0', -1, current_timestamp, current_timestamp, 'Secom');