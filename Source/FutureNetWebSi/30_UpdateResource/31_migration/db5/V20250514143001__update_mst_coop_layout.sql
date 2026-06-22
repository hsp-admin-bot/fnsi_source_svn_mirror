DELETE FROM ntss.mst_coop_layout
WHERE ctl_no IN (-4030003,-4030004,-4030005,-4030007);

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030003, 'P_hosp', 'profile', '', 'S', 'cre', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報要求">
    <item  name="ヘッダー部.STX" len="1" value="$STX"/>
    <item  name="ヘッダー部.拡張部" len="2" value="const:00"/>
    <item  name="ヘッダー部.電文区分" len="4" value="const:SRD0"/>
    <item  name="ヘッダー部.ブロック区分" len="3" value="const:E01"/>
    <item  name="ヘッダー部.予備" len="1" value="$BLANK"/>
    <item  name="ヘッダー部.データ区分" len="3" value="const:A61"/>
    <item  name="ヘッダー部.サブ区分" len="1" value="const:0"/>
    <item  name="ヘッダー部.情報種別" len="1" value="const:C"/>
    <item  name="内容部患者コード" len="13" value="$JOURNAL.hosp_pat_id" />
    <item  name="内容部特定情報" len="7" value="$BLANK"/>
    <item  name="内容部予備" len="6" value="$BLANK"/>
    <item  name="ETX" len="1" value="$ETX"/>
</root>', '{}'::jsonb, '1', '0', -1, '2020-01-21 08:29:41.740', CURRENT_TIMESTAMP, 'MED');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030004, 'P_hosp', 'profile', '', 'S', 'upd', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報要求">
    <item  name="ヘッダー部.STX" len="1" value="$STX"/>
    <item  name="ヘッダー部.拡張部" len="2" value="const:00"/>
    <item  name="ヘッダー部.電文区分" len="4" value="const:SRD0"/>
    <item  name="ヘッダー部.ブロック区分" len="3" value="const:E01"/>
    <item  name="ヘッダー部.予備" len="1" value="$BLANK"/>
    <item  name="ヘッダー部.データ区分" len="3" value="const:A61"/>
    <item  name="ヘッダー部.サブ区分" len="1" value="const:0"/>
    <item  name="ヘッダー部.情報種別" len="1" value="const:C"/>
    <item  name="内容部患者コード" len="13" value="$JOURNAL.hosp_pat_id" />
    <item  name="内容部特定情報" len="7" value="$BLANK"/>
    <item  name="内容部予備" len="6" value="$BLANK"/>
    <item  name="ETX" len="1" value="$ETX"/>
</root>', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030005, 'P_hosp', 'profile', '', 'S', 'del', 'text', 'パナソニック 患者プロファイル', 'Medicom', '患者プロファイル', '1', '<root name="患者情報要求">
    <item  name="ヘッダー部.STX" len="1" value="$STX"/>
    <item  name="ヘッダー部.拡張部" len="2" value="const:00"/>
    <item  name="ヘッダー部.電文区分" len="4" value="const:SRD0"/>
    <item  name="ヘッダー部.ブロック区分" len="3" value="const:E01"/>
    <item  name="ヘッダー部.予備" len="1" value="$BLANK"/>
    <item  name="ヘッダー部.データ区分" len="3" value="const:A61"/>
    <item  name="ヘッダー部.サブ区分" len="1" value="const:0"/>
    <item  name="ヘッダー部.情報種別" len="1" value="const:C"/>
    <item  name="内容部患者コード" len="13" value="$JOURNAL.hosp_pat_id" />
    <item  name="内容部特定情報" len="7" value="$BLANK"/>
    <item  name="内容部予備" len="6" value="$BLANK"/>
    <item  name="ETX" len="1" value="$ETX"/>
</root>', '{}'::jsonb, '1', '0', -1, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 'MED');

INSERT INTO ntss.mst_coop_layout
(ctl_no, facility_cd, coop_cd, coop_cd_index, direction, coop_cd_sub, coop_format, coop_name, coop_vender, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-4030007, 'P_hosp', 'profile', 'send_time', 'S', 'cre', 'text', '定時一括送信機能（パナソニック  患者プロファイル用）', 'Medicom', '患者プロファイル(定時)', '1', '<rootnode></rootnode>', '{"dataset": [{"sqlCode": -2400, "facilityCd": "facilityCd", "PreSqlInfoItem": ["@ord_no", "@pat_id"]}]}'::jsonb, '1', '0', -1, '2020-01-21 08:29:41.740', CURRENT_TIMESTAMP, 'MED');
