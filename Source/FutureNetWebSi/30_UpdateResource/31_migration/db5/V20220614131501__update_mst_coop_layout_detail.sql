DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no in (-107000001);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000001, 'nkknkk', 'rst_dial', 'S', '薬剤', '薬剤', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-497.item_cd"/>
<item  name="薬剤数量" len="8" value="dataset:-497.amount" padding_format="blank" padding_position="left"/>
<item  name="薬剤回数" len="2" value="const:1" padding_format="blank" padding_position="left"/>
<item  name="薬剤単位" len="8" value="dataset:-497.unit"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', CURRENT_TIMESTAMP);