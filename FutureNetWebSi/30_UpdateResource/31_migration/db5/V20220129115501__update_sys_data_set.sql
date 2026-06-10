delete from "sys_data_set" where "sql_cd" in (1201,1202,1203,1204,1205,1206,1207,-20,-39,-41);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-41, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''COURSE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''COURSE_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''WARD'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS ward_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''XRAY_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
    , dial_course.course_name AS dial_course_name
    , dial_course.in_hospital_cd_1 AS dial_course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
    LEFT JOIN mst_course AS dial_course
      ON dial_course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    WHEN (SELECT course_from FROM course_from_info) = ''2'' 
      THEN COALESCE(NULLIF((SELECT dial_course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE @inOut WHEN ''1'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）放射線：診療科コードと病棟コード', '2022-01-19 18:29:49', '2022-01-19 18:29:49', '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-39, 'WITH course_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''COURSE'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS course_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, course_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS course_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''COURSE_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS course_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_from_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_from 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''WARD'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS ward_from 
  ORDER BY
    order_no ASC LIMIT 1
) 
, ward_code_info AS ( 
  SELECT
    1 AS order_no
    , COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS ward_code 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) info 
  WHERE
    facility_cd = @facilityCd 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''EXAMIN_INFO'' 
    AND info ->> ''key2'' = ''WARD_CODE'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS ward_code 
  ORDER BY
    order_no ASC LIMIT 1
) 
, exam_info AS ( 
  SELECT
    medical_care_info ->> ''ward_cd'' AS ward_cd
    , ward.ward_name AS ward_name
    , ward.in_hospital_cd_1 AS ward_in_hospital_cd
    , medical_care_info ->> ''main_course_cd'' AS main_course_cd
    , course.course_name AS course_name
    , course.in_hospital_cd_1 AS course_in_hospital_cd 
    , dial_course.course_name AS dial_course_name
    , dial_course.in_hospital_cd_1 AS dial_course_in_hospital_cd 
  FROM
    pat_main AS main 
    LEFT JOIN mst_ward AS ward 
      ON ward.ward_cd ::TEXT = main.medical_care_info ->> ''ward_cd'' 
    LEFT JOIN mst_course AS course 
      ON course.course_cd ::TEXT = main.medical_care_info ->> ''main_course_cd'' 
    LEFT JOIN mst_course AS dial_course
      ON dial_course.course_cd ::TEXT = main.medical_care_info ->> ''dialysis_course_cd'' 
  WHERE
    main.pat_id = @patId 
) 
SELECT
  CASE 
    WHEN (SELECT course_from FROM course_from_info) = ''1'' 
      THEN COALESCE(NULLIF((SELECT course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    WHEN (SELECT course_from FROM course_from_info) = ''2'' 
      THEN COALESCE(NULLIF((SELECT dial_course_in_hospital_cd FROM exam_info), ''''), (SELECT course_code FROM course_code_info)) 
    ELSE (SELECT course_code FROM course_code_info) 
    END AS course_cd
  , CASE @inOut WHEN ''1'' THEN
      (CASE WHEN (SELECT ward_from FROM ward_from_info) = ''1'' 
       THEN COALESCE(NULLIF((SELECT ward_in_hospital_cd FROM exam_info), ''''), (SELECT ward_code FROM ward_code_info)) 
       ELSE (SELECT ward_code FROM ward_code_info) 
       END)
    ELSE '''' END AS ward_cd', 2, '[]', '0', '{"applications": [4]}', NULL, '富士通）検査オーダ(診療科コードと病棟コード)', '2022-01-12 18:29:49', '2022-01-12 18:29:49', '[{"sql_cd": -20, "field_name": "in_out", "replace_var": "@inOut"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-20, 'select 
	TO_CHAR(COALESCE(ppm.in_out_class, 0), ''FM9'') as in_out,
	(case ppm.in_out_class when ''0'' then ''1'' when ''1'' then ''2''  else ''1'' end) as exam_in_out
from 
	pat_personal_main ppm
where
	pat_id = @patId ', 3, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）入外区分', '2020-04-10 17:18:50', '2020-04-10 17:18:53', NULL);
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
    AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者基本情報の取得', '2022-01-28 18:21:40', '2022-01-28 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1202, 'WITH take_cource_info AS ( 
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
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
    CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' 
      THEN (''@medicalCareInfo.mainCourseCd'' :: TEXT) 
      ELSE ('''' :: TEXT) END AS main_course_cd
    , (''@medicalCareInfo.wardCd'' :: TEXT) AS ward_cd
  WHERE 
    (''@inOutClass'') = ''1'' -- ''1''：入院
  UNION 
  SELECT
    ''''  AS main_course_cd
    , ''''  AS ward_cd
  WHERE 
    (''@inOutClass'') <> ''1'' -- [''1''：入院]以外（0:外来）
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
      , TO_NUMBER(NULLIF(''@medicalCareInfo.dialysisCourseCd'', ''''), ''FM999999999'')
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
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-01-28 18:21:40', '2022-01-28 18:21:40', '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1203, 'WITH take_cource_info AS ( 
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
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''IS_TAKE_COURCE_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
, cource_ward_info AS (
  SELECT 
    (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' 
       THEN ''@medicalCareInfo.mainCourseCd'' 
       ELSE medical_care_info->>''main_course_cd'' 
     END) :: TEXT AS main_course_cd
    , (''@medicalCareInfo.wardCd'' :: TEXT) AS ward_cd
  FROM 
    pat_main
  WHERE 
    is_del = ''0'' 
    AND pat_id = @patId
    AND (''@inOutClass'') = ''1'' -- ''1''：入院
  UNION 
  SELECT
    ''''  AS main_course_cd
    , ''''  AS ward_cd
  WHERE 
    (''@inOutClass'') <> ''1'' -- [''1''：入院]以外（0:外来）
)
UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  , medical_care_info = json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , medical_care_info->''dialysis_course_cd''
      , ''ward_cd''
      , TO_NUMBER(NULLIF((SELECT ward_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_count''
      , medical_care_info->''dialysis_count''
      , ''purification_count''
      , medical_care_info->''purification_count''
      , ''other_dialysis_count''
      , medical_care_info->''other_dialysis_count''
      , ''pat_dialysis_count''
      , medical_care_info->''pat_dialysis_count''
      , ''facility_cd''
      , medical_care_info->>''facility_cd''
      , ''dialysis_start_date''
      , medical_care_info->>''dialysis_start_date''
      , ''hospital_start_date''
      , medical_care_info->>''hospital_start_date''
    )
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-01-28 18:21:40', '2022-01-28 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1204, 'DELETE 
FROM
  pat_main 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者基本情報の削除(物理)', '2022-01-28 18:21:40', '2022-01-28 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1205, 'UPDATE pat_main 
SET is_del = ''1'' 
WHERE
  facility_cd = ''@facilityCd'' 
  AND pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)患者基本情報の削除(論理:削除フラグ=''1'')', '2022-01-28 18:21:40', '2022-01-28 18:21:40', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1206, 'INSERT 
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
  , NULLIF(''@schExtEndDate'', '''')
  , NULLIF(''@schExtStatus'', '''')
  , NULLIF(''@cardIdm'', '''')
  , CASE ''@oldUpDate_Date'' 
    WHEN '''' THEN NULL 
    ELSE to_timestamp(''@oldUpDate_Date'', ''yyyy-MM-dd hh24:mi:ss'') 
    END
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の浄化申し込み・初回指示_患者基本情報の新規
', '2022-01-28 18:21:40', '2022-01-28 18:21:40', '[{"sql_cd": 1002, "field_name": "pat_memo_info", "replace_var": "@patMemoInfo"}, {"sql_cd": 1003, "field_name": "infect_info", "replace_var": "@infectInfo"}, {"sql_cd": 1004, "field_name": "addition_info", "replace_var": "@additioninfo"}]');
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1207, 'UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  , medical_care_info = json_build_object( 
      ''main_course_cd''
      , TO_NUMBER((CASE WHEN medical_care_info->>''main_course_cd'' IS NULL THEN NULLIF(''@medicalCareInfo.mainCourseCd'', '''') ELSE medical_care_info->>''main_course_cd'' END), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER((CASE WHEN medical_care_info->>''main_course_cd'' IS NULL THEN medical_care_info->>''dialysis_course_cd'' ELSE NULLIF(''@medicalCareInfo.mainCourseCd'', '''') END), ''FM999999999'')
      , ''ward_cd''
      , TO_NUMBER(NULLIF(''@medicalCareInfo.wardCd'', ''''), ''FM999999999'')
      , ''dialysis_count''
      , medical_care_info->''dialysis_count''
      , ''purification_count''
      , medical_care_info->''purification_count''
      , ''other_dialysis_count''
      , medical_care_info->''other_dialysis_count''
      , ''pat_dialysis_count''
      , medical_care_info->''pat_dialysis_count''
      , ''facility_cd''
      , medical_care_info->>''facility_cd''
      , ''dialysis_start_date''
      , medical_care_info->>''dialysis_start_date''
      , ''hospital_start_date''
      , medical_care_info->>''hospital_start_date''
    )
WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の浄化申し込み・初回指示_患者基本情報の修正
', '2022-01-28 18:21:40', '2022-01-28 18:21:40', NULL);
