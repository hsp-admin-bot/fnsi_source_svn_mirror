DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no IN (-203000001);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-203000001, 'F_hosp', 'profile', 'R', '患者プロファイル詳細', 'pre', '富士通想定患者プロファイル患者プロファイル項目', '患者プロファイル項目', '1', '<root name="患者プロファイル詳細(pre)">
    <item  name="患者プロファイル項目属性" len="5" key="項目属性" type="string"/>
    <item  name="患者プロファイル項目ＩＤ" len="30" type="string"/>
    <item  name="患者プロファイル項目名称" len="50" type="string"/>
    <item  name="患者プロファイルタイプ・アイテム" len="1060" type="string"/>
    <item  name="患者プロファイル更新利用者ＩＤ" len="8" type="string"/>
    <item  name="患者プロファイル更新日" len="8" type="string"/>
    <item  name="患者プロファイル更新時間" len="6" type="string"/>
</root>', '{"key": {"項目属性": {"all": "項目属性詳細"}}}', '1', '0', 4126, '2019-12-23 07:03:12', CURRENT_TIMESTAMP);
