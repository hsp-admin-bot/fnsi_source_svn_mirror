delete from "sys_data_set" where "sql_cd" = 1705;
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1705, 'WITH data_new_info AS (
  SELECT 
    null AS ctl_no,
    NULLIF(''@inOutClass'', '''') :: TEXT AS in_out, 
    null AS reason,
    null AS to_course,
    null AS to_doctor,
    0 AS disp_order,
    null AS period_end,
    NULLIF(''@facilityCd'', '''') AS facility_cd,
    null AS from_course,
    null AS from_doctor,
    (CASE ''@inOutClass'' WHEN ''0'' THEN  ''6'' WHEN ''1'' THEN ''4'' ELSE ''6'' END) :: TEXT AS move_in_out,
    null AS to_facility,
    ''@syoriDate'' AS period_start,
    null AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    null AS period_end_day,
    null AS period_end_year,
    ''0'' AS facility_is_free,
    null AS period_end_month,
    SUBSTR(''@syoriDate'', 7, 2) AS period_start_day,
    ''@syoriDate'' AS period_start_date,
    SUBSTR(''@syoriDate'', 1, 4) AS period_start_year,
    SUBSTR(''@syoriDate'', 5, 2) AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    null AS to_medicalInstitutionCd,
    null AS from_medicalInstitutionCd
) 
, current_new_data AS (
  -- 当日を含む過去の最新データを取得する
  SELECT
    ((info->>''in_out'')::TEXT) AS in_out
    , info->>''period_start'' AS period_start
    , ((info->>''ctl_no'')::TEXT) AS ctl_no
  FROM
    pat_unique patu
    CROSS JOIN LATERAL json_array_elements ( patu.in_out_visit_history_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
    AND info->>''period_start'' <= ''@syoriDate''
  ORDER BY info->>''period_start'' DESC, ((info->>''ctl_no'') :: INTEGER) DESC LIMIT 1
)
, data_exists_info AS (
  SELECT
    1 AS order_no
    , ''1'' AS exists_flag 
  FROM
    current_new_data
  WHERE
    in_out = ''@inOutClass''
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
    AND is_del = ''0'' )
, json_data AS (
  SELECT json_build_object(
    ''ctl_no'', row_number() over(order by order_no DESC, ctl_no ASC),
    ''in_out'' , (in_out :: INTEGER),
    ''reason'' , reason,
    ''to_course'' , (to_course :: INTEGER),
    ''to_doctor'' , (to_doctor :: INTEGER),
    ''disp_order'' , (disp_order :: INTEGER),
    ''period_end'' , period_end,
    ''facility_cd'' , facility_cd,
    ''from_course'' , (from_course :: INTEGER),
    ''from_doctor'' , (from_doctor :: INTEGER),
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
  AND (SELECT exists_flag FROM data_exists_info) = ''0'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_固有情報_入外・転入出情報(死亡以外)', '2020-05-25 18:21:40.841', CURRENT_TIMESTAMP, NULL);
