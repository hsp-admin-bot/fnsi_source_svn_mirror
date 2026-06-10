delete from "sys_data_set" where "sql_cd" in (1202,1203,1402,1403,1801,1802,7206);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1402, 'UPDATE pat_personal_main 
SET
  other_contact_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND hosp_pat_id = ''@hospPatId'' 
  AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1801, 'UPDATE pat_main 
SET taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1403, 'UPDATE pat_personal_main 
SET dial_diff_com_info =
CASE
        ''@dialDiffComInfoFlg'' 
        WHEN '''' THEN
        ''@dialDiffComInfoValue'' ELSE dial_diff_com_info || ''[{"dial_diff_cd":"@dialDiffComInfo.dialDiffCd","is_main":"@dialDiffComInfo.isMain","is_dial_diff":"@dialDiffComInfo.isDialDiff","reg_date":"@dialDiffComInfo.regDate"}]'' :: jsonb 
    END,
    other_contact_info =
CASE
    ''@otherContactInfoFlg'' 
    WHEN '''' THEN
    ''@otherContactInfoValue'' ELSE other_contact_info || (''[{"ctl_no":"@otherContactInfo.ctlNo","disp_order":"@otherContactInfo.dispOrder","is_key_person":"@otherContactInfo.isKeyPerson","pat_id":"@otherContactInfo.patId","last_name":"@otherContactInfo.lastName","first_name":"@otherContactInfo.firstName","last_name_kana":"@otherContactInfo.lastNmKana","first_name_kana":"@otherContactInfo.firstNmKana","relation_cd":'' || TO_NUMBER(NULLIF(''@otherContactInfo.relationCd'', ''''), ''FM999999999'') || '',"relation_name":"@otherContactInfo.relationName","zip_cd":"@otherContactInfo.zipCd","address":"@otherContactInfo.address","e_mail":"@otherContactInfo.eMail","work_name":"@otherContactInfo.workName","work_tel":"@otherContactInfo.workTel","tel1":"@otherContactInfo.tel1","tel2":"@otherContactInfo.tel2","fax":"@otherContactInfo.fax","memo1":"@otherContactInfo.memo1","memo2":"@otherContactInfo.memo2"}]'') :: jsonb 
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
    AND facility_cd = ''@facilityCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'INSERT 
INTO pat_main( 
  pat_id
  , facility_cd
  , is_same
  , is_implant
  , is_infect
  , is_diabetes
  , is_blood_suger_exam
  , in_out_current_state
  , in_out_plan_state
  , in_out_plan_date
  , pat_memo_info
  , addition_info
  , charge_staff_info
  , pat_group_info
  , taboo_allergy_info
  , infect_info
  , implant_info
  , tare_info
  , off_water_info
  , device_set_info
  , acceptance_status_info
  , is_del
  , up_date
  , reg_date
  , is_wheel_chair
  , medical_care_info
  , sch_ext_end_date
  , sch_ext_status
  , card_idm
  , old_up_date
  , host_notification_info
) 
VALUES ( 
  @patId
  , ''@facilityCd''
  , NULLIF(''@isSame'', '''')
  , NULLIF(''@isImplant'', '''')
  , NULLIF(''@isInfect'', '''')
  , NULLIF(''@isDiabetes'', '''')
  , NULLIF(''@isBloodSugerExam'', '''')
  , NULLIF(''@inOutCurrentState'', '''')
  , NULLIF(''@inOutPlanState'', '''')
  , CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , COALESCE(NULLIF(''@patMemoInfo'', ''''), ''[]'') ::JSONB
  , COALESCE(NULLIF(''@additioninfo'', ''''), ''[]'') ::JSONB
  , ''@chargeStaffInfoValue''
  , ''@patGroupInfoValue''
  , ''@tabooAllergyInfoValue''
  , COALESCE(NULLIF(''@infectInfo'', ''''), ''[]'') ::JSONB
  , ''@implantInfoValue''
  , ''@tareInfoValue''
  , ''@offWaterInfoValue''
  , ''@deviceSetInfoValue''
  , ''@acceptanceStatusInfoValue''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , NULLIF(''@isWheelChair'', '''')
  , CASE ''@medicalCareInfoFlg'' 
    WHEN '''' THEN json_build_object( 
      ''main_course_cd''
      , NULL
      , ''dialysis_course_cd''
      , NULL
      , ''ward_cd''
      , NULL
      , ''dialysis_count''
      , NULL
      , ''purification_count''
      , NULL
      , ''other_dialysis_count''
      , NULL
      , ''pat_dialysis_count''
      , NULL
      , ''facility_cd''
      , NULL
      , ''dialysis_start_date''
      , NULL
      , ''hospital_start_date''
      , NULL
    ) 
    ELSE json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.mainCourseCd'', ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.wardCd'', ''''), ''FM999999999'')
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    ) 
    END
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2021-12-16 00:56:38.373', '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'UPDATE pat_main 
SET
  pat_id = @patId
  , facility_cd = ''@facilityCd''
  , is_same = NULLIF(''@isSame'', '''')
  , is_implant = NULLIF(''@isImplant'', '''')
  , is_infect = NULLIF(''@isInfect'', '''')
  , is_diabetes = NULLIF(''@isDiabetes'', '''')
  , is_blood_suger_exam = NULLIF(''@isBloodSugerExam'', '''')
  , in_out_current_state = NULLIF(''@inOutCurrentState'', '''')
  , in_out_plan_state = NULLIF(''@inOutPlanState'', '''')
  , in_out_plan_date = CASE ''@inOutPlanDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@inOutPlanDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , pat_memo_info = ''@patMemoInfoValue''
  , addition_info = ''@additionInfoValue''
  , charge_staff_info = ''@chargeStaffInfoValue''
  , pat_group_info = ''@patGroupInfoValue''
  , taboo_allergy_info = ''@tabooAllergyInfoValue''
  , infect_info = ''@infectInfoValue''
  , implant_info = ''@implantInfoValue''
  , tare_info = ''@tareInfoValue''
  , off_water_info = ''@offWaterInfoValue''
  , device_set_info = ''@deviceSetInfoValue''
  , acceptance_status_info = ''@acceptanceStatusInfoValue''
  , up_date = CURRENT_TIMESTAMP
  , is_wheel_chair = NULLIF(''@isWheelChair'', '''')
  , medical_care_info = CASE ''@medicalCareInfoFlg'' 
    WHEN '''' THEN ''@medicalCareInfoValue'' 
    ELSE json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.mainCourseCd'', ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.wardCd'', ''''), ''FM999999999'')
      , ''dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCount'', ''''), ''FM999999999'')
      , ''purification_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.purificationCount'', ''''), ''FM999999999'')
      , ''other_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.otherDialysisCount'', ''''), ''FM999999999'')
      , ''pat_dialysis_count''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.patDialysisCount'', ''''), ''FM999999999'')
      , ''facility_cd''
      , NULLIF(''@medicalCareInfo.facilityCd'', '''')
      , ''dialysis_start_date''
      , NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    ) 
    END
  , sch_ext_end_date = NULLIF(''@schExtEndDate'', '''')
  , sch_ext_status = NULLIF(''@schExtStatus'', '''')
  , card_idm = NULLIF(''@cardIdm'', '''')
  , old_up_date = CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2021-12-16 00:56:38.322', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7206, 'WITH infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    , NULLIF(''@infectInfo.infect'', ''0'') AS infect
    , SUBSTR(COALESCE(TO_CHAR(TO_TIMESTAMP(NULLIF(''@infectInfo.examDate_Date'', ''''), ''yyyy-MM-dd hh24:mi:ss''), ''yyyyMMdd''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
    AND ms ->> ''infection_cd'' :: TEXT = ''@infectInfo.infectionCd''
) 
UPDATE pat_main 
SET infect_info = jsonb_set (
  COALESCE ( infect_info, ''[]'' ) :: JSONB,
  CAST ( ( SELECT ''{'' ||  idx || ''}'' FROM infectionInfo ) AS TEXT [] ),
  CAST ( ( SELECT ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' FROM infectionInfo ) AS JSONB ) :: JSONB 
) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(感染症情報)', '2020-05-25 18:21:40.841', '2021-12-16 00:56:38.271', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1802, 'WITH memoInfo AS (
  SELECT 
    ''【分類】'' || ''@tabooAllergyInfo.content'' || ''\n''
    ''【開始日】'' || ''@tabooAllergyInfo.startDate'' || ''\n''
    ''【症状】'' || ''@tabooAllergyInfo.symptom'' || ''\n''
    ''【マスタ一致】該当なし（'' || ''@tabooAllergyInfo.tabooAllergyCd'' || ''）'' AS meno
) 
UPDATE pat_main 
SET taboo_allergy_info =
CASE
    ''@tabooAllergyInfoFlg'' 
    WHEN '''' THEN
    ''@tabooAllergyInfoValue'' ELSE taboo_allergy_info || (''[{"memo":"'' || (SELECT meno FROM memoInfo) || ''", "ctl_no":"@nextCtlNo3", "content":"@tabooAllergyInfo.content", "disp_order":'' || COALESCE(NULLIF(''@tabooAllergyInfo.dispOrder'', ''''), ''null'') || '', "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'') :: jsonb 
  END 
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
