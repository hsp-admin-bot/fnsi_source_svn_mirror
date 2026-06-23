DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no in (-103000007);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000007, 'nkknkk', 'profile', 'R', '詳細項目', '障害者加算', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="9" SEQ="col:$journal.detail.pat_personal_main_1.dial_diff_com_info.ctl_no" info="障害者加算">
  <Item Code="col:$journal.detail.pat_personal_main_1.dial_diff_com_info.dial_diff_cd"></Item>
  <Contents></Contents>
  <Date>col:$journal.detail.pat_personal_main_1.dial_diff_com_info.reg_date</Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999',CURRENT_TIMESTAMP);