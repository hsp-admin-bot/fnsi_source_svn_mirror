DELETE FROM ntss.sys_data_set
WHERE sql_cd in(1211);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(1211, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd''
      AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''HOSPITALIZATION_DEPT_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
    (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) IN (''0'', ''2'')
          THEN (''@medicalCareInfo.mainCourseCd2'' ::TEXT) 
        ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1''           -- ''1''：入院
              THEN (''@medicalCareInfo.mainCourseCd'' ::TEXT) 
            ELSE ('''' ::TEXT) 
            END) 
        END)     AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
                THEN (''@medicalCareInfo.mainCourseCd2'' :: TEXT)
                    ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) IN (''1'' , ''2'') AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
                                            ELSE ('''' :: TEXT)
                END)
            END) AS main_course_cd
    , CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN (''@medicalCareInfo.wardCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS ward_cd
)
, device_set_info_default AS ( 
  SELECT
    host_notification_info
  FROM
    mst_device_set_info_default
  WHERE
    facility_cd = ''@facilityCd''
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
  , json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
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
      , NULLIF(replace(''@medicalCareInfo.dialysisStartDate'', ''/'', ''''), '''')
      , ''hospital_start_date''
      , NULLIF(''@medicalCareInfo.hospitalStartDate'', '''')
    )
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULLIF((SELECT host_notification_info FROM device_set_info_default), ''[]'') ::JSONB
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}, {"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]'::jsonb);