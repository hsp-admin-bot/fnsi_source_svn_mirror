delete from ntss.mst_coop_layout_detail where ctl_no = -407000031;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000031, 'P_hosp', 'rst_dial', 'S', 'test', '01', '検査', '検査', '1', '<root>
  <Order Code="dataset:-307083.code" Name="dataset:-307083.name" Count="dataset:-307083.count" Unit="dataset:-307083.unit" Cutoff="dataset:-307083.cutoff" SeqNo="dataset:-307083.seq_no" _sqlCode="-307083"/>
</root>
', '{"dataset": [{"key0": "-307073.key0", "ordNo": "-307073.ord_no", "sqlCode": -307083, "coopSaveNo": "-307073.coop_save_no", "facilityCd": "-307073.facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'MED');