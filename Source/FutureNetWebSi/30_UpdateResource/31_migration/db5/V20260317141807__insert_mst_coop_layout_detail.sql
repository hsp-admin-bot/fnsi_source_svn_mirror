DELETE FROM mst_coop_layout_detail WHERE ctl_no IN 
(-1207100003,-1207100004);

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version)
VALUES (-1207100003,'F_SX','iji_dial','S','医事','医事','SX連携','S','1','<root name="医事">
  <item name="医事明細" len="64" value="dataset:-1202022.data_rec"/>
</root>','{}','1','0',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');

INSERT INTO ntss.mst_coop_layout_detail
(ctl_no,facility_cd,coop_cd,direction,coop_cd_detail,coop_cd_detail_sub,coop_name,description,is_editable,coop_setting,coop_ext_setting,is_disp,is_del,user_id,reg_date,up_date,coop_version)
VALUES (-1207100004,'F_SX','iji_dial','S','医事','blank','SX連携','S','1','<root name="医事">
  <item name="医事明細" len="64" value="$BLANK"/>
</root>','{}','1','0',1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP,'F_SX');
