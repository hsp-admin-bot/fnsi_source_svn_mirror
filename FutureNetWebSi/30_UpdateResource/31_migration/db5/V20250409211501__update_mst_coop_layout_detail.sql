delete from mst_coop_layout_detail where ctl_no IN (-407000028,-407000032,-407000030);

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000028, 'P_hosp','rst_dial','S','treatment','15','処置・人工腎臓以外','処置・人工腎臓以外','1','<root>
    <Order Code="dataset:-307064.code" Name="dataset:-307064.name"
        Count="dataset:-307064.count" Unit="dataset:-307064.unit"
        Cutoff="dataset:-307064.cutoff" SeqNo="dataset:-307064.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307063.ord_no", "key0": "-307063.key0", "facilityCd": "-307063.facility_cd",  "seqNo": "-307063.seq_no", "sqlCode": -307064}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000032, 'P_hosp','rst_dial','S','treatment','16','処置・人工腎臓以外（導入期加算）','処置・人工腎臓以外（導入期加算）','1','<root>
    <Order Code="dataset:-307066.code" Name="dataset:-307066.name"
        Count="dataset:-307066.count" Unit="dataset:-307066.unit"
        Cutoff="dataset:-307066.cutoff" SeqNo="dataset:-307066.seq_no" />
 </root>','{"dataset": [{"ordNo": "-307065.ord_no", "key0": "-307065.key0", "facilityCd": "-307065.facility_cd",  "seqNo": "-307065.seq_no", "sqlCode": -307066}]}','1','0',-1,'2025-03-28 14:52:05.205',CURRENT_TIMESTAMP,'MED');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-407000030, 'P_hosp','rst_dial','S','surgery','01','手術・麻酔','手術・麻酔','1','<root>
    <Order Code="dataset:-307068.code" Name="dataset:-307068.name"
        Count="dataset:-307068.count" Unit="dataset:-307068.unit"
        Cutoff="dataset:-307068.cutoff" SeqNo="dataset:-307068.seq_no" />
</root>','{"dataset": [{"ordNo": "-307071.ord_no", "key0": "-307071.key0", "facilityCd": "-307071.facility_cd",  "seqNo": "-307071.seq_no", "sqlCode": -307068}]}','1','0',-1,'2023-11-21 23:54:58.443',CURRENT_TIMESTAMP,'MED');