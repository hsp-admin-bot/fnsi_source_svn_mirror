DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no IN (-104000002, -104000006);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000002, 'nkknkk', 'ind_dial', 'S', '医療材料', '指示医材', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-19.cd1"/>
<item  name="医材数量" len="6" value="dataset:-19.amount" padding_format="blank" padding_position="left"/>
</root>', '{}', '1', '0', 4, '2022-07-27 05:43:54.661', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-104000006, 'nkknkk', 'ind_dial', 'S', '医療材料del', '指示医材del', '日機装標準', 'S', '1', '<root name="医材">
<item  name="医材コード" len="8" value="dataset:-191.cd1"/>
<item  name="医材数量" len="6" value="dataset:-191.amount" padding_format="blank" padding_position="left"/>
</root>', '{}', '1', '0', -1, '2022-07-27 05:43:54.664', CURRENT_TIMESTAMP);


