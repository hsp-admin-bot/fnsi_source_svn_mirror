delete from "mst_coop_layout_detail" where "ctl_no" in (-201000001);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-201000001, 'F_hosp', 'ini_dial', 'R', 'ini_dial_meisai', 'pre', '富士通想定透析初回申込-申込詳細', 'For test', '1', '<root name="透析申込詳細(pre)">
    <item  name="明細.項目コード" len="8" type="string"/>
    <item  name="明細.項目属性" len="3" key="項目属性" type="string"/>
    <item  name="明細.項目名称" len="50" type="string"/>
    <item  name="明細.数量" len="11" type="string"/>
    <item  name="明細.選択単位フラグ" len="1" type="string"/>
    <item  name="明細.単位コード" len="3" type="string"/>
    <item  name="明細.単位名称" len="4" type="string"/>
    <item  name="明細.第２単位コード" len="3" type="string"/>
    <item  name="明細.第２単位名称" len="4" type="string"/>
    <item  name="明細.単位換算量" len="11" type="string"/>
</root>', '{"key": {"項目属性": {"all": "ini_dial詳細"}}}', '1', '0', -1, '2019-12-13 06:16:24',CURRENT_TIMESTAMP);

