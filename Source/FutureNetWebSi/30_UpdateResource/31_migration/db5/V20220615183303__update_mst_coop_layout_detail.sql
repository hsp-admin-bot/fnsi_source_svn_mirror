DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no in (-103000004);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000004, 'nkknkk', 'profile', 'R', '詳細項目', '生存情報', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="12" SEQ="" info="生存情報">
  <Item Code="col:$journal.detail.pat_unique_3.medical_hst_info.disease_cd">col:$journal.detail.pat_unique_3.medical_hst_info.name</Item>
  <Contents>col:$journal.pat_personal_main.is_die</Contents>
  <Date>col:$journal.pat_personal_main.die_date</Date>
</DetailInfo>', '{}', '1', '0', -1, '2022-06-15 01:36:18.609', CURRENT_TIMESTAMP);

