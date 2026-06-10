delete from "mst_coop_layout_detail" where "facility_cd" = 'N_hosp' and "coop_cd" = 'vit_cop';
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000027, 'N_hosp', 'vit_cop', 'S', 'バイタル', 'vital', 'NECバイタル送信', 'バイタル送信', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="dataset:-201.vital_cd"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '0', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000026, 'N_hosp', 'vit_cop', 'S', 'vital', '⊿ＢＶ変化率', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param80"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000025, 'N_hosp', 'vit_cop', 'S', 'vital', '⊿BV', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param17"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000024, 'N_hosp', 'vit_cop', 'S', 'vital', '補液温度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param74"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000023, 'N_hosp', 'vit_cop', 'S', 'vital', '補液量現在値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param72"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000022, 'N_hosp', 'vit_cop', 'S', 'vital', '補液速度設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param73"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000021, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液流量', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param22"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000020, 'N_hosp', 'vit_cop', 'S', 'vital', 'Ｎａ濃度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param20"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000019, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液温度', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param21"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000018, 'N_hosp', 'vit_cop', 'S', 'vital', 'ＩＰ速度設定', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param37"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000017, 'N_hosp', 'vit_cop', 'S', 'vital', 'ＩＰ総量', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param09"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000016, 'N_hosp', 'vit_cop', 'S', 'vital', 'TMP', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param13"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000015, 'N_hosp', 'vit_cop', 'S', 'vital', '透析液圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param12"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000014, 'N_hosp', 'vit_cop', 'S', 'vital', '静脈圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param11"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000013, 'N_hosp', 'vit_cop', 'S', 'vital', '除水目標値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param32"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000012, 'N_hosp', 'vit_cop', 'S', 'vital', '除水積算値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param05"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000011, 'N_hosp', 'vit_cop', 'S', 'vital', '除水速度設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param33"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000010, 'N_hosp', 'vit_cop', 'S', 'vital', '血流量設定値', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param36"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000009, 'N_hosp', 'vit_cop', 'S', 'vital', '治療モード', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param31"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000008, 'N_hosp', 'vit_cop', 'S', 'vital', '経過時間', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:param01"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000007, 'N_hosp', 'vit_cop', 'S', 'vital', '後体重', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:paramaw"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000006, 'N_hosp', 'vit_cop', 'S', 'vital', '前体重', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambw"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000005, 'N_hosp', 'vit_cop', 'S', 'vital', '体温', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:paramte"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000004, 'N_hosp', 'vit_cop', 'S', 'vital', '脈拍', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parampl"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000003, 'N_hosp', 'vit_cop', 'S', 'vital', '最低血圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambl"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000002, 'N_hosp', 'vit_cop', 'S', 'vital', '最高血圧', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32" value="const:parambh"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{}', '1', '1', 4, '2020-05-15 12:01:51.647', '2020-05-15 12:01:55.097');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-316000001, 'N_hosp', 'vit_cop', 'S', 'vital', 'pre', 'NECバイタル送信', 'バイタル送信(★無効設定)', '1', '<root name="バイタル詳細">
    <item  name="バイタル項目コード" len="32"  key="種別" value="dataset:-201.vital_cd"/>
    <item  name="バイタル実施進捗" len="1" value="const:X"/>
    <item  name="測定値" len="100" value="dataset:-201.vital_data"/>
    <item  name="測定日時" len="12" value="dataset:-201.occur_date"/>
    <item  name="操作者コード" len="16" value="$BLANK"/>
    <item  name="更新日" len="14" value="$BLANK"/>
    <item  name="更新端末" len="16" value="$BLANK"/>
    <item  name="更新者コード" len="16" value="$BLANK"/>
    <item  name="操作者所属部署" len="4" value="$BLANK"/>
    <item  name="予備" len="25" value="$BLANK"/>
</root>', '{"key": {"種別": {"01": "経過時間", "05": "除水積算値", "09": "ＩＰ総量", "11": "静脈圧", "12": "透析液圧", "13": "TMP", "17": "⊿BV", "20": "Ｎａ濃度", "21": "透析液温度", "22": "透析液流量", "31": "治療モード", "32": "除水目標値", "33": "除水速度設定値", "36": "血流量設定値", "37": "ＩＰ速度設定", "72": "補液量現在値", "73": "補液速度設定値", "74": "補液温度", "80": "⊿ＢＶ変化率", "aw": "後体重", "bh": "最高血圧", "bl": "最低血圧", "bw": "前体重", "pl": "脈拍", "te": "体温"}}}', '1', '1', 4, '2020-05-15 12:01:38.83', '2020-05-15 12:01:42.503');
