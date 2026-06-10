delete from "sys_data_set" where "sql_cd" in (1202,1203);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'WITH mstWardInfo AS ( 
  SELECT
    A.ward_cd
    , A.ward_name
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_ward A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_ward''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.ward_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.wardCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' 
  ORDER BY
    ms.INDEX
) 
, mstCourseInfo AS ( 
  SELECT
    A.course_cd
    , A.course_name
    , A.standard_course_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_course A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd''
        AND master_physical_name = ''mst_course''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.course_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.mainCourseCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd'' 
  ORDER BY
    ms.INDEX
)
INSERT 
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
      , COALESCE((SELECT course_cd FROM mstCourseInfo), 0)
      , ''dialysis_course_cd''
      , NULLIF(''@medicalCareInfo.dialysisCourseCd'', '''')
      , ''ward_cd''
      , COALESCE((SELECT ward_cd FROM mstWardInfo), 0)
      , ''dialysis_count''
      , NULLIF(''@medicalCareInfo.dialysisCount'', '''')
      , ''purification_count''
      , NULLIF(''@medicalCareInfo.purificationCount'', '''')
      , ''other_dialysis_count''
      , NULLIF(''@medicalCareInfo.otherDialysisCount'', '''')
      , ''pat_dialysis_count''
      , NULLIF(''@medicalCareInfo.patDialysisCount'', '''')
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
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'WITH mstWardInfo AS ( 
  SELECT
    A.ward_cd
    , A.ward_name
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_ward A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd'' 
        AND master_physical_name = ''mst_ward''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.ward_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.wardCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' 
  ORDER BY
    ms.INDEX
) 
, mstCourseInfo AS ( 
  SELECT
    A.course_cd
    , A.course_name
    , A.standard_course_cd
    , A.in_hospital_cd_1 AS hospital_cd 
  FROM
    mst_course A
    , ( 
      SELECT
        mss.facility_cd
        , ms.*
        , ROW_NUMBER() OVER () AS INDEX 
      FROM
        mst_selector mss 
        CROSS JOIN LATERAL jsonb_to_recordset(mss.order_settings -> ''items'') AS ms(code BIGINT, NAME TEXT) 
      WHERE
        facility_cd = ''@facilityCd''
        AND master_physical_name = ''mst_course''
    ) ms 
  WHERE
    A.facility_cd = ms.facility_cd 
    AND A.course_cd = ms.code 
    AND A.is_del = ''0'' 
    AND A.is_disp = ''1'' 
    AND '''' != ''@medicalCareInfo.mainCourseCd'' 
    AND A.in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd'' 
  ORDER BY
    ms.INDEX
)
UPDATE pat_main 
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
      , COALESCE((SELECT course_cd FROM mstCourseInfo), 0)
      , ''dialysis_course_cd''
      , NULLIF(''@medicalCareInfo.dialysisCourseCd'', '''')
      , ''ward_cd''
      , COALESCE((SELECT ward_cd FROM mstWardInfo), 0)
      , ''dialysis_count''
      , NULLIF(''@medicalCareInfo.dialysisCount'', '''')
      , ''purification_count''
      , NULLIF(''@medicalCareInfo.purificationCount'', '''')
      , ''other_dialysis_count''
      , NULLIF(''@medicalCareInfo.otherDialysisCount'', '''')
      , ''pat_dialysis_count''
      , NULLIF(''@medicalCareInfo.patDialysisCount'', '''')
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
