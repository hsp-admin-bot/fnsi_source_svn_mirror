DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-600014,-600016
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600014, 'WITH take_cource_info AS ( 
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
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClass'') = ''1'' -- ''1''：入院
      THEN (SELECT course_cd FROM mst_course_cd)
      ELSE null
    END AS main_course_cd
    , (SELECT ward_cd FROM mst_ward_cd) AS ward_cd
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
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
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''dialysis_course_cd''
      , (SELECT main_course_cd FROM cource_ward_info)
      , ''ward_cd''
      , (SELECT ward_cd FROM cource_ward_info)
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
      , CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE NULL
      END
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
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の新規', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600016, 'WITH take_cource_info AS (
  SELECT
    1 AS order_no,
    CASE
      TRIM(ini_info ->> ''value'')
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'')
      ELSE TRIM(ini_info ->> ''value'')
    END AS take_cource_flg
  FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info :: json) AS ini_info
  WHERE
    ini.is_del = ''0''
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd''
    AND COALESCE(ini_info ->> ''key0'', '''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND''
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG''
  UNION
  SELECT
    2 AS order_no,
    ''1'' AS take_cource_flg
  ORDER BY
    order_no ASC
  LIMIT
    1
), mst_ward_cd AS (
  SELECT
    ward_cd
  FROM
    mst_ward
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.wardCd'' :: TEXT
    AND facility_cd = ''@facilityCd''
    AND is_disp = ''1''
    AND is_del = ''0''
)
, mst_course_cd AS (
  SELECT 
    course_cd
  FROM
    mst_course
  WHERE
    in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    AND facility_cd = ''@facilityCd''
    AND is_del = ''0''
)
, cource_ward_info AS (
  SELECT
    (
      CASE
        WHEN (
          SELECT
            take_cource_flg
          FROM
            take_cource_info
        ) = ''1''
        AND (''@inOutClass'') = ''1'' -- ''1''：入院
        THEN CAST((SELECT course_cd FROM mst_course_cd) AS TEXT)
        ELSE medical_care_info ->> ''main_course_cd''
      END
    ) AS main_course_cd,
    (
      select
        ward_cd
      from
        mst_ward_cd
    ) AS ward_cd
  FROM
    pat_main
  WHERE
    is_del = ''0''
    AND pat_id = @patId
)
, dialysis_start_date_info AS (
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
    WHEN '''' THEN TRIM(ini_info ->> ''default_v'') 
    ELSE TRIM(ini_info ->> ''value'') 
    END AS dialysis_start_date_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.is_disp = ''1''
    AND ini.facility_cd = ''@facilityCd'' 
    AND COALESCE(ini_info ->> ''key0'','''') = ''@key0''
    AND TRIM(ini_info ->> ''key1'') = ''NEC'' 
    AND TRIM(ini_info ->> ''key2'') = ''INTRODUCTION_DATE_FLG''
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS dialysis_start_date_flg 
  ORDER BY order_no ASC LIMIT 1
)
UPDATE
  pat_main
SET
  up_date = CURRENT_TIMESTAMP,
  in_out_current_state = (
    case
      ''@isDie''
      when ''1'' then ''11''
      else in_out_current_state
    end
  ),
  medical_care_info = json_build_object(
    ''main_course_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            main_course_cd
          FROM
            cource_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_course_cd'',
        TO_NUMBER(
      NULLIF(
        (
          SELECT
            main_course_cd
          FROM
            cource_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''ward_cd'',
    (
        SELECT
          ward_cd
        FROM
          cource_ward_info
      ),
    ''dialysis_count'',
    medical_care_info -> ''dialysis_count'',
    ''purification_count'',
    medical_care_info -> ''purification_count'',
    ''other_dialysis_count'',
    medical_care_info -> ''other_dialysis_count'',
    ''pat_dialysis_count'',
    medical_care_info -> ''pat_dialysis_count'',
    ''facility_cd'',
    medical_care_info ->> ''facility_cd'',
    ''dialysis_start_date'',
    CASE (SELECT dialysis_start_date_flg FROM dialysis_start_date_info)
      WHEN ''1'' THEN NULLIF(''@medicalCareInfo.dialysisStartDate'', '''')
      ELSE medical_care_info ->> ''dialysis_start_date''
      END,
    ''hospital_start_date'',
    medical_care_info ->> ''hospital_start_date''
  )
WHERE
  is_del = ''0''
  AND pat_id = @patId
  AND @is_die = ''0''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)初回指示連携、患者情報連携、患者死亡退院情報連携_患者基本情報の更新', '2025-02-05 11:12:00.547', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}]'::jsonb);
