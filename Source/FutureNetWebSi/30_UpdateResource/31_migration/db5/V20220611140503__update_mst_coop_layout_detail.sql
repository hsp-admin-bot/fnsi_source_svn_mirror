DELETE from ntss.mst_coop_layout_detail where ctl_no= -107000002;
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-107000002, 'nkknkk', 'rst_dial', 'S', '医材', '医材', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-498.item_cd"/>
<item  name="医材数量" len="6" value="dataset:-498.amounttest" padding_format="blank" padding_position="left"/>
</root>', '{}', '1', '0', 4, '2020-04-10 17:24:24.924', CURRENT_TIMESTAMP);
