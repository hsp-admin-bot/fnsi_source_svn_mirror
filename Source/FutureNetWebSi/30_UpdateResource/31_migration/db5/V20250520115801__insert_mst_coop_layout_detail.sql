delete from mst_coop_layout_detail where ctl_no IN (-11100009,-11100010);

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-11100009, 'Secom','exam_ord','S','検査項目','検査項目','セコム連携_検体検査オーダ連携','検体検査オーダ連携（検体検査オーダファイル_検体検査）','1','<root name="明細詳細(検査項目)">
  <occ name="検査コード" detail="検査項目" sqlCode="-1105002"/>
</root>
','{"dataset": [{"key0": "-1105001.key0", "ordNo": "-1105001.ord_no", "setCnt": "-1105001.set_cnt", "sqlCode": -1105002, "facilityCd": "1105001.facility_cd"}]}','1','0',-1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Secom');

INSERT INTO ntss.mst_coop_layout_detail (ctl_no, facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version) VALUES
	 (-11100010, 'Secom','exam_ord','S','検査項目','01','セコム連携_検体検査オーダ連携','検体検査オーダ連携（検体検査オーダファイル_検体検査）','1','<root name="明細詳細(検査項目)">
  <item name="検査コード" value="dataset:-1105003.item_in_hospital_cd"/>
</root>
','{"dataset": [{"key0": "-1105002.key0", "ordNo": "-1105002.ord_no", "setCnt": "-1105002.set_cnt", "itemCnt": "-1105002.item_cnt", "sqlCode": -1105003, "facilityCd": "1105002.facility_cd"}]}','1','0',-1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'Secom');

