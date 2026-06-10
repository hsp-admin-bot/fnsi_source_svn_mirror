DELETE from mst_coop_layout_detail where ctl_no= -104000001;
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000001, 'nkknkk', 'ind_dial', 'S', '投与薬剤', '指示薬剤', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-18.medi_cd1"/>
<item  name="薬剤数量" len="8" value="dataset:-18.medi_amount"/>
<item  name="薬剤回数" len="2" value="dataset:-18.medi_back"/>
<item  name="薬剤単位" len="8" value="dataset:-18.medi_unit"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', current_timestamp);