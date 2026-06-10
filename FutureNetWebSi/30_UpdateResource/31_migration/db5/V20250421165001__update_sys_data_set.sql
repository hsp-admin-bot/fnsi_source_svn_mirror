DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (
	-600016
	);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-600016, 'WITH mst_ward_cd AS (
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
        WHEN ''@inOutClass'' = ''1'' -- ''1''：入院
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
    COALESCE(
        TO_NUMBER(medical_care_info ->> ''main_course_cd'',''FM999999999''),
        TO_NUMBER(
            NULLIF(
                (
                    SELECT main_course_cd
                    FROM cource_ward_info
                ),
                ''''
            ),
            ''FM999999999''
        )
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