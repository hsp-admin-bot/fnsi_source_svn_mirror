DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1014,1015,1011,1010);
DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (1212);

INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1015, 'SELECT
    CASE WHEN NULLIF(@inOutClass ,'''') IS NOT NULL AND @inOutClass = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@inOutClass, ''FM9999999999999999'') 
		     WHEN NULLIF(@inOutClass ,'''') IS NOT NULL AND @inOutClass  = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@inOutClass, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_INOUT_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)連携設定[患者個人情報]の取得', '2022-06-11 12:57:35.682', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1014, 'SELECT
    CASE WHEN NULLIF(@patSex ,'''') IS NOT NULL AND @patSex = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patSex, ''FM9999999999999999'') 
		     WHEN NULLIF(@patSex ,'''') IS NOT NULL AND @patSex = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patSex, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_SEX_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)連携設定[性別変換項目]の取得', '2022-06-03 15:41:21.709', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1011, 'SELECT
    CASE WHEN NULLIF(@patBloodTypeAbo ,'''') IS NOT NULL AND @patBloodTypeAbo = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patBloodTypeAbo, ''FM9999999999999999'') 
		     WHEN NULLIF(@patBloodTypeAbo ,'''') IS NOT NULL AND @patBloodTypeAbo = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patBloodTypeAbo, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_BLOOD_ABO_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装)患者プロファイル:連携設定詳細(血液型ABO)の取得', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1010, 'SELECT
    CASE WHEN NULLIF(@patBloodTypeRh ,'''') IS NOT NULL AND @patBloodTypeRh = TRIM(ini_info ->> ''value'') THEN TO_NUMBER(@patBloodTypeRh, ''FM9999999999999999'') 
		     WHEN NULLIF(@patBloodTypeRh ,'''') IS NOT NULL AND @patBloodTypeRh = TRIM(ini_info ->> ''default_v'') THEN TO_NUMBER(@patBloodTypeRh, ''FM9999999999999999'') 
       ELSE ''0''
    END AS check_value
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd 
		AND COALESCE(ini_info ->> ''key0'','''') = @key0
    AND TRIM(ini_info ->> ''key1'') = ''CONV_BLOOD_RH_TO_FNW''
  ORDER BY check_value DESC
  LIMIT 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)連携設定詳細(血液型RH)の取得', '2022-01-17 15:02:47', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1212, 'WITH take_cource_info AS ( 
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
		''@medicalCareInfo.mainCourseCd2'' :: TEXT AS dialysis_course_cd
    ,(CASE WHEN ((SELECT take_cource_flg FROM take_cource_info) = ''0'')
			    THEN ''@medicalCareInfo.mainCourseCd2''
					ELSE (CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND (''@inOutClassOut'') = ''1'' -- ''1''：入院
                     THEN ''@medicalCareInfo.mainCourseCd''
                     ELSE ''''
                END)
			END) :: TEXT AS main_course_cd
    , (CASE WHEN (''@inOutClassOut'') = ''1'' -- ''1''：入院
      THEN ''@medicalCareInfo.wardCd''
      ELSE '''' END) :: TEXT AS ward_cd
  FROM 
    pat_main
  WHERE 
    is_del = ''0'' 
    AND pat_id = @patId
)
UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  , medical_care_info = json_build_object( 
      ''main_course_cd''
      , TO_NUMBER(NULLIF((SELECT main_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
      , ''dialysis_course_cd''
      , TO_NUMBER(NULLIF((SELECT dialysis_course_cd FROM cource_ward_info), ''''), ''FM999999999'')
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
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル_患者基本情報の修正', '2022-06-11 01:22:40.189', CURRENT_TIMESTAMP, '[{"sql_cd": 1015, "field_name": "check_value", "replace_var": "@inOutClassOut"}]');