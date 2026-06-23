delete from "mst_coop_layout_detail" where "ctl_no" in (-501000002,-501000003,-501000004,-502000001);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-501000002, 'S_hosp', 'ord_dial', 'R', '風袋情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(風袋情報)">
    <item name="風袋-名称" len="16" col="$journal.detail.ord_main_4.ind_tare_info.name_" type="string"/>
    <item name="風袋-量" len="5" col="$journal.detail.ord_main_4.ind_tare_info.weight_" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', '2019-12-13 09:30:47');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-501000003, 'S_hosp', 'ord_dial', 'R', '除水補正情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(除水補正情報)">
    <item name="除水補正-名称" len="16" col="$journal.detail.ord_main_3.ind_off_water_info.name_" type="string"/>
    <item name="除水補正-量" len="5" col="$journal.detail.ord_main_3.ind_off_water_info.weight_" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', '2019-12-13 09:30:47');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-501000004, 'S_hosp', 'ord_dial', 'R', '処方情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(処方情報)">
    <item name="薬剤-コード" len="10" col="$journal.detail.ord_main_2.ind_medi_info.cd" type="string"/>
    <item name="薬剤-名称" len="80" col="$journal.detail.ord_main_2.ind_medi_info.name" type="string"/>
    <item name="薬剤-数量" len="7" col="$journal.detail.ord_main_2.ind_medi_info.amount" type="string"/>
    <item name="薬剤-単位" len="20" col="$journal.detail.ord_main_2.ind_medi_info.unit" type="string"/>
    <item name="服用-コード" len="10" col="$journal.detail.ord_main_2.ind_medi_info.procedure_cd" type="string"/>
    <item name="服用-名称" len="80" col="$journal.detail.ord_main_2.ind_medi_info.procedure_name" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 09:30:47', '2019-12-13 09:30:47');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-502000001, 'S_hosp', 'ord_dial', 'R', '消耗品情報', 'all', 'SSI_透析オーダ受け連携', '透析オーダ受信', '1', '<root name="透析オーダ受け(消耗品情報)">
    <item  name="消耗品-コード" len="10" col="$journal.detail.ord_main_1.ind_equip_info.cd" type="string"/>
    <item  name="消耗品-名称" len="40" col="$journal.detail.ord_main_1.ind_equip_info.name" type="string"/>
    <item  name="消耗品-数量" len="3" col="$journal.detail.ord_main_1.ind_equip_info.amount" type="string"/>
</root>', '{}', '1', '0', -1, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
