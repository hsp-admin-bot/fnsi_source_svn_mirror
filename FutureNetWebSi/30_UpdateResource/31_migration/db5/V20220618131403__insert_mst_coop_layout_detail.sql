delete from mst_coop_layout_detail where ctl_no in (-104000008,-104000007,-104000006,-104000005);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000005, 'nkknkk', 'ind_dial', 'S', '投与薬剤del', '指示薬剤del', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-181.medi_cd1"/>
<item  name="薬剤数量" len="8" value="dataset:-181.medi_amount" padding_format="blank" padding_position="left"/>
<item  name="薬剤回数" len="2" value="dataset:-181.medi_back" padding_format="blank" padding_position="left"/>
<item  name="薬剤単位" len="8" value="dataset:-181.medi_unit"/>
</root>', '{}', '1', '0', -1, '2022-06-17 07:04:41.07', '2022-06-17 07:04:41.07');
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000006, 'nkknkk', 'ind_dial', 'S', '医療材料del', '指示医材del', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-191.cd1"/>
<item  name="医材数量" len="6" value="dataset:-191.amount"/>
</root>', '{}', '1', '0', -1, '2022-06-17 07:04:41.07', '2022-06-17 07:04:41.07');
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000007, 'nkknkk', 'ind_dial', 'S', '投与薬剤del', 'blank', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="$BLANK"/>
<item  name="薬剤数量" len="8" value="$BLANK"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="$BLANK"/>
</root>', '{}', '1', '0', -1, '2022-06-17 07:04:41.07', '2022-06-17 07:04:41.07');
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000008, 'nkknkk', 'ind_dial', 'S', '医療材料del', 'blank', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="$BLANK"/>
<item  name="医材数量" len="6" value="$BLANK"/>
</root>', '{}', '1', '0', -1, '2022-06-17 07:04:41.07', '2022-06-17 07:04:41.07');
