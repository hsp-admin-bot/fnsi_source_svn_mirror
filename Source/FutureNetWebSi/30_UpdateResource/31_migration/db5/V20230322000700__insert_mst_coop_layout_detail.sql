delete from "mst_coop_layout_detail" where "ctl_no" in (66661,
66662);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (66661, 'F_hosp', 'phy_ord', 'S', '透析心電図詳細del', '検査項目', '透析心電図', '透析心電図', '1', '<root name="明細詳細(透析心電図)">
    <item  name="明細.項目コード" len="8" value="dataset:-66671.in_hospital_cd1"/>
    <item  name="明細.項目属性" len="3" value="dataset:-66671.sbt_cd1"/>
    <item  name="明細.項目名称" len="50" value="dataset:-66671.item_name"/>
    <item  name="明細.数量" len="11" value="const:0000000.000"/>
    <item  name="明細.選択単位フラグ" len="1" value="const:0"/>
    <item  name="明細.単位コード" len="3" value="$BLANK"/>
    <item  name="明細.単位名称" len="4" value="$BLANK"/>
    <item  name="明細.第２単位コード" len="3" value="$BLANK"/>
    <item  name="明細.第２単位名称" len="4" value="$BLANK"/>
    <item  name="明細.単位換算量" len="11" value="const:0000000.000"/>
    <item  name="明細.タグ名称" len="20" value="dataset:-66671.tag_name"/>
</root>', '{}', '1', '0', -1,CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, 'gx002');
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date", "coop_version") VALUES (66662, 'F_hosp', 'phy_ord', 'S', '透析心電図詳細', '検査項目', '透析心電図', '透析心電図', '1', '<root name="明細詳細(透析心電図)">
    <item  name="明細.項目コード" len="8" value="dataset:-66670.in_hospital_cd1"/>
    <item  name="明細.項目属性" len="3" value="dataset:-66670.sbt_cd1"/>
    <item  name="明細.項目名称" len="50" value="dataset:-66670.item_name"/>
    <item  name="明細.数量" len="11" value="const:0000000.000"/>
    <item  name="明細.選択単位フラグ" len="1" value="const:0"/>
    <item  name="明細.単位コード" len="3" value="$BLANK"/>
    <item  name="明細.単位名称" len="4" value="$BLANK"/>
    <item  name="明細.第２単位コード" len="3" value="$BLANK"/>
    <item  name="明細.第２単位名称" len="4" value="$BLANK"/>
    <item  name="明細.単位換算量" len="11" value="const:0000000.000"/>
    <item  name="明細.タグ名称" len="20" value="dataset:-66670.tag_name"/>
</root>', '{}', '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'gx002');
