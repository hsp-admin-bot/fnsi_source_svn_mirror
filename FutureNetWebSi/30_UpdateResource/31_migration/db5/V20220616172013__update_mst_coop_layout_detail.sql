delete from mst_coop_layout_detail where ctl_no = -103000002;
INSERT INTO "ntss"."mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-103000002, 'nkknkk', 'profile', 'R', '詳細項目', '重症度', '日機装標準', '患者情報（XML)', '1', '<DetailInfo Function="14" SEQ="" info="重症度">
	<Item Code="col:$journal.detail.pat_personal_main_4.severity_cd">
	col:$journal.detail.pat_personal_main_4.severity_name
  </Item>
  <Contents></Contents>
  <Date></Date>
</DetailInfo>', '{}', '1', '0', 4, '2020-05-21 18:36:58.999',CURRENT_TIMESTAMP);
