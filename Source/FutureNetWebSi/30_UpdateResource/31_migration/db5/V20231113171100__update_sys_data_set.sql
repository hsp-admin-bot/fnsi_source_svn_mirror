DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (4202,-603202,-603102)
;


INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(4202, 'WITH infection_nec AS ( 
  (
    SELECT
      A.infection_cd :: TEXT AS infection_cd
    FROM
      mst_infection A
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
          AND master_physical_name = ''mst_infection''
      ) ms 
    WHERE
      A.facility_cd = ms.facility_cd 
      AND A.infection_cd = ms.code 
      AND A.is_del = ''0'' 
      AND A.is_disp = ''1'' 
      AND ( A.in_hospital_cd_1 = ''@infectInfo.infectionCd'') 
  ORDER BY
    infection_cd ASC LIMIT 1
  )
  UNION 
  SELECT
    ''0'' AS infection_cd 
  ORDER BY
    infection_cd DESC LIMIT 1
) 
, infectionInfo AS ( 
  SELECT
    (idx - 1) AS idx
    , ms ->> ''infection_cd'' AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    pat_main AS A 
    CROSS JOIN LATERAL jsonb_array_elements(A.infect_info ::jsonb) WITH ORDINALITY AS info(ms, idx)
    INNER JOIN infection_nec AS nec ON nec.infection_cd = ms ->> ''infection_cd'' AND ms ->> ''infection_cd'' != ''0'' 
  WHERE
    A.is_del = ''0'' 
    AND A.facility_cd = ''@facilityCd'' 
    AND A.pat_id = @patId 
  UNION 
  SELECT
    NULL AS idx
    , nec.infection_cd AS infection_cd 
    , CASE ''@infectInfo.infect'' WHEN ''1'' THEN ''1'' WHEN ''2'' THEN ''2'' ELSE ''0'' END AS infect
    , SUBSTR(COALESCE(NULLIF(''@infectInfo.examDate'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')), 1, 8) AS exam_date
    , TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS up_date
  FROM
    infection_nec AS nec 
  ORDER BY
    idx ASC NULLS LAST LIMIT 1
) 
UPDATE pat_main 
SET
  infect_info = jsonb_set( 
    COALESCE(infect_info, ''[]'') ::JSONB
    , CAST( 
      ( 
        SELECT
          ''{'' || COALESCE(idx, 999) || ''}'' 
        FROM
          infectionInfo
      ) AS TEXT []
    ) 
    , CAST( 
      ( 
        SELECT
          ''{"infect":"'' || infect || ''", "up_date":"'' || up_date || ''", "exam_date":"'' || exam_date || ''", "infection_cd":'' || infection_cd || ''}'' 
        FROM
          infectionInfo
      ) AS JSONB
    ) ::JSONB
  ) 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)CSIの患者プロファイル', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603202, '-- 【SQL_CD=-603202】
WITH mst_course_info AS (
  SELECT
    mst_course.course_cd :: text as course_cd
  , mst_course.in_hospital_cd_1
  FROM
    mst_course
  WHERE
    mst_course.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND in_hospital_cd_1 = ''@medicalCareInfo.mainCourseCd''
    ORDER BY course_cd ASC
    LIMIT 1
),
mst_ward_info AS (
  SELECT
    mst_ward.ward_cd :: text as ward_cd
  , mst_ward.in_hospital_cd_1
  FROM
    mst_ward
  WHERE
    mst_ward.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND in_hospital_cd_1 = ''@medicalCareInfo.wardCd''
    ORDER BY ward_cd ASC
    LIMIT 1
),
course_ward_info AS (
  SELECT
    (
      CASE ''@medicalCareInfo.mainCourseCd''
        WHEN ''''
        THEN pat_main.medical_care_info ->> ''main_course_cd''
        ELSE mst_course_info.course_cd
      END
    ) :: TEXT AS main_course_cd,
    (
      case
        ''@medicalCareInfo.wardCd''
        when '''' then pat_main.medical_care_info ->> ''ward_cd''
        else mst_ward_info.ward_cd
      end
    ) AS ward_cd
  FROM
    pat_main
  LEFT JOIN mst_course_info ON
    ''@medicalCareInfo.mainCourseCd'' = mst_course_info.in_hospital_cd_1
  LEFT JOIN mst_ward_info ON
    ''@medicalCareInfo.wardCd'' = mst_ward_info.in_hospital_cd_1
  WHERE
    is_del = ''0''
    AND pat_id = @patId
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
            course_ward_info
        ),
        ''''
      ),
      ''FM999999999''
    ),
    ''dialysis_course_cd'',
    medical_care_info -> ''dialysis_course_cd'',
    ''ward_cd'',
    TO_NUMBER(
      NULLIF(
        (
          SELECT
            ward_cd
          FROM
            course_ward_info
        ),
        ''''
      ),
      ''FM999999999''
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
    medical_care_info ->> ''dialysis_start_date'',
    ''hospital_start_date'',
    medical_care_info ->> ''hospital_start_date''
  )
WHERE
  is_del = ''0''
  AND pat_id = @patId', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者プロファイル_患者基本情報の修正', '2023-09-28 13:12:38.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-603102, '-- 【SQL_CD=-603102】
WITH mst_course_info AS (
  SELECT
    mst_course.course_cd :: text as main_course_cd
  , mst_course.in_hospital_cd_1
  FROM
    mst_course
  WHERE
    mst_course.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND ''@medicalCareInfo.mainCourseCd'' = mst_course.in_hospital_cd_1
    ORDER BY course_cd ASC
    LIMIT 1
),
mst_ward_info AS (
  SELECT
    mst_ward.ward_cd :: text as ward_cd
  , mst_ward.in_hospital_cd_1
  FROM
    mst_ward
  WHERE
    mst_ward.facility_cd = ''@facilityCd''
    AND is_del = ''0''
    AND ''@medicalCareInfo.wardCd'' = mst_ward.in_hospital_cd_1
    ORDER BY ward_cd ASC
    LIMIT 1
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
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM mst_course_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM mst_ward_info), ''''), ''FM999999999'')
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
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)患者プロファイル_患者基本情報の新規', '2023-10-05 22:41:33.168', CURRENT_TIMESTAMP, '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]'::jsonb);