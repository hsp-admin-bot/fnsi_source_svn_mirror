delete from "mst_coop_layout" where "ctl_no" = -3160001;
INSERT INTO "mst_coop_layout"("ctl_no", "facility_cd", "coop_cd", "coop_cd_index", "direction", "coop_cd_sub", "coop_format", "coop_name", "coop_vender", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-3160001, 'N_hosp', 'vit_cop', '', 'S', 'cre', 'text', 'NECバイタル送信', 'MEGA', 'バイタル送信', '1', '<root name="バイタル">
    <item  name="メッセージID" len="8" value="const:R-VITAL"/>
    <item  name="種別" len="1" value="const:A"/>
    <item  name="病院コード" len="2" value="const:01"/>
    <item  name="患者ID" len="10" value="$JOURNAL.hosp_pat_id" padding_format="zero" padding_position="left" subMode="R"/>
    <item  name="送信日時" len="14" value="$SYSDATE yyyyMMddHHmmss"/>
    <item  name="予備" len="5" value="$BLANK"/>
    <occ  name="バイタル項目数" len="3" detail="バイタル" sqlCode="-201"/>
</root>', '{"dataset": [{"ordNo": "ordNo", "sqlCode": -201}], "dumpFileName": {"patId": "patId", "sqlCode": -99997}}', '1', '0', 4, '2020-05-15 11:01:33.529', '2020-05-15 11:01:38.737');
