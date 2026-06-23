delete from "sys_data_set" where "sql_cd" in (1601,1602,1603,1701,1702,1703,1704,1705);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1601, 'SELECT
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique 
FROM
  pat_unique 
WHERE
  pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報取得', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1602, 'INSERT 
INTO pat_unique( 
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
) 
VALUES ( 
  @patId
  , ''[]''
  , ''[]''
  , ''[]''
  , ''0''
  , CURRENT_TIMESTAMP
  , CURRENT_TIMESTAMP
  , ''@facilityCd ''
  , NULL
)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報登録', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1603, 'UPDATE pat_unique 
SET
  medical_hst_info = ''[]''
  , in_out_visit_history_info = ''[]''
  , physical_info = ''[]'' 
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報更新', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1701, 'SELECT
  pat_id
  , medical_hst_info
  , in_out_visit_history_info
  , physical_info
  , is_del
  , up_date
  , reg_date
  , facility_cd
  , old_up_date_unique
  , ( 
    SELECT
      (COALESCE(MAX(TO_NUMBER(COALESCE(NULLIF(RESULT ->> ''ctl_no'', ''''), ''0''), ''FM99999'')), 0) + 1) AS ctl_no 
    FROM
      pat_unique tbl1 
      CROSS JOIN LATERAL json_array_elements(tbl1.physical_info ::json) RESULT 
    WHERE
      tbl1.pat_id = @patId
  ) AS next_ctl_no_1
  , ( 
    SELECT
      (COALESCE(MAX(TO_NUMBER(COALESCE(NULLIF(RESULT ->> ''ctl_no'', ''''), ''0''), ''FM99999'')), 0) + 1) AS ctl_no 
    FROM
      pat_unique tbl2 
      CROSS JOIN LATERAL json_array_elements(tbl2.medical_hst_info ::json) RESULT 
    WHERE
      tbl2.pat_id = @patId
  ) AS next_ctl_no_2
  , ( 
    SELECT
      (COALESCE(MAX(TO_NUMBER(COALESCE(NULLIF(RESULT ->> ''ctl_no'', ''''), ''0''), ''FM99999'')), 0) + 1) AS ctl_no 
    FROM
      pat_unique tbl3 
      CROSS JOIN LATERAL json_array_elements(tbl3.in_out_visit_history_info ::json) RESULT 
    WHERE
      tbl3.pat_id = @patId
  ) AS next_ctl_no_3 
FROM
  pat_unique 
WHERE
  pat_id = @patId 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報取得JSON', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1702, 'UPDATE pat_unique 
SET
  physical_info = ''[]'' 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1703, 'WITH exam_date_tmp AS ( 
  SELECT
    COALESCE(NULLIF(''@physicalInfo.examDate1_Date'', ''''), COALESCE(NULLIF(''@physicalInfo.examDate2_Date'', ''''), TO_CHAR(CURRENT_TIMESTAMP, ''YYYY-MM-DD HH24:MI:SS''))) AS exam_date
) 
, exam_date_info AS ( 
  SELECT
    SUBSTR(exam_date, 1, 10) || ''T'' || SUBSTR(exam_date, 12, 8) AS exam_date
    , TO_CHAR(TO_DATE(exam_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS inspect_date
    , TO_CHAR(TO_DATE(exam_date, ''YYYY-MM-DD HH24:MI:SS''), ''YYYYMMDD'') AS indicator_start_date 
  FROM
    exam_date_tmp
) 
, order_class_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''1'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS order_class 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENT_SEND'' 
    AND TRIM(ini_info ->> ''key2'') = ''ORDER_CLASS'' 
  UNION 
  SELECT
    2 AS order_no
    , ''1'' AS order_class 
  ORDER BY
    order_no ASC LIMIT 1
) 
, indicator_info AS ( 
  SELECT
    1 AS order_no
    , CASE 
      WHEN TRIM(ini_info ->> ''value'') = '''' OR TRIM(ini_info ->> ''value'') = ''0'' 
        THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''0''), '''') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS indicator_cd 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''ORDER_RECV'' 
    AND TRIM(ini_info ->> ''key2'') = ''DEFAULT_DOCTOR'' 
  UNION 
  SELECT
    2 AS order_no
    , '''' AS indicator_cd 
  ORDER BY
    order_no ASC LIMIT 1
) 
, data_new_info AS (
  SELECT 
    NULL AS dw,
    NULL AS ctr,
    NULL AS memo,
    NULL AS ctl_no,
    ''@physicalInfo.height'' AS height,
    NULL AS chest_dia,
    (SELECT exam_date FROM exam_date_info) AS exam_date,
    NULL AS breast_dia,
    ''@physicalInfo.ctrWeight'' AS ctr_weight,
    ''@facilityCd'' AS facility_cd,
    (SELECT order_class FROM order_class_info) AS order_class,
    (SELECT indicator_cd FROM indicator_info) AS indicator_cd,
    (SELECT inspect_date FROM exam_date_info) AS inspect_date,
    NULL AS pre_scale_lower,
    NULL AS pre_scale_upper,
    (SELECT indicator_start_date FROM exam_date_info) AS indicator_start_date
) 
, data_old_info AS (
  SELECT
    info ->> ''dw'' AS dw,
    info ->> ''ctr'' AS ctr,
    info ->> ''memo'' AS memo,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''height'' AS height,
    info ->> ''chest_dia'' AS chest_dia,
    info ->> ''exam_date'' AS exam_date,
    info ->> ''breast_dia'' AS breast_dia,
    info ->> ''ctr_weight'' AS ctr_weight,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''order_class'' AS order_class,
    info ->> ''indicator_cd'' AS indicator_cd,
    info ->> ''inspect_date'' AS inspect_date,
    info ->> ''pre_scale_lower'' AS pre_scale_lower,
    info ->> ''pre_scale_upper'' AS pre_scale_upper,
    info ->> ''indicator_start_date'' AS indicator_start_date 
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.physical_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    exam_date DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    TO_NUMBER(OLD.height ::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.height ::TEXT, ''FM9999.99'') 
    AND TO_NUMBER(OLD.ctr_weight ::TEXT, ''FM9999.99'') = TO_NUMBER(NEW.ctr_weight ::TEXT, ''FM9999.99'') 
    AND SUBSTR(OLD.exam_date ::TEXT, 1, 10) = SUBSTR(NEW.exam_date ::TEXT, 1, 10) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no
    , dw ::TEXT AS dw
    , ctr ::TEXT AS ctr
    , memo ::TEXT AS memo
    , ctl_no ::TEXT AS ctl_no
    , height ::TEXT AS height
    , chest_dia ::TEXT AS chest_dia
    , exam_date ::TEXT AS exam_date
    , breast_dia ::TEXT AS breast_dia
    , ctr_weight ::TEXT AS ctr_weight
    , facility_cd ::TEXT AS facility_cd
    , order_class ::TEXT AS order_class
    , indicator_cd ::TEXT AS indicator_cd
    , inspect_date ::TEXT AS inspect_date
    , pre_scale_lower ::TEXT AS pre_scale_lower
    , pre_scale_upper ::TEXT AS pre_scale_upper
    , indicator_start_date ::TEXT AS indicator_start_date 
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no
    , info ->> ''dw'' AS dw
    , info ->> ''ctr'' AS ctr
    , info ->> ''memo'' AS memo
    , info ->> ''ctl_no'' AS ctl_no
    , info ->> ''height'' AS height
    , info ->> ''chest_dia'' AS chest_dia
    , info ->> ''exam_date'' AS exam_date
    , info ->> ''breast_dia'' AS breast_dia
    , info ->> ''ctr_weight'' AS ctr_weight
    , info ->> ''facility_cd'' AS facility_cd
    , info ->> ''order_class'' AS order_class
    , info ->> ''indicator_cd'' AS indicator_cd
    , info ->> ''inspect_date'' AS inspect_date
    , info ->> ''pre_scale_lower'' AS pre_scale_lower
    , info ->> ''pre_scale_upper'' AS pre_scale_upper
    , info ->> ''indicator_start_date'' AS indicator_start_date 
  FROM
    pat_unique patu 
    CROSS JOIN LATERAL json_array_elements(patu.physical_info ::json) AS info 
  WHERE
    pat_id = @patId  
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0''
  ORDER BY order_no ASC, exam_date DESC)
, json_data AS (
  SELECT json_build_object(''dw'', dw,
    ''ctr'', ctr,
    ''memo'', memo,
    ''ctl_no'', row_number() over(order by order_no ASC, exam_date DESC),
    ''height'', height,
    ''chest_dia'', chest_dia,
    ''exam_date'', exam_date,
    ''breast_dia'', breast_dia,
    ''ctr_weight'', ctr_weight,
    ''facility_cd'', facility_cd,
    ''order_class'', order_class,
    ''indicator_cd'', indicator_cd,
    ''inspect_date'', inspect_date,
    ''pre_scale_lower'', pre_scale_lower,
    ''pre_scale_upper'', pre_scale_upper,
    ''indicator_start_date '', indicator_start_date) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  physical_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_身体情報', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1704, 'UPDATE pat_unique 
SET
  in_out_visit_history_info = ''[]'' 
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1705, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    ''@inOutClass'' :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    ''@facilityCd'' AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    (CASE ''@inOutClass'' WHEN ''0'' THEN  ''6'' WHEN ''1'' THEN ''4'' ELSE ''10'' END) :: TEXT AS move_in_out,
    null AS to_facility,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    TO_CHAR(CURRENT_TIMESTAMP, ''DD'') AS period_start_day,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'') AS period_start_date,
    TO_CHAR(CURRENT_TIMESTAMP, ''YYYY'') AS period_start_year,
    TO_CHAR(CURRENT_TIMESTAMP, ''MM'') AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, data_old_info AS (
  SELECT
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start_date DESC, ctl_no ASC LIMIT 1
) 
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    data_old_info AS OLD
    , data_new_info AS NEW 
  WHERE
    (OLD.in_out ::TEXT) = (NEW.in_out ::TEXT) 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS exists_flag 
  ORDER BY
    order_no ASC LIMIT 1
)
, data_info AS ( 
  SELECT
    0 AS order_no,
    ctl_no::TEXT AS ctl_no,
    in_out::TEXT AS in_out,
    reason::TEXT AS reason,
    to_course::TEXT AS to_course,
    to_doctor::TEXT AS to_doctor,
    disp_order::TEXT AS disp_order,
    period_end::TEXT AS period_end,
    facility_cd::TEXT AS facility_cd,
    from_course::TEXT AS from_course,
    from_doctor::TEXT AS from_doctor,
    move_in_out::TEXT AS move_in_out,
    to_facility::TEXT AS to_facility,
    period_start::TEXT AS period_start,
    from_facility::TEXT AS from_facility,
    course_is_free::TEXT AS course_is_free,
    doctor_is_free::TEXT AS doctor_is_free,
    period_end_day::TEXT AS period_end_day,
    period_end_year::TEXT AS period_end_year,
    facility_is_free::TEXT AS facility_is_free,
    period_end_month::TEXT AS period_end_month,
    period_start_day::TEXT AS period_start_day,
    period_start_date::TEXT AS period_start_date,
    period_start_year::TEXT AS period_start_year,
    period_start_month::TEXT AS period_start_month,
    period_end_input_free::TEXT AS period_end_input_free,
    period_start_input_free::TEXT AS period_start_input_free,
    to_medicalInstitutionCd::TEXT AS to_medicalInstitutionCd,
    from_medicalInstitutionCd::TEXT AS from_medicalInstitutionCd
  FROM
    data_new_info 
  WHERE
    (SELECT exists_flag FROM data_exists_info) = ''0'' 
  UNION 
  SELECT
    1 AS order_no,
    info ->> ''ctl_no'' AS ctl_no,
    info ->> ''in_out'' AS in_out,
    info ->> ''reason'' AS reason,
    info ->> ''to_course'' AS to_course,
    info ->> ''to_doctor'' AS to_doctor,
    info ->> ''disp_order'' AS disp_order,
    info ->> ''period_end'' AS period_end,
    info ->> ''facility_cd'' AS facility_cd,
    info ->> ''from_course'' AS from_course,
    info ->> ''from_doctor'' AS from_doctor,
    info ->> ''move_in_out'' AS move_in_out,
    info ->> ''to_facility'' AS to_facility,
    info ->> ''period_start'' AS period_start,
    info ->> ''from_facility'' AS from_facility,
    info ->> ''course_is_free'' AS course_is_free,
    info ->> ''doctor_is_free'' AS doctor_is_free,
    info ->> ''period_end_day'' AS period_end_day,
    info ->> ''period_end_year'' AS period_end_year,
    info ->> ''facility_is_free'' AS facility_is_free,
    info ->> ''period_end_month'' AS period_end_month,
    info ->> ''period_start_day'' AS period_start_day,
    info ->> ''period_start_date'' AS period_start_date,
    info ->> ''period_start_year'' AS period_start_year,
    info ->> ''period_start_month'' AS period_start_month,
    info ->> ''period_end_input_free'' AS period_end_input_free,
    info ->> ''period_start_input_free'' AS period_start_input_free,
    info ->> ''to_medicalInstitutionCd'' AS to_medicalInstitutionCd,
    info ->> ''from_medicalInstitutionCd'' AS from_medicalInstitutionCd
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
  ORDER BY
    period_start_date DESC)
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no ASC, period_start_date DESC),
    ''in_out'' , in_out,
    ''reason'' , reason,
    ''to_course'' , to_course,
    ''to_doctor'' , to_doctor,
    ''disp_order'' , disp_order,
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , from_course,
    ''from_doctor'' , from_doctor,
    ''move_in_out'' , move_in_out,
    ''to_facility'' , to_facility,
    ''period_start'' , period_start,
    ''from_facility'' , from_facility,
    ''course_is_free'' , course_is_free,
    ''doctor_is_free'' , doctor_is_free,
    ''period_end_day'' , period_end_day,
    ''period_end_year'' , period_end_year,
    ''facility_is_free'' , facility_is_free,
    ''period_end_month'' , period_end_month,
    ''period_start_day'' , period_start_day,
    ''period_start_date'' , period_start_date,
    ''period_start_year'' , period_start_year,
    ''period_start_month'' , period_start_month,
    ''period_end_input_free'' , period_end_input_free,
    ''period_start_input_free'' , period_start_input_free,
    ''to_medicalInstitutionCd'' , to_medicalInstitutionCd,
    ''from_medicalInstitutionCd'' , from_medicalInstitutionCd) AS new_data
  FROM data_info
)
UPDATE pat_unique 
SET
  in_out_visit_history_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報', '2020-05-25 18:21:40.841', '2021-12-24 17:59:06.44', NULL);
