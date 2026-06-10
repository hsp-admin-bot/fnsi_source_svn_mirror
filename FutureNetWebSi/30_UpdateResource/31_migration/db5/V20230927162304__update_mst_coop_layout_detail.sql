DELETE FROM ntss.mst_coop_layout_detail
WHERE ctl_no IN (-601000001,-601000002,-601000003,-601000004,-606000001)
;


INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-601000003, 'C_hosp', 'profile', 'R', '患者連絡先情報', '勤務先', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="2">
				<DISP_PATID></DISP_PATID>
				<CTL_NO>col:$journal.detail.pat_personal_main.vendor_contact_info.ctl_no</CTL_NO>
				<DISP_NO>col:$journal.detail.pat_personal_main.vendor_contact_info.disp_order</DISP_NO>
				<RELATION>col:$journal.detail.pat_personal_main.vendor_contact_info.relation_cd</RELATION>
				<NAME>col:$journal.detail.pat_personal_main.vendor_contact_info.name</NAME>
				<ADDRESS>col:$journal.detail.pat_personal_main.vendor_contact_info.address</ADDRESS><!-- 住所N -->
				<ZIPCODE>col:$journal.detail.pat_personal_main.vendor_contact_info.zip_cd</ZIPCODE><!-- 郵便番号N -->
				<TELNO1>col:$journal.detail.pat_personal_main.vendor_contact_info.worker_tel</TELNO1><!-- 電話番号N -->
</PAT_CONTACT>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-601000002, 'C_hosp', 'profile', 'R', '患者連絡先情報', '本人', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="1">
  <DISP_PATID/>
  <CTL_NO>col:$journal.pat_personal_main.pat_contact_info.ctl_no</CTL_NO>
  <DISP_NO>col:$journal.pat_personal_main.pat_contact_info.disp_order</DISP_NO>
  <RELATION>col:$journal.pat_personal_main.pat_contact_info.relation_cd</RELATION>
  <NAME>col:$journal.pat_personal_main.pat_contact_info.name</NAME>
  <ADDRESS>col:$journal.pat_personal_main.pat_contact_info.address</ADDRESS>
  <!-- 住所N -->
  <ZIPCODE>col:$journal.pat_personal_main.pat_contact_info.zip_cd</ZIPCODE>
  <!-- 郵便番号N -->
  <TELNO1>col:$journal.pat_personal_main.pat_contact_info.tel1</TELNO1>
  <!-- 電話番号N -->
</PAT_CONTACT>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-601000004, 'C_hosp', 'profile', 'R', '患者連絡先情報', 'その他', 'CSI', '患者情報（XML)', '1', '<PAT_CONTACT ID="3">
				<DISP_PATID></DISP_PATID>
				<CTL_NO>col:$journal.detail.pat_personal_main.other_contact_info.ctl_no</CTL_NO>
				<DISP_NO>col:$journal.detail.pat_personal_main.other_contact_info.disp_order</DISP_NO>
				<RELATION>col:$journal.detail.pat_personal_main.other_contact_info.relation_cd</RELATION>
				<NAME>col:$journal.detail.pat_personal_main.other_contact_info.name</NAME>
				<ADDRESS>col:$journal.detail.pat_personal_main.other_contact_info.address</ADDRESS><!-- 住所N -->
				<ZIPCODE>col:$journal.detail.pat_personal_main.other_contact_info.zip_cd</ZIPCODE><!-- 郵便番号N -->
				<TELNO1>col:$journal.detail.pat_personal_main.other_contact_info.tel1</TELNO1><!-- 電話番号N -->
</PAT_CONTACT>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-601000001, 'C_hosp', 'profile', 'R', '患者感染症情報', 'all', 'CSI', '患者情報（XML)', '1', '<PAT_INFECT ID="">
				<DISP_PATID></DISP_PATID>
				<INFECTION_CD>col:$journal.detail.pat_main.infect_info.infection_cd</INFECTION_CD><!-- 患者感染症情報:感染症コードN -->
				<INFECT>col:$journal.detail.pat_main.infect_info.infect</INFECT><!-- 患者感染症情報:結果コードN -->
</PAT_INFECT>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');
INSERT INTO ntss.mst_coop_layout_detail
(ctl_no, facility_cd, coop_cd, direction, coop_cd_detail, coop_cd_detail_sub, coop_name, description, is_editable, coop_setting, coop_ext_setting, is_disp, is_del, user_id, reg_date, up_date, coop_version)
VALUES(-606000001, 'C_hosp', 'exam_rst', 'R', '検体検査結果', 'all', 'CSI', '検査結果（XML)', '1', '<RST_EXAMIN_HST_DETAIL ID="">

    <DISP_PATID></DISP_PATID>

    <REG_EXAM_DATE>col:$journal.detail.pat_exam_main.exam_result_info.result_date</REG_EXAM_DATE>

    <REG_ORDER_CLASS>col:$journal.detail.pat_exam_main.exam_result_info.reg_order_class</REG_ORDER_CLASS>

    <IN_HOSPITAL_CD>col:$journal.detail.pat_exam_main.exam_result_info.item_cd</IN_HOSPITAL_CD>

    <EXAM_RST>col:$journal.detail.pat_exam_main.exam_result_info.result</EXAM_RST>

    <COMMENTS>col:$journal.detail.pat_exam_main.exam_result_info.freememo</COMMENTS>

</RST_EXAMIN_HST_DETAIL>', '{}'::jsonb, '1', '0', 5843, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '');