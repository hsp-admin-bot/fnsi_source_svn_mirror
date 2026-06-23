delete from "sys_data_set" where "sql_cd"  = 1103 or "sql_cd"  = 1201 or "sql_cd"  = 1403 or ("sql_cd"  >= 4101 and "sql_cd"  <= 4104) or "sql_cd"  = 4201 or "sql_cd"  = 4202;INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1103, 'UPDATE pat_personal_main 
SET fn_pat_id = NULLIF ( ''@fnPatId'', '''' ),
hosp_pat_id = NULLIF ( ''@hospPatId'', '''' ),
nkk_pat_id = NULLIF ( ''@nkkPatId'', '''' ),
facility_cd = NULLIF ( ''@facilityCd'', '''' ),
pat_last_name = personal_info_encrypt ( split_part( ''@patLastName'', ''　'', 1 ) ),
pat_first_name = personal_info_encrypt ( split_part( ''@patLastName'', ''　'', 2 ) ),
pat_last_name_kana = personal_info_encrypt ( ''@patLastNmKana'' ),
pat_first_name_kana = personal_info_encrypt ( ''@patFirstNmKana'' ),
pat_last_name_alpha = NULLIF ( ''@patLastNmAlpha'', '''' ),
pat_first_name_alpha = NULLIF ( ''@patFirstNmAlpha'', '''' ),
pat_birth_name = NULLIF ( ''@patBirthName'', '''' ),
pat_birth_name_kana = NULLIF ( ''@patBirthNmKana'', '''' ),
pat_birth_name_alpha = NULLIF ( ''@patBirthNmAlpha'', '''' ),
pat_birthday = NULLIF ( ''@patBirthday'', '''' ),
pat_sex =
CASE
        ''@patSex'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patSex'', ''9999999999999999'' ) 
    END,
    nationality = NULLIF ( ''@nationality'', '''' ),
    pat_blood_type_abo =
CASE
        ''@patBloodTypeAbo'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@patBloodTypeAbo'', ''9999999999999999'' ) 
    END,
    pat_blood_type_rh =
CASE
    ''@patBloodTypeRh'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeRh'', ''9999999999999999'' ) 
    END,
    pat_blood_type_serovar =
CASE
    ''@patBloodTypeSerovar'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@patBloodTypeSerovar'', ''9999999999999999'' ) 
    END,
    in_out_class =
CASE
    ''@inOutClass'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@inOutClass'', ''9999999999999999'' ) 
    END,
    is_die = NULLIF ( ''@isDie'', '''' ),
    die_cd =
CASE
        ''@dieCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@dieCd'', ''99999999999999999999999999999999'' ) 
    END,
    die_date =
CASE
    ''@dieDate_Date'' 
    WHEN '''' THEN
    NULL ELSE to_timestamp( ''@dieDate_Date'', ''yyyy-MM-dd hh24:mi:ss'' ) 
    END,
    dial_diff_com_info = ''@dialDiffComInfoValue'',
    severity_cd =
CASE
    ''@severityCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@severityCd'', ''99999999999999999999999999999999'' ) 
    END,
    transport_cd =
CASE
    ''@transportCd'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@transportCd'', ''99999999999999999999999999999999'' ) 
    END,
    pat_contact_info =
CASE
    ''@patContactInfoFlg'' 
    WHEN '''' THEN
    ''@patContactInfoValue'' ELSE json_build_object (
        ''zip_cd'',
        NULLIF ( ''@patContactInfo.zipCd'', '''' ),
        ''address'',
        NULLIF ( ''@patContactInfo.address'', '''' ),
        ''tel1'',
        NULLIF ( ''@patContactInfo.tel'', '''' ),
        ''fax'',
        NULLIF ( ''@patContactInfo.fax'', '''' ),
        ''e_mail'',
        NULLIF ( ''@patContactInfo.eMail'', '''' ),
        ''work_name'',
        NULLIF ( ''@patContactInfo.workName'', '''' ),
        ''work_address'',
        NULLIF ( ''@patContactInfo.workAddress'', '''' ),
        ''work_tel'',
        NULLIF ( ''@patContactInfo.workTel'', '''' ),
        ''memo1'',
        NULLIF ( ''@patContactInfo.memo1'', '''' ),
        ''memo2'',
        NULLIF ( ''@patContactInfo.memo2'', '''' ) 
    ) 
    END,
    other_contact_info = ''@otherContactInfoValue'',
    vendor_contact_info = ''@vendorContactInfoValue'',
    insurance_info = ''@insuranceInfoValue'',
    reg_date = ''@regDate'',
    up_date = CURRENT_TIMESTAMP,
    primary_disease_cd =
CASE
        ''@primaryDiseaseCd'' 
        WHEN '''' THEN
        NULL ELSE to_number( ''@primaryDiseaseCd'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_service =
CASE
    ''@remoteMonitorService'' 
    WHEN '''' THEN
    NULL ELSE to_number( ''@remoteMonitorService'', ''99999999999999999999999999999999'' ) 
    END,
    remote_monitor_user_id = NULLIF ( ''@remoteMonitorUserId'', '''' ),
    remote_monitor_user_pw = NULLIF ( ''@remoteMonitorUserPw'', '''' ) 
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1201, 'SELECT
    pat_id,
    facility_cd,
    is_same,
    is_implant,
    is_infect,
    is_diabetes,
    is_blood_suger_exam,
    in_out_current_state,
    in_out_plan_state,
    in_out_plan_date,
    pat_memo_info,
    addition_info,
    charge_staff_info,
    pat_group_info,
    taboo_allergy_info,
    infect_info,
    implant_info,
    tare_info,
    off_water_info,
    device_set_info,
    acceptance_status_info,
    is_del,
    up_date,
    reg_date,
    is_wheel_chair,
    medical_care_info,
    sch_ext_end_date,
    sch_ext_status,
    card_idm,
    old_up_date,
    host_notification_info,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl1
        CROSS JOIN LATERAL json_array_elements ( tbl1.pat_memo_info :: json ) RESULT 
    WHERE
        tbl1.pat_id = @patId 
    ) AS next_ctl_no_1,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl2
        CROSS JOIN LATERAL json_array_elements ( tbl2.charge_staff_info :: json ) RESULT 
    WHERE
        tbl2.pat_id = @patId 
    ) AS next_ctl_no_2,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl3
        CROSS JOIN LATERAL json_array_elements ( tbl3.taboo_allergy_info :: json ) RESULT 
    WHERE
        tbl3.pat_id = @patId 
    ) AS next_ctl_no_3,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl4
        CROSS JOIN LATERAL json_array_elements ( tbl4.infect_info :: json ) RESULT 
    WHERE
        tbl4.pat_id = @patId 
    ) AS next_ctl_no_4 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1403, 'UPDATE pat_personal_main 
SET dial_diff_com_info =
CASE
        ''@dialDiffComInfoFlg'' 
        WHEN '''' THEN
        ''@dialDiffComInfoValue'' ELSE dial_diff_com_info || ''[{"ctl_no":"@dialDiffComInfo.ctlNo","dial_diff_cd":"@dialDiffComInfo.dialDiffCd","is_main":"@dialDiffComInfo.isMain","is_dial_diff":"@dialDiffComInfo.isDialDiff","reg_date":"@dialDiffComInfo.regDate"}]'' :: jsonb 
    END,
    other_contact_info =
CASE
    ''@otherContactInfoFlg'' 
    WHEN '''' THEN
    ''@otherContactInfoValue'' ELSE other_contact_info || ''[{"ctl_no":"@otherContactInfo.ctlNo","disp_order":"@otherContactInfo.dispOrder","is_key_person":"@otherContactInfo.isKeyPerson","pat_id":"@otherContactInfo.patId","last_name":"@otherContactInfo.lastName","first_name":"@otherContactInfo.firstName","last_name_kana":"@otherContactInfo.lastNmKana","first_name_kana":"@otherContactInfo.firstNmKana","relation_cd":"@otherContactInfo.relationCd","relation_name":"@otherContactInfo.relationName","zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":"@otherContactInfo.eMail","work_name":"@otherContactInfo.workName","work_tel":"@otherContactInfo.workTel","tel1":"@otherContactInfo.tel1","tel2":"@otherContactInfo.tel2","fax":"@otherContactInfo.fax","memo1":"@otherContactInfo.memo1","memo2":"@otherContactInfo.memo2"}]'' :: jsonb 
    END,
    vendor_contact_info =
CASE
    ''@vendorContactInfoFlg'' 
    WHEN '''' THEN
    ''@vendorContactInfoValue'' ELSE vendor_contact_info || ''[{"ctl_no":"@vendorContactInfo.ctlNo","disp_order":"@vendorContactInfo.dispOrder","company_name":"@vendorContactInfo.companyName","zip_cd":"@vendorContactInfo.zipCd","address":"@vendorContactInfo.address","company_tel":"@vendorContactInfo.companyTel","fax":"@vendorContactInfo.fax","worker_last_name":"@vendorContactInfo.workerLastName","worker_first_name":"@vendorContactInfo.workerFirstName","worker_tel":"@vendorContactInfo.workerTel","worker_e_mail":"@vendorContactInfo.workerEMail","memo1":"@vendorContactInfo.memo1","memo2":"@vendorContactInfo.memo2"}]'' :: jsonb 
    END,
    insurance_info =
CASE
    ''@insuranceInfoFlg'' 
    WHEN '''' THEN
    ''@insuranceInfoValue'' ELSE insurance_info || ''[{"insurance_no":"@insuranceInfo.insuranceNo","insurance_class":"@insuranceInfo.insuranceClass","insured_cd":"@insuranceInfo.insuredCd","insured_no":"@insuranceInfo.insuredNo","insurance_ratio":"@insuranceInfo.insuranceRatio","pub_insu_no1":"@insuranceInfo.pubInsuNo1","pub_insu_no2":"@insuranceInfo.pubInsuNo2","pub_insu_rec_no1":"@insuranceInfo.pubInsuRecNo1","pub_insu_rec_no2":"@insuranceInfo.pubInsuRecNo2","insurance_memo1":"@insuranceInfo.insuranceMemo1","insurance_memo2":"@insuranceInfo.insuranceMemo2","disability_no":"@insuranceInfo.disabilityNo"}]'' :: jsonb 
END 
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4101, 'update pat_personal_main set
	other_contact_info = ''[]''
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4102, 'update pat_personal_main set  other_contact_info = case ''@otherContactInfoFlg''                         when '''' then ''@otherContactInfoValue''                         else other_contact_info || ''[{"ctl_no":"@otherContactInfo.ctlNo","disp_order":"@otherContactInfo.dispOrder","is_key_person":"@otherContactInfo.isKeyPerson","pat_id":"@otherContactInfo.patId","last_name":"@otherContactInfo.lastName","first_name":"@otherContactInfo.firstName","last_name_kana":"@otherContactInfo.lastNmKana","first_name_kana":"@otherContactInfo.firstNmKana","relation_cd":"@otherContactInfo.relationCd","relation_name":"@otherContactInfo.relationName","zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":"@otherContactInfo.eMail","work_name":"@otherContactInfo.workName","work_tel":"@otherContactInfo.workTel","tel1":"@otherContactInfo.tel1","tel2":"@otherContactInfo.tel2","fax":"@otherContactInfo.fax","memo1":"@otherContactInfo.memo1","memo2":"@otherContactInfo.memo2"}]''::jsonb                       end
where  is_del = ''0''and hosp_pat_id = ''@hospPatId''and facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4103, 'update pat_personal_main set
	vendor_contact_info = ''[]''
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4104, 'update pat_personal_main set
  vendor_contact_info = case ''@vendorContactInfoFlg''                          when '''' then ''@vendorContactInfoValue''                          else vendor_contact_info || ''[{"ctl_no":"@vendorContactInfo.ctlNo","disp_order":"@vendorContactInfo.dispOrder","company_name":"@vendorContactInfo.companyName","zip_cd":"@vendorContactInfo.zipCd","address":"@vendorContactInfo.address","company_tel":"@vendorContactInfo.companyTel","fax":"@vendorContactInfo.fax","worker_last_name":"@vendorContactInfo.workerLastName","worker_first_name":"@vendorContactInfo.workerFirstName","worker_tel":"@vendorContactInfo.workerTel","worker_e_mail":"@vendorContactInfo.workerEMail","memo1":"@vendorContactInfo.memo1","memo2":"@vendorContactInfo.memo2"}]''::jsonb                        endwhere  is_del = ''0''and hosp_pat_id = ''@hospPatId''and facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4201, 'UPDATE pat_main 
SET infect_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (4202, 'UPDATE pat_main 
SET infect_info =
CASE
    ''@infectInfoFlg'' 
    WHEN '''' THEN
    ''@infectInfoValue'' ELSE infect_info || ''[{"ctl_no":"@nextCtlNo4", "infection_cd":"@infectInfo.infectionCd", "infect":"@infectInfo.infect", "exam_date":"@infectInfo.examDate", "up_date":"@infectInfo.upDate"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
