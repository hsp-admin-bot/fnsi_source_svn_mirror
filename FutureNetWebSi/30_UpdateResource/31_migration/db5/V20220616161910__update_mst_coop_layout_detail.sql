DELETE FROM "ntss"."mst_coop_layout_detail" WHERE ctl_no in (-103000005,-103000006);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000005, 'nkknkk', 'profile', 'R', '詳細項目', '患者フリーコメント', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="11" SEQ="col:$journal.detail.pat_main_3.pat_memo_info.ctl_no" info="患者フリーコメント">
  <Item Code="col:$journal.detail.pat_main_3.pat_memo_info.code">col:$journal.detail.pat_main_3.pat_memo_info.title</Item>
  <Contents>col:$journal.detail.pat_main_3.pat_memo_info.content</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999',CURRENT_TIMESTAMP);
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000006, 'nkknkk', 'profile', 'R', '詳細項目', '患者メモ', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="10" SEQ="" info="患者メモ">
  <Item Code="">col:$journal.detail.pat_main_6.pat_memo_info.title</Item>
  <Contents>col:$journal.detail.pat_main_6.pat_memo_info.content</Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999',CURRENT_TIMESTAMP);