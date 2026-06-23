delete from "mst_coop_layout_detail" where "ctl_no" in (-210000001,-210000002,-210000003);
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-210000001, 'F_hosp', 'exam_ord', 'S', '検査項目', '検査項目', '富士通検査依頼', '依頼送信', '1', '<root name="明細詳細(検査項目)">
    <item  name="明細.項目コード" len="8" value="dataset:-25.in_hospital_cd1"/>
    <item  name="明細.項目属性" len="3" value="dataset:-25.sbt_cd1"/>
    <item  name="明細.項目名称" len="50" value="dataset:-25.item_name"/>
    <item  name="明細.数量" len="11" value="const:0000000.000"/>
    <item  name="明細.選択単位フラグ" len="1" value="const:0"/>
    <item  name="明細.単位コード" len="3" value="$BLANK"/>
    <item  name="明細.単位名称" len="4" value="$BLANK"/>
    <item  name="明細.第２単位コード" len="3" value="$BLANK"/>
    <item  name="明細.第２単位名称" len="4" value="$BLANK"/>
    <item  name="明細.単位換算量" len="11" value="const:0000000.000"/>
    <item  name="明細.タグ名称" len="20" value="dataset:-25.tag_name"/>
</root>', '{}', '1', '0', 4, '2019-12-13 06:16:24', '2019-12-13 06:16:24');
