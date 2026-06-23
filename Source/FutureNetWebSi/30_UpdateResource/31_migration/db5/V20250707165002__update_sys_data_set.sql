DELETE FROM sys_data_set
WHERE sql_cd IN (-501004);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-501004, 'WITH dateInfo AS(
  SELECT
    CASE 
       WHEN NULLIF(''@medicalCareInfo.dialysisStartDate'','''') IS NULL THEN NULL
       WHEN ''@medicalCareInfo.dialysisStartDate'' ~ ''^(19|20)\d{2}(0[1-9]|1[0-2])(0[1-9]|[12]\d|3[01])$'' 
            AND (
                 (''@medicalCareInfo.dialysisStartDate'' ~ ''^(19|20)\d{2}02(29)$'' AND SUBSTRING(''@medicalCareInfo.dialysisStartDate'', 1, 4)::int % 4 = 0 AND (SUBSTRING(''@medicalCareInfo.dialysisStartDate'', 1, 4)::int % 100 != 0 OR SUBSTRING(''@medicalCareInfo.dialysisStartDate'', 1, 4)::int % 400 = 0))
                 OR (''@medicalCareInfo.dialysisStartDate'' ~ ''^(19|20)\d{2}(0[13578]|1[02])(0[1-9]|[12]\d|3[01])$'')
                 OR (''@medicalCareInfo.dialysisStartDate'' ~ ''^(19|20)\d{2}(0[469]|11)(0[1-9]|[12]\d|30)$'')
                 OR (''@medicalCareInfo.dialysisStartDate'' ~ ''^(19|20)\d{2}02(0[1-9]|1\d|2[0-8])$'')
            )
       THEN ''@medicalCareInfo.dialysisStartDate''
       ELSE NULL
     END AS inOutDate
),
in_out_ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE((SELECT ctl_no FROM in_out_ctl_no_calc), 1) AS ctl_no,
    ''0'' AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    ''1'' AS move_in_out,
    NULL AS to_facility,
    (SELECT inOutDate FROM dateInfo) AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 7, 2) END AS period_start_day,
    (SELECT inOutDate FROM dateInfo) AS period_start_date,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 1, 4) END AS period_start_year,
    CASE WHEN (SELECT inOutDate FROM dateInfo) IS NULL
THEN NULL
ELSE SUBSTR((SELECT inOutDate FROM dateInfo), 5, 2) END AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
),
in_out_data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    pat_unique
    CROSS JOIN LATERAL
      jsonb_array_elements(pat_unique.in_out_visit_history_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  AND data_calc ->>''move_in_out'' = ''1''
  AND data_calc ->>''period_start_date'' = ''@medicalCareInfo.dialysisStartDate''
  UNION
  SELECT
    2 AS order_no,
    ''0'' AS exists_flag
  ORDER BY
    order_no
  LIMIT 1
),
json_data AS(
  SELECT
    jsonb_build_object(
      ''ctl_no'',
      ctl_no,
      ''in_out'',
      in_out::integer,
      ''reason'',
      reason,
      ''to_course'',
      to_course,
      ''to_doctor'',
      to_doctor,
      ''disp_order'',
      disp_order,
      ''period_end'',
      period_end,
      ''facility_cd'',
      facility_cd,
      ''from_course'',
      from_course,
      ''from_doctor'',
      from_doctor,
      ''move_in_out'',
      move_in_out,
      ''to_facility'',
      to_facility,
      ''period_start'',
      period_start,
      ''from_facility'',
      from_facility,
      ''course_is_free'',
      course_is_free,
      ''doctor_is_free'',
      doctor_is_free,
      ''period_end_day'',
      period_end_day,
      ''period_end_year'',
      period_end_year,
      ''facility_is_free'',
      facility_is_free,
      ''period_end_month'',
      period_end_month,
      ''period_start_day'',
      period_start_day,
      ''period_start_date'',
      period_start_date,
      ''period_start_year'',
      period_start_year,
      ''period_start_month'',
      period_start_month,
      ''period_end_input_free'',
      period_end_input_free,
      ''period_start_input_free'',
      period_start_input_free,
      ''to_medicalInstitutionCd'',
      to_medicalInstitutionCd,
      ''from_medicalInstitutionCd'',
      from_medicalInstitutionCd
    ) AS new_data
  FROM
    data_new_info
)
UPDATE
  pat_unique
SET
  up_date = CURRENT_TIMESTAMP,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM in_out_data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
AND (SELECT inOutDate FROM dateInfo) IS NOT NULL', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)SSIの患者プロファイル(既往歴情報情報)', '2025-06-19 10:57:10.504', CURRENT_TIMESTAMP, NULL);