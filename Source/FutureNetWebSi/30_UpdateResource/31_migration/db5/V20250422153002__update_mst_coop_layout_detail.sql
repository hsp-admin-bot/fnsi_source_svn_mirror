DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no=-407000011;

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-407000011, 'P_hosp', 'rst_dial', 'S', 'treatment', '01', '酸素情報 Orderタグ', '酸素情報 Orderタグ', '1', '<root>
              <Order Code="dataset:-307127.code" Name="dataset:-307127.name" Count="dataset:-307127.count" Unit="dataset:-307127.unit" Cutoff="dataset:-307127.cutoff" SeqNo="dataset:-307127.seq_no" _sqlCode="-307127"/>
              <Order_Administration/>
              <OrderUnits_Memo/>
</root>
', '{"dataset": [{"key0": "-307130.key0", "ordNo": "-307130.ord_no", "sqlCode": -307127, "facilityCd": "-307130.facility_cd"}]}'::jsonb, '1', '0', 5843, current_timestamp, current_timestamp, 'MED');