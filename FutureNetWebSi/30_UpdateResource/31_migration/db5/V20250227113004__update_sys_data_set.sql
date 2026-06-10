DELETE FROM sys_data_set WHERE sql_cd IN (9106, 9107);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9106, 'WITH date_info AS (
SELECT CASE
    WHEN ''@dieDate'' != '''' THEN ''@dieDate''
    ELSE TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')
    END date_info
)
INSERT INTO pat_unique(
  pat_id,
  medical_hst_info,
  in_out_visit_history_info,
  physical_info,
  is_del,
  up_date,
  reg_date,
  facility_cd,
  old_up_date_unique
) 
VALUES (
  @patId,
  CASE
    WHEN ''@dieDate'' != '''' THEN
    jsonb_build_array(jsonb_build_object(
          ''memo'',
          null,
          ''ctl_no'',
          1,
          ''die_date'',
          (SELECT date_info FROM date_info),
          ''out_come'',
          ''10'',
          ''course_cd'',
          null,
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          null,
          ''disp_order'',
          0,
          ''disease_day'',
          null,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          null,
          ''disease_year'',
          null,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          null,
          ''disease_month'',
          null,
          ''out_come_date'',
          (SELECT date_info FROM date_info),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          null,
          ''diagnosis_year'',
          null,
          ''diagnosis_month'',
          null,
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          null,
          ''diagnosis_facility_cd'',
          null,
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''0''
          ))
          ELSE ''[]''
          END,
  jsonb_build_array(jsonb_build_object(
      ''ctl_no'',
      1,
      ''in_out'',
      CASE
        WHEN ''@dieDate'' != '''' THEN 2
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN 0
        ELSE 1
      END,
      ''reason'',
      NULL,
      ''to_course'',
      NULL,
      ''to_doctor'',
      NULL,
      ''disp_order'',
      0,
      ''period_end'',
      NULL,
      ''facility_cd'',
      ''@facilityCd'',
      ''from_course'',
      NULL,
      ''from_doctor'',
      NULL,
      ''move_in_out'',
      CASE
        WHEN ''@dieDate'' != '''' THEN ''11''
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN ''6''
        ELSE ''4''
      END,
      ''to_facility'',
      NULL,
      ''period_start'',
      (SELECT date_info FROM date_info),
      ''from_facility'',
      NULL,
      ''course_is_free'',
      ''0'',
      ''doctor_is_free'',
      ''0'',
      ''period_end_day'',
      NULL,
      ''period_end_year'',
      NULL,
      ''facility_is_free'',
      ''0'',
      ''period_end_month'',
      NULL,
      ''period_start_day'',
       SUBSTR((SELECT date_info FROM date_info), 7, 2),
      ''period_start_date'',
      (SELECT date_info FROM date_info),
      ''period_start_year'',
      SUBSTR((SELECT date_info FROM date_info), 1, 4),
      ''period_start_month'',
      SUBSTR((SELECT date_info FROM date_info), 5, 2),
      ''period_end_input_free'',
      ''0'',
      ''period_start_input_free'',
      ''0'',
      ''to_medicalInstitutionCd'',
      NULL,
      ''from_medicalInstitutionCd'',
      NULL
    )),
  CASE
    WHEN ''@physicalInfo.height'' !~ ''^[0-9]+$'' THEN ''[]'' :: jsonb
    WHEN ''@physicalInfo.height''::int = 0 THEN ''[]'' :: jsonb
    ELSE jsonb_build_array(
      jsonb_build_object(
        ''ctl_no'', 1,
        ''exam_date'', CURRENT_DATE :: text,
        ''order_class'', @physicalInfo.orderClass,
        ''height'', TO_CHAR(''@physicalInfo.height''::numeric / 100, ''FM999.0''),
        ''ctr_weight'', NULL,
        ''breast_dia'', NULL,
        ''chest_dia'', NULL,
        ''ctr'', NULL,
        ''dw'', NULL,
        ''indicator_cd'', NULL,
        ''indicator_start_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'', NULL,
        ''pre_scale_upper'', NULL,
        ''pre_scale_lower'', NULL,
        ''facility_cd'', NULL,
        ''inspect_date'', TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'', NULL,
        ''target_weight'', NULL
      )
    )
  END,
  ''0'',
  CURRENT_TIMESTAMP,
  CURRENT_TIMESTAMP,
  ''@facilityCd'',
  NULL
)', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の登録', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, NULL);
INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(9107, 'WITH date_info AS (
SELECT CASE
    WHEN ''@dieDate'' != '''' THEN ''@dieDate''
    ELSE TO_CHAR(CURRENT_TIMESTAMP, ''YYYYMMDD'')
    END date_info
),
coop_height AS(
  SELECT
    CASE
      WHEN ''@physicalInfo.height'' !~ ''^[0-9]+$'' THEN ''.0''
      ELSE TO_CHAR(''@physicalInfo.height''::numeric / 100, ''FM999.0'')
    END AS coop_height
),
latest_element AS(
  SELECT
    pat_id,
    p_info.VALUE AS elem
  FROM
    pat_unique
    CROSS JOIN
      LATERAL jsonb_array_elements(physical_info) AS p_info
  WHERE
    pat_id = @patId
    AND p_info ->> ''height'' IS NOT NULL
  ORDER BY
    p_info ->> ''exam_date'' DESC
  LIMIT 1
),
updated_elements AS(
  SELECT
    pat_id,
    jsonb_agg(
      CASE
        WHEN elem ->> ''exam_date'' = CURRENT_DATE::text AND (SELECT coop_height FROM coop_height) <> ''.0''
        THEN jsonb_set(elem, ''{height}'', (''"'' ||(SELECT coop_height FROM coop_height) || ''"'') ::jsonb)
        ELSE elem
      END
    ) AS updated_data,
    bool_or(
      elem ->> ''exam_date'' = CURRENT_DATE::text
    ) AS has_date,
    bool_or(
      (
        SELECT
          elem ->> ''height''
        FROM
          latest_element
      ) != (SELECT coop_height FROM coop_height) AND (SELECT coop_height FROM coop_height) <> ''.0''
    ) AS is_change,
    MAX(
      (
        elem ->> ''ctl_no''
      )::int
    ) + 1 AS next_ctl_no
  FROM
    pat_unique,
    jsonb_array_elements(physical_info) AS elem
  WHERE
    pat_id = @patId
  GROUP BY
    pat_id
),
final_update AS(
  SELECT
    pat_id,
    CASE
      WHEN has_date
    OR  NOT is_change THEN updated_data
      ELSE updated_data || jsonb_build_array(jsonb_build_object(
          ''ctl_no'',
          next_ctl_no,
          ''exam_date'',
          CURRENT_DATE::text,
          ''order_class'',
          ''@physicalInfo.orderClass'',
          ''height'',
          (
            SELECT
              CASE 
                WHEN (SELECT coop_height FROM coop_height) = ''.0'' THEN NULL
                ELSE (SELECT coop_height FROM coop_height)
              END
          ),
          ''ctr_weight'',
          NULL,
          ''breast_dia'',
          NULL,
          ''chest_dia'',
          NULL,
          ''ctr'',
          NULL,
          ''dw'',
          NULL,
          ''indicator_cd'',
          NULL,
          ''indicator_start_date'',
          TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
          ''memo'',
          NULL,
          ''pre_scale_upper'',
          NULL,
          ''pre_scale_lower'',
          NULL,
          ''facility_cd'',
          NULL,
          ''inspect_date'',
          TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
          ''changer_cd'',
          NULL,
          ''target_weight'',
          NULL
        ))
    END AS final_data
  FROM
    updated_elements
),
in_out_class AS(
  SELECT
    (
      CASE
        WHEN ''@dieDate'' != '''' THEN ''2''
        WHEN ''@medicalCareInfo.wardCd'' = '''' THEN ''0''
        ELSE ''1''
      END
    ) AS in_out
),
inout_ctl_no_calc AS(
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
medi_ctl_no_calc AS(
  SELECT
    COUNT(1) + 1 AS ctl_no
  FROM
    pat_unique
    CROSS JOIN
      jsonb_array_elements(pat_unique.medical_hst_info) AS data_calc
  WHERE
    pat_unique.pat_id = @patId
  AND facility_cd = ''@facilityCd''
  AND is_del = ''0''
  GROUP BY
    pat_unique.pat_id
),
data_new_info AS(
  SELECT
    COALESCE(ctl_no, 1) AS ctl_no,
    in_out AS in_out,
    NULL AS reason,
    NULL AS to_course,
    NULL AS to_doctor,
    0 AS disp_order,
    NULL AS period_end,
    ''@facilityCd'' AS facility_cd,
    NULL AS from_course,
    NULL AS from_doctor,
    (CASE in_out WHEN ''0'' THEN ''6'' WHEN ''1'' THEN ''4'' WHEN ''2'' THEN ''11'' ELSE ''6'' END)::TEXT AS move_in_out,
    NULL AS to_facility,
    (SELECT date_info FROM date_info) AS period_start,
    NULL AS from_facility,
    ''0'' AS course_is_free,
    ''0'' AS doctor_is_free,
    NULL AS period_end_day,
    NULL AS period_end_year,
    ''0'' AS facility_is_free,
    NULL AS period_end_month,
    SUBSTR((SELECT date_info FROM date_info), 7, 2) AS period_start_day,
    (SELECT date_info FROM date_info) AS period_start_date,
    SUBSTR((SELECT date_info FROM date_info), 1, 4) AS period_start_year,
    SUBSTR((SELECT date_info FROM date_info), 5, 2) AS period_start_month,
    ''0'' AS period_end_input_free,
    ''0'' AS period_start_input_free,
    NULL AS to_medicalInstitutionCd,
    NULL AS from_medicalInstitutionCd
  FROM
    in_out_class
    LEFT JOIN
      inout_ctl_no_calc
    ON  true
),
data_exists_info AS(
  SELECT
    1 AS order_no,
    ''1'' AS exists_flag
  FROM
    in_out_class ioc
  WHERE
    ''@ppmInOutClass'' = ioc.in_out
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
  physical_info = CASE
    WHEN (physical_info IS NULL
  OR  physical_info = ''[]'') AND (SELECT coop_height FROM coop_height) <> ''.0''
  THEN jsonb_build_array(jsonb_build_object(
        ''ctl_no'',
        1,
        ''exam_date'',
        CURRENT_DATE::text,
        ''order_class'',
        ''@physicalInfo.orderClass'',
        ''height'',
        (SELECT coop_height FROM coop_height),
        ''ctr_weight'',
        NULL,
        ''breast_dia'',
        NULL,
        ''chest_dia'',
        NULL,
        ''ctr'',
        NULL,
        ''dw'',
        NULL,
        ''indicator_cd'',
        NULL,
        ''indicator_start_date'',
        TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''memo'',
        NULL,
        ''pre_scale_upper'',
        NULL,
        ''pre_scale_lower'',
        NULL,
        ''facility_cd'',
        NULL,
        ''inspect_date'',
        TO_CHAR(CURRENT_DATE, ''YYYYMMDD''),
        ''changer_cd'',
        NULL,
        ''target_weight'',
        NULL
      ))
    ELSE(
      SELECT
        final_data
      FROM
        final_update
    )
  END,
  in_out_visit_history_info = CASE
    WHEN((SELECT exists_flag FROM data_exists_info) = ''0''
    OR  in_out_visit_history_info IS NULL
    OR  in_out_visit_history_info = ''[]''
    ) THEN in_out_visit_history_info || (SELECT new_data FROM json_data)
    ELSE in_out_visit_history_info
  END,
  medical_hst_info = CASE
    WHEN ''@dieDate'' != ''''
      THEN medical_hst_info || jsonb_build_object(
          ''memo'',
          null,
          ''ctl_no'',
          (SELECT ctl_no FROM medi_ctl_no_calc),
          ''die_date'',
          (SELECT date_info FROM date_info),
          ''out_come'',
          ''10'',
          ''course_cd'',
          null,
          ''is_notice'',
          ''0'',
          ''disease_cd'',
          null,
          ''disp_order'',
          (SELECT ctl_no FROM medi_ctl_no_calc) -1,
          ''disease_day'',
          null,
          ''facility_cd'',
          ''@facilityCd'',
          ''disease_date'',
          null,
          ''disease_year'',
          null,
          ''is_diagnosed'',
          ''0'',
          ''diagnosis_day'',
          null,
          ''disease_month'',
          null,
          ''out_come_date'',
          (SELECT date_info FROM date_info),
          ''course_is_free'',
          ''0'',
          ''diagnosis_date'',
          null,
          ''diagnosis_year'',
          null,
          ''diagnosis_month'',
          null,
          ''is_main_disease'',
          ''0'',
          ''diagnostician_cd'',
          null,
          ''diagnosis_facility_cd'',
          null,
          ''diagnostician_is_free'',
          ''0'',
          ''is_confirmation_biopsy'',
          ''0'',
          ''diagnosis_facility_is_free'',
          ''0'',
          ''disease_end_input_free'',
          ''0'',
          ''diagnosis_end_input_free'',
          ''0'',
          ''disease_start_input_free'',
          ''0'',
          ''diagnosis_start_input_free'',
          ''0'',
          ''is_dialysis_underlying_disease'',
          ''0''
          )
    ELSE medical_hst_info
  END
WHERE
  pat_id = @patId
AND facility_cd = ''@facilityCd''
AND is_del = ''0''
AND @is_die = ''0''
;', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(受信用)NECの患者固有情報「身体情報」の更新', '2021-11-23 12:12:12.000', CURRENT_TIMESTAMP, '[{"sql_cd": 1101, "field_name": "is_die", "replace_var": "@is_die"}, {"sql_cd": -100001, "field_name": "in_out_class", "replace_var": "@ppmInOutClass"}]'::jsonb);