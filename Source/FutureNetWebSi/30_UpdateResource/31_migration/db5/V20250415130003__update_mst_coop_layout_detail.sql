DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000030;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000030, 'P_hosp', 'rst_dial', 'S', 'surgery', '01', '手術・麻酔', '手術・麻酔', '1', '<root>
    <Order Code="dataset:-307068.code" Name="dataset:-307068.name" Count="dataset:-307068.count" Unit="dataset:-307068.unit" Cutoff="dataset:-307068.cutoff" SeqNo="dataset:-307068.seq_no" _sqlCode="-307068"/>
    <Order_Administration/>
    <OrderUnits_Memo/>
  </root>', '{"dataset": [{"key0": "-307071.key0", "ordNo": "-307071.ord_no", "sqlCode": -307068, "facilityCd": "-307071.facility_cd", "application": "-307071.application"}]}'::jsonb, '1', '0', 5843, '2025-04-15 11:04:56.269', current_timestamp, 'MED');