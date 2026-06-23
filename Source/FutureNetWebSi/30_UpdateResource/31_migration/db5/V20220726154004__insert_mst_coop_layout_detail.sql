DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no IN (-107000005, -107000006);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000005, 'nkknkk', 'rst_dial', 'S', '薬剤', '薬剤del', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-503.item_cd"/>
<item  name="薬剤数量" len="8" value="dataset:-503.amount" padding_format="blank" padding_position="left"/>
<item  name="薬剤回数" len="2" value="const:1" padding_format="blank" padding_position="left"/>
<item  name="薬剤単位" len="8" value="dataset:-503.unit"/>
</root>', '{}', '1', '0', -1, '2022-07-22 16:31:59.88', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000006, 'nkknkk', 'rst_dial', 'S', '医材', '医材del', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-504.item_cd"/>
<item  name="医材数量" len="6" value="dataset:-504.amounttest" padding_format="blank" padding_position="left"/>
</root>', '{}', '1', '0', -1, '2022-07-22 16:31:59.88', CURRENT_TIMESTAMP);
