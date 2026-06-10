delete from "mst_coop_layout_detail" where "ctl_no" in (-107000004,-107000003,-107000002,-107000001);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000004, 'nkknkk', 'rst_dial', 'S', '医材', 'blank', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="$BLANK"/>
<item  name="医材数量" len="6" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000003, 'nkknkk', 'rst_dial', 'S', '薬剤', 'blank', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="$BLANK"/>
<item  name="薬剤数量" len="8" value="$BLANK"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000002, 'nkknkk', 'rst_dial', 'S', '医材', '医材', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-494.item_cd"/>
<item  name="医材数量" len="6" value="dataset:-494.amount"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000001, 'nkknkk', 'rst_dial', 'S', '薬剤', '薬剤', '日機装標準', 'S', '1', '<root name="薬剤">
<item  name="薬剤コード" len="8" value="dataset:-495.item_cd"/>
<item  name="薬剤数量" len="8" value="dataset:-495.amount"/>
<item  name="薬剤回数" len="2" value="$BLANK"/>
<item  name="薬剤単位" len="8" value="dataset:-495.unit"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', '2020-04-10 17:24:28.151');
