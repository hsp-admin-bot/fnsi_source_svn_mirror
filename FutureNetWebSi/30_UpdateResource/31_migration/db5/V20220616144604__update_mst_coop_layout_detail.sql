DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no in (-103000003);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000003, 'nkknkk', 'profile', 'R', '詳細項目', '搬送区分', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="13" SEQ="" info="搬送区分">
  <Item Code="col:$journal.detail.pat_personal_main_3.transport_cd">col:$journal.detail.pat_personal_main_3.transport_name</Item>
  <Contents></Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', -1, '2022-06-15 12:12:43.449', CURRENT_TIMESTAMP);
