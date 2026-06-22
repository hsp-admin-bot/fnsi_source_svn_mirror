delete from mst_coop_layout_detail where ctl_no IN (-407000001,-407000002,-407000003,-407000004);

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000001,'P_hosp','rst_dial','S','medicine','01','投薬内服繰り返し','投薬内服繰り返し','1','<root>
    <Order Code="dataset:-307009.code" Name="dataset:-307009.name"
        Count="dataset:-307009.count" Unit="dataset:-307009.unit"
        Cutoff="dataset:-307009.cutoff" SeqNo="dataset:-307009.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307008.ord_no", "key0": "-307008.key0", "facilityCd": "-307008.facility_cd",  "seqNo": "-307008.seq_no", "sqlCode": -307009}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000002,'P_hosp','rst_dial','S','medicine','02','投薬頓服繰り返し','投薬頓服繰り返し','1','<root>
    <Order Code="dataset:-307011.code" Name="dataset:-307011.name"
        Count="dataset:-307011.count" Unit="dataset:-307011.unit"
        Cutoff="dataset:-307011.cutoff" SeqNo="dataset:-307011.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307010.ord_no", "key0": "-307010.key0", "facilityCd": "-307010.facility_cd",  "seqNo": "-307010.seq_no", "sqlCode": -307011}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000003,'P_hosp','rst_dial','S','medicine','03','投薬外用繰り返し','投薬外用繰り返し','1','<root>
    <Order Code="dataset:-307013.code" Name="dataset:-307013.name"
        Count="dataset:-307013.count" Unit="dataset:-307013.unit"
        Cutoff="dataset:-307013.cutoff" SeqNo="dataset:-307013.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307012.ord_no", "key0": "-307012.key0", "facilityCd": "-307012.facility_cd",  "seqNo": "-307012.seq_no", "sqlCode": -307013}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000004,'P_hosp','rst_dial','S','medicine','04','投薬自己注射繰り返し','投薬自己注射繰り返し','1','<root>
    <Order Code="dataset:-307015.code" Name="dataset:-307015.name"
        Count="dataset:-307015.count" Unit="dataset:-307015.unit"
        Cutoff="dataset:-307015.cutoff" SeqNo="dataset:-307015.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307014.ord_no", "key0": "-307014.key0", "facilityCd": "-307014.facility_cd",  "seqNo": "-307014.seq_no", "sqlCode": -307015}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');