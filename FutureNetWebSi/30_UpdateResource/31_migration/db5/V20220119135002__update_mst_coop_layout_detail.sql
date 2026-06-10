delete from "mst_coop_layout_detail" where "ctl_no" in (-211000001,-211000002,-211000003);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-211000001, 'F_hosp', 'rad_ord', 'S', '撮影項目', '撮影項目', '富士通撮影依頼', '依頼送信', '1', '<root name="明細詳細(撮影項目)">
    <item  name="明細.項目コード" len="8" value="dataset:-27.in_hospital_cd1"/>
    <item  name="明細.項目属性" len="3" value="dataset:-27.sbt_cd1"/>
    <item  name="明細.項目名称" len="50" value="dataset:-27.item_name"/>
    <item  name="明細.数量" len="11" value="const:0000000.000"/>
    <item  name="明細.選択単位フラグ" len="1" value="const:0"/>
    <item  name="明細.単位コード" len="3" value="$BLANK"/>
    <item  name="明細.単位名称" len="4" value="$BLANK"/>
    <item  name="明細.第２単位コード" len="3" value="$BLANK"/>
    <item  name="明細.第２単位名称" len="4" value="$BLANK"/>
    <item  name="明細.単位換算量" len="11" value="const:0000000.000"/>
    <item  name="明細.タグ名称" len="20" value="dataset:-27.tag_name"/>
</root>', '{}', '1', '0', 4, '2022-01-14 18:29:49', '2022-01-14 18:29:49');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-211000002, 'F_hosp', 'rad_ord', 'S', '撮影項目_削除', '撮影項目', '富士通撮影依頼', '依頼送信', '1', '<root name="明細詳細(撮影項目)">
    <item  name="明細.項目コード" len="8" value="dataset:-46.in_hospital_cd1"/>
    <item  name="明細.項目属性" len="3" value="dataset:-46.sbt_cd1"/>
    <item  name="明細.項目名称" len="50" value="dataset:-46.item_name"/>
    <item  name="明細.数量" len="11" value="const:0000000.000"/>
    <item  name="明細.選択単位フラグ" len="1" value="const:0"/>
    <item  name="明細.単位コード" len="3" value="$BLANK"/>
    <item  name="明細.単位名称" len="4" value="$BLANK"/>
    <item  name="明細.第２単位コード" len="3" value="$BLANK"/>
    <item  name="明細.第２単位名称" len="4" value="$BLANK"/>
    <item  name="明細.単位換算量" len="11" value="const:0000000.000"/>
    <item  name="明細.タグ名称" len="20" value="dataset:-46.tag_name"/>
</root>', '{}', '1', '0', 4, '2022-01-14 18:29:49', '2022-01-14 18:29:49');
