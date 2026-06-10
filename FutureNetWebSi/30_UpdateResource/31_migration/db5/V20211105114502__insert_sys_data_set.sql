delete from "sys_data_set" where "sql_cd" in (-99993,1102,1201,1202,7101,7102,7103,7201,7202,7203,7204,7205,7206,7207,7208,7209,7210,7301,7302);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7302, 'update pat_unique set
  medical_hst_info = case ''@medicalHstInfoFlg''
                  when '''' then ''@medicalHstInfoValue''
                  else medical_hst_info || ''[{"memo":"@medicalHstInfo.memo", "ctl_no":"@nextCtlNo2", "die_date":"@medicalHstInfo.dieDate", "out_come":"@medicalHstInfo.outCome", "course_cd":"@medicalHstInfo.courseCd", "is_notice":"@medicalHstInfo.isNotice", "disease_cd":"@medicalHstInfo.diseaseCd", "disp_order":"@medicalHstInfo.dispOrder", "disease_day":"@medicalHstInfo.diseaseDay", "facility_cd":"@medicalHstInfo.facilityCd", "disease_date":"@medicalHstInfo.diseaseDate", "disease_year":"@medicalHstInfo.diseaseYear", "is_diagnosed":"@medicalHstInfo.isDiagnosed", "diagnosis_day":"@medicalHstInfo.diagnosisDay", "disease_month":"@medicalHstInfo.diseaseMonth", "out_come_date":"@medicalHstInfo.outComeDate", "course_is_free":"@medicalHstInfo.courseIsFree", "diagnosis_date":"@medicalHstInfo.diagnosisDate", "diagnosis_year":"@medicalHstInfo.diagnosisYear", "diagnosis_month":"@medicalHstInfo.diagnosisMonth", "is_main_disease":"@medicalHstInfo.isMainDisease", "diagnostician_cd":"@medicalHstInfo.diagnosticianCd", "diagnosis_facility_cd":"@medicalHstInfo.diagnosisFacilityCd", "diagnostician_is_free":"@medicalHstInfo.diagnosticianIsFree", "is_confirmation_biopsy":"@medicalHstInfo.isConfirmationBiopsy", "diagnosis_facility_is_free":"@medicalHstInfo.diagnosisFacilityIsFree", "is_dialysis_underlying_disease":"@medicalHstInfo.isDialysisUnderlyingDisease"}]''::jsonb
                  end
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7301, 'update pat_unique set
  medical_hst_info = ''[]''
where
  pat_id = @patId
and
  facility_cd = ''@facilityCd''
and
  is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(既往歴情報情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7210, 'UPDATE pat_main 
SET taboo_allergy_info =
CASE
    ''@tabooAllergyInfoFlg'' 
    WHEN '''' THEN
    ''@tabooAllergyInfoValue'' ELSE taboo_allergy_info || ''[{"ctl_no":"@nextCtlNo3", "disp_order":"@tabooAllergyInfo.dispOrder", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "content":"@tabooAllergyInfo.content", "memo":"@tabooAllergyInfo.memo", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7209, 'UPDATE pat_main 
SET taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(禁忌・アレルギー情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7208, 'UPDATE pat_main 
SET pat_memo_info =
CASE
    ''@patMemoInfoFlg'' 
    WHEN '''' THEN
    ''@patMemoInfoValue'' ELSE pat_memo_info || ''[{"ctl_no":"@nextCtlNo1", "title":"@patMemoInfo.title", "content":"@patMemoInfo.content"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(患者メモ情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7207, 'UPDATE pat_main 
SET pat_memo_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(患者メモ情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7206, 'UPDATE pat_main 
SET infect_info =
CASE
    ''@infectInfoFlg'' 
    WHEN '''' THEN
    ''@infectInfoValue'' ELSE infect_info || ''[{"ctl_no":"@nextCtlNo4", "infection_cd":"@infectInfo.infectionCd", "infect":"@infectInfo.infect", "exam_date":"@infectInfo.examDate", "up_date":"@infectInfo.upDate"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7205, 'UPDATE pat_main 
SET infect_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7204, 'UPDATE pat_main 
SET implant_info =
CASE
    ''@implantInfoFlg'' 
    WHEN '''' THEN
    ''@implantInfoValue'' ELSE implant_info || ''[{"ctl_no":"@nextCtlNo5", "disp_order":"@implantInfo.dispOrder", "implant_cd":"@implantInfo.implantCd", "reg_date":"@implantInfo.regDate", "remove_date":"@implantInfo.removeDate"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(インプラント情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7203, 'UPDATE pat_main 
SET implant_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(インプラント情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7202, 'UPDATE pat_main 
SET charge_staff_info =
CASE
    ''@chargeStaffInfoFlg'' 
    WHEN '''' THEN
    ''@chargeStaffInfoValue'' ELSE charge_staff_info || ''[{"ctl_no":"@nextCtlNo2", "disp_order":"@chargeStaffInfo.dispOrder", "staff_cd":"@chargeStaffInfo.staffCd", "is_main":"@chargeStaffInfo.isMain", "is_charge":"@chargeStaffInfo.isCharge", "is_puncture":"@chargeStaffInfo.isPuncture"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(担当スタッフ情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7201, 'UPDATE pat_main 
SET charge_staff_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(担当スタッフ情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7103, 'UPDATE pat_personal_main 
SET dial_diff_com_info =
CASE
        ''@dialDiffComInfoFlg'' 
        WHEN '''' THEN
        ''@dialDiffComInfoValue'' ELSE dial_diff_com_info || ''[{"dial_diff_cd":"@dialDiffComInfo.dialDiffCd","is_main":"@dialDiffComInfo.isMain","is_dial_diff":"@dialDiffComInfo.isDialDiff","reg_date":"@dialDiffComInfo.regDate"}]'' :: jsonb 
    END
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7102, 'UPDATE pat_personal_main 
SET other_contact_info =
CASE
    ''@otherContactInfoFlg'' 
    WHEN '''' THEN
    ''@otherContactInfoValue'' ELSE other_contact_info || ''[{"ctl_no":"@otherContactInfo.ctlNo","disp_order":"@otherContactInfo.dispOrder","is_key_person":"@otherContactInfo.isKeyPerson","pat_id":"@otherContactInfo.patId","last_name":"@otherContactInfo.lastName","first_name":"@otherContactInfo.firstName","last_name_kana":"@otherContactInfo.lastNmKana","first_name_kana":"@otherContactInfo.firstNmKana","relation_cd":"@otherContactInfo.relationCd","relation_name":"@otherContactInfo.relationName","zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":"@otherContactInfo.eMail","work_name":"@otherContactInfo.workName","work_tel":"@otherContactInfo.workTel","tel1":"@otherContactInfo.tel1","tel2":"@otherContactInfo.tel2","fax":"@otherContactInfo.fax","memo1":"@otherContactInfo.memo1","memo2":"@otherContactInfo.memo2"}]'' :: jsonb 
    END
WHERE
    is_del = ''0'' 
    AND hosp_pat_id = ''@hospPatId'' 
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7101, 'update pat_personal_main set
	other_contact_info = ''[]''
where
  is_del = ''0''
and
  hosp_pat_id = ''@hospPatId''
and
  facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(連絡先情報)', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'insert into pat_main (
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
  host_notification_info
) values (
  @patId,
  ''@facilityCd'',
  NULLIF(''@isSame'',''''),
  NULLIF(''@isImplant'',''''),
  NULLIF(''@isInfect'',''''),
  NULLIF(''@isDiabetes'',''''),
  NULLIF(''@isBloodSugerExam'',''''),
  NULLIF(''@inOutCurrentState'',''''),
  NULLIF(''@inOutPlanState'',''''),
  case ''@inOutPlanDate_Date''
    when '''' then null
    else to_timestamp(''@inOutPlanDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''[{"title": "手術歴", "ctl_no": 1, "content": "【手術歴】\n年月日：術式"}, {"title": "喫煙歴", "ctl_no": 2, "content": "【喫煙歴】\n年月日：喫煙"}, {"title": "感染歴", "ctl_no": 3, "content": "【感染歴】\n年月日：感染"}, {"title": "透析歴", "ctl_no": 4, "content": "【透析歴】\n年月日：透析"}, {"title": "禁酒歴", "ctl_no": 5, "content": "【透析歴】\n年月日：禁酒"}, {"title": "禁忌・アレルギー歴", "ctl_no": 6, "content": "【禁忌・アレルギー歴】\n年月日：禁忌・アレルギー歴"}, {"title": "\ntestメモ", "ctl_no": 7, "content": null}, {"title": null, "ctl_no": 8, "content": null}, {"title": null, "ctl_no": 9, "content": null}, {"title": null, "ctl_no": 10, "content": null}, {"title": null, "ctl_no": 11, "content": null}, {"title": null, "ctl_no": 12, "content": null}, {"title": null, "ctl_no": 13, "content": null}, {"title": null, "ctl_no": 14, "content": null}, {"title": null, "ctl_no": 15, "content": null}, {"title": null, "ctl_no": 16, "content": null}, {"title": null, "ctl_no": 17, "content": null}, {"title": null, "ctl_no": 18, "content": null}, {"title": null, "ctl_no": 19, "content": null}, {"title": null, "ctl_no": 20, "content": null}]'',
  ''[{"cd": 1, "reg_date": "2021-02-01T03:13:26.591+0000", "is_enable": "1"}, {"cd": 2, "reg_date": "2021-02-01T03:14:10.542+0000", "is_enable": "1"}, {"cd": 3, "reg_date": "2021-02-01T03:14:36.652+0000", "is_enable": "1"}, {"cd": 18, "reg_date": "2021-03-05T09:27:28.158+0000", "is_enable": "1"}, {"cd": 52, "reg_date": "2021-05-21T10:46:35.066+0000", "is_enable": "1"}, {"cd": 53, "reg_date": "2021-05-21T10:46:35.080+0000", "is_enable": "1"}, {"cd": 54, "reg_date": "2021-05-21T10:46:35.092+0000", "is_enable": "1"}, {"cd": 55, "reg_date": "2021-05-21T10:46:35.104+0000", "is_enable": "1"}, {"cd": 56, "reg_date": "2021-05-21T10:46:35.118+0000", "is_enable": "1"}, {"cd": 57, "reg_date": "2021-05-24T11:17:15.419+0000", "is_enable": "1"}]'',
  ''@chargeStaffInfoValue'',
  ''@patGroupInfoValue'',
  ''@tabooAllergyInfoValue'',
  ''[{"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 68}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 69}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 70}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 71}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 72}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 73}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 74}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 75}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 76}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 77}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 78}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 79}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 80}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 81}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 82}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 83}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 84}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 85}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 86}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 87}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 88}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 89}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 90}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 91}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 92}, {"infect": "0", "up_date": null, "exam_date": null, "infection_cd": 93}]'',
  ''@implantInfoValue'',
  ''@tareInfoValue'',
  ''@offWaterInfoValue'',
  ''@deviceSetInfoValue'',
  ''@acceptanceStatusInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  NULLIF(''@isWheelChair'',''''),
  case ''@medicalCareInfoFlg''
    when '''' then json_build_object(''main_course_cd'',null,''dialysis_course_cd'',null,''ward_cd'',null,''dialysis_count'',null,''purification_count'',null,''other_dialysis_count'',null,''facility_cd'',null,''dialysis_start_date'',null,''hospital_start_date'',null)
    else json_build_object(''main_course_cd'',NULLIF(''@medicalCareInfo.mainCourseCd'',''''),''dialysis_course_cd'',NULLIF(''@medicalCareInfo.dialysisCourseCd'',''''),''ward_cd'',NULLIF(''@medicalCareInfo.wardCd'',''''),''dialysis_count'',NULLIF(''@medicalCareInfo.dialysisCount'',''''),''purification_count'',NULLIF(''@medicalCareInfo.purificationCount'',''''),''other_dialysis_count'',NULLIF(''@medicalCareInfo.otherDialysisCount'',''''),''facility_cd'',NULLIF(''@medicalCareInfo.facilityCd'',''''),''dialysis_start_date'',NULLIF(''@medicalCareInfo.dialysisStartDate'',''''),''hospital_start_date'',NULLIF(''@medicalCareInfo.hospitalStartDate'',''''))
  end,
  NULLIF(''@schExtEndDate'',''''),
  NULLIF(''@schExtStatus'',''''),
  NULLIF(''@cardIdm'',''''),
  case ''@oldUpDate_Date''
    when '''' then null
    else to_timestamp(''@oldUpDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  null
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
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
    ) AS next_ctl_no_4,
    (
    SELECT
        (
            COALESCE ( MAX ( TO_NUMBER( COALESCE ( NULLIF ( RESULT ->> ''ctl_no'', '''' ), ''0'' ), ''99999'' ) ), 0 ) + 1 
        ) AS ctl_no 
    FROM
        pat_main tbl5
        CROSS JOIN LATERAL json_array_elements ( tbl5.implant_info :: json ) RESULT 
    WHERE
        tbl5.pat_id = @patId 
    ) AS next_ctl_no_5 
FROM
    pat_main 
WHERE
    is_del = ''0'' 
    AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1102, 'insert into pat_personal_main (
  fn_pat_id,
  hosp_pat_id,
  nkk_pat_id,
  facility_cd,
  pat_last_name,
  pat_first_name,
  pat_last_name_kana,
  pat_first_name_kana,
  pat_last_name_alpha,
  pat_first_name_alpha,
  pat_birth_name,
  pat_birth_name_kana,
  pat_birth_name_alpha,
  pat_birthday,
  pat_sex,
  nationality,
  pat_blood_type_abo,
  pat_blood_type_rh,
  pat_blood_type_serovar,
  in_out_class,
  is_die,
  die_cd,
  die_date,
  dial_diff_com_info,
  severity_cd,
  transport_cd,
  pat_contact_info,
  other_contact_info,
  vendor_contact_info,
  insurance_info,
  is_del,
  up_date,
  reg_date,
  primary_disease_cd,
  remote_monitor_service,
  remote_monitor_user_id,
  remote_monitor_user_pw
) values (
  NULLIF(''@fnPatId'',''''),
  NULLIF(''@hospPatId'',''''),
  NULLIF(''@nkkPatId'',''''),
  NULLIF(''@facilityCd'',''''),
  personal_info_encrypt(split_part( ''@patLastName'', ''　'', 1 )),
  personal_info_encrypt(split_part( ''@patFirstName'', ''　'', 2 )),
  case when split_part( ''@patLastNmKana'', ''　'', 2 ) is null or split_part( ''@patLastNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patLastNmKana'', '' '', 1 ))
  else 
    personal_info_encrypt(split_part( ''@patLastNmKana'', ''　'', 1 ))
  end,
  case when split_part( ''@patFirstNmKana'', ''　'', 2 ) is null or split_part( ''@patFirstNmKana'', ''　'', 2 ) = '''' then 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', '' '', 2 ))
  else 
    personal_info_encrypt(split_part( ''@patFirstNmKana'', ''　'', 2 ))
  end,
  NULLIF(''@patLastNmAlpha'',''''),
  NULLIF(''@patFirstNmAlpha'',''''),
  NULLIF(''@patBirthName'',''''),
  NULLIF(''@patBirthNmKana'',''''),
  NULLIF(''@patBirthNmAlpha'',''''),
  NULLIF(''@patBirthday'',''''),
  case ''@patSex''
    when '''' then null
    else to_number(''@patSex'',''9999999999999999'')
  end,
  NULLIF(''@nationality'',''''),
  case ''@patBloodTypeAbo''
    when '''' then null
    else to_number(''@patBloodTypeAbo'',''9999999999999999'')
  end,
  case ''@patBloodTypeRh''
    when '''' then null
    else to_number(''@patBloodTypeRh'',''9999999999999999'')
  end,
  case ''@patBloodTypeSerovar''
    when '''' then null
    else to_number(''@patBloodTypeSerovar'',''9999999999999999'')
  end,
  case ''@inOutClass''
    when '''' then null
    else to_number(''@inOutClass'',''9999999999999999'')
  end,
  NULLIF(''@isDie'',''''),
  case ''@dieCd''
    when '''' then null
    else to_number(''@dieCd'',''99999999999999999999999999999999'')
  end,
  case ''@dieDate_Date''
    when '''' then null
    else to_timestamp(''@dieDate_Date'',''yyyy-MM-dd hh24:mi:ss'')
  end,
  ''[{"is_main": "0", "reg_date": null, "dial_diff_cd": 1, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 2, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 3, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 4, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 5, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 6, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 7, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 8, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 9, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 10, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 11, "is_dial_diff": "0"}, {"is_main": "0", "reg_date": null, "dial_diff_cd": 12, "is_dial_diff": "0"}]'',
  case ''@severityCd''
    when '''' then null
    else to_number(''@severityCd'',''99999999999999999999999999999999'')
  end,
  case ''@transportCd''
    when '''' then null
    else to_number(''@transportCd'',''99999999999999999999999999999999'')
  end,
  case ''@patContactInfoFlg''
    when '''' then json_build_object(''zip_cd'',null,''address'',null,''tel'',null,''fax'',null,''e_mail'',null,''work_name'',null,''work_address'',null,''work_tel'',null,''memo1'',null,''memo2'',null)
    else json_build_object(''zip_cd'',NULLIF(''@patContactInfo.zipCd'',''''),''address'',NULLIF(TRIM(TRIM(TRIM(''@patContactInfo.address'', ''　''), '' ''), ''　''),''''),''tel'',NULLIF(''@patContactInfo.tel'',''''),''fax'',NULLIF(''@patContactInfo.fax'',''''),''e_mail'',NULLIF(''@patContactInfo.eMail'',''''),''work_name'',NULLIF(''@patContactInfo.workName'',''''),''work_address'',NULLIF(''@patContactInfo.workAddress'',''''),''work_tel'',NULLIF(''@patContactInfo.workTel'',''''),''memo1'',NULLIF(''@patContactInfo.memo1'',''''),''memo2'',NULLIF(''@patContactInfo.memo2'',''''))
  end,
  ''@otherContactInfoValue'',
  ''@vendorContactInfoValue'',
  ''@insuranceInfoValue'',
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  case ''@primaryDiseaseCd''
    when '''' then null
    else to_number(''@primaryDiseaseCd'',''99999999999999999999999999999999'')
  end,
  case ''@remoteMonitorService''
    when '''' then null
    else to_number(''@remoteMonitorService'',''99999999999999999999999999999999'')
  end,
  NULLIF(''@remoteMonitorUserId'',''''),
  NULLIF(''@remoteMonitorUserPw'','''')
)', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-99993, 'SELECT
  ''PatientRequest_'' || 
  TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDDHH24MISS_'') ||
  CASE WHEN LENGTH(journal.hosp_pat_id) >= 12 THEN journal.hosp_pat_id ELSE LPAD(journal.hosp_pat_id, 12, ''0'') END ||
  ''.xml'' AS filename
  , CASE WHEN LENGTH(journal.hosp_pat_id) >= 12 THEN journal.hosp_pat_id ELSE LPAD(journal.hosp_pat_id, 12, ''0'') END AS hosp_pat_id
FROM
  sys_coop_journal AS journal 
WHERE
  journal.ctl_no = @ctlNo', 2, '[]', '0', '{"applications": [4]}', NULL, '日機装 患者情報（XML）[送信]ファイル名取得', '2021-04-20 09:19:08.001', '2021-04-20 09:19:12', NULL);
