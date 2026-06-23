delete from "mst_coop_layout_detail" where "ctl_no" in (-104000001,-104000002,-104000003,-104000004);
update mst_coop_layout_detail set coop_ext_setting = '{}'  where coop_ext_setting = '[{}]';
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000004, 'nkknkk', 'ind_dial', 'S', '医療材料', 'blank', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="$BLANK"/>
<item  name="医材数量" len="6" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000003, 'nkknkk', 'ind_dial', 'S', '投与薬剤', 'blank', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="$BLANK"/>
<item  name="薬剤数量" len="8" value="$BLANK"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000002, 'nkknkk', 'ind_dial', 'S', '医療材料', '指示医材', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-19.cd1"/>
<item  name="医材数量" len="6" value="dataset:-19.amount"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000001, 'nkknkk', 'ind_dial', 'S', '投与薬剤', '指示薬剤', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-18.medi_cd1"/>
<item  name="薬剤数量" len="8" value="dataset:-18.medi_amount"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="dataset:-18.medi_unit"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
