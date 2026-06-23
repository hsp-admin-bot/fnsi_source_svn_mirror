delete from "mst_coop_layout_detail" where "ctl_no"  = -601000001 or "ctl_no"  = -601000002 or "ctl_no"  = -601000003 or "ctl_no"  = -601000004;INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-601000004, 'C_hosp', 'profile', 'R', '患者連絡先情報', 'その他', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="3">
				<DISP_PATID></DISP_PATID>
				<CTL_NO>col:$journal.detail.pat_personal_main.other_contact_info.ctl_no</CTL_NO>
				<DISP_NO>col:$journal.detail.pat_personal_main.other_contact_info.disp_order</DISP_NO>
				<RELATION>col:$journal.detail.pat_personal_main.other_contact_info.relation_cd</RELATION>
				<NAME>col:$journal.detail.pat_personal_main.other_contact_info.name</NAME>
				<ADDRESS>col:$journal.detail.pat_personal_main.other_contact_info.address</ADDRESS><!-- 住所N -->
				<ZIPCODE>col:$journal.detail.pat_personal_main.other_contact_info.zip_cd</ZIPCODE><!-- 郵便番号N -->
				<TELNO1>col:$journal.detail.pat_personal_main.other_contact_info.tel1</TELNO1><!-- 電話番号N -->
</PAT_CONTACT>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-601000002, 'C_hosp', 'profile', 'R', '患者連絡先情報', '本人', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="1">
				<DISP_PATID></DISP_PATID>
				<CTL_NO></CTL_NO>
				<DISP_NO></DISP_NO>
				<RELATION></RELATION>
				<NAME></NAME>
				<ADDRESS>col:$journal.pat_personal_main.pat_contact_info.address</ADDRESS><!-- 住所N -->
				<ZIPCODE>col:$journal.pat_personal_main.pat_contact_info.zip_cd</ZIPCODE><!-- 郵便番号N -->
				<TELNO1>col:$journal.pat_personal_main.pat_contact_info.tel1</TELNO1><!-- 電話番号N -->
</PAT_CONTACT>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-601000003, 'C_hosp', 'profile', 'R', '患者連絡先情報', '勤務先', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="2">
				<DISP_PATID></DISP_PATID>
				<CTL_NO>col:$journal.detail.pat_personal_main.vendor_contact_info.ctl_no</CTL_NO>
				<DISP_NO>col:$journal.detail.pat_personal_main.vendor_contact_info.disp_order</DISP_NO>
				<RELATION>col:$journal.detail.pat_personal_main.vendor_contact_info.relation_cd</RELATION>
				<NAME>col:$journal.detail.pat_personal_main.vendor_contact_info.name</NAME>
				<ADDRESS>col:$journal.detail.pat_personal_main.vendor_contact_info.address</ADDRESS><!-- 住所N -->
				<ZIPCODE>col:$journal.detail.pat_personal_main.vendor_contact_info.zip_cd</ZIPCODE><!-- 郵便番号N -->
				<TELNO1>col:$journal.detail.pat_personal_main.vendor_contact_info.worker_tel</TELNO1><!-- 電話番号N -->
</PAT_CONTACT>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
INSERT INTO "mst_coop_layout_detail"("ctl_no", "facility_cd", "coop_cd", "direction", "coop_cd_detail", "coop_cd_detail_sub", "coop_name", "description", "is_editable", "coop_setting", "coop_ext_setting", "is_disp", "is_del", "user_id", "reg_date", "up_date") VALUES (-601000001, 'C_hosp', 'profile', 'R', '患者感染症情報', 'all', 'CSI', '患者情報（XML)', '1', '<PAT_INFECT ID="">
				<DISP_PATID></DISP_PATID>
				<INFECTION_CD>col:$journal.detail.pat_main.infect_info.infection_cd</INFECTION_CD><!-- 患者感染症情報:感染症コードN -->
				<INFECT>col:$journal.detail.pat_main.infect_info.infect</INFECT><!-- 患者感染症情報:結果コードN -->
</PAT_INFECT>', '{}', '1', '0', 4126, '2019-12-23 07:03:12', '2019-12-23 07:03:12');
