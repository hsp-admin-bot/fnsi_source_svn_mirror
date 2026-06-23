DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no IN ('-103000009', '7924', '7925', '7926', '7497');
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (7925, 'nkknkk', 'profile', 'R', '詳細項目', '食物アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="4" SEQ="" info="食物アレルギー">
  <Item Code="col:$journal.detail.pat_main_9.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_9.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_9.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', -1, '2022-07-11 23:36:54.776', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (7926, 'nkknkk', 'profile', 'R', '詳細項目', '造影剤アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="5" SEQ="" info="造影剤アレルギー">
  <Item Code="col:$journal.detail.pat_main_10.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_10.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_10.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', -1, '2022-07-11 23:36:54.776', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000009, 'nkknkk', 'profile', 'R', '詳細項目', 'アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="3" SEQ="" info="アレルギー">
  <Item Code="col:$journal.detail.pat_main_4.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_4.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_4.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (7497, 'nkknkk', 'profile', 'R', '詳細項目', '金属アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="6" SEQ="" info="金属アレルギー">
  <Item Code="col:$journal.detail.pat_main_5.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_5.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_5.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999', CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (7924, 'nkknkk', 'profile', 'R', '詳細項目', 'その他アレルギー', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="7" SEQ="" info="その他アレルギー">
  <Item Code="col:$journal.detail.pat_main_8.taboo_allergy_info.taboo_allergy_cd">col:$journal.detail.pat_main_8.taboo_allergy_info.content</Item>
  <Contents>col:$journal.detail.pat_main_8.taboo_allergy_info.memo</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', -1, '2022-07-11 23:36:54.776', CURRENT_TIMESTAMP);
