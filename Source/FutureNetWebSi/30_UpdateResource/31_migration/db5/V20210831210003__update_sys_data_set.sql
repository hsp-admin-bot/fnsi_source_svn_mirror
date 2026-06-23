delete from "sys_data_set" where "sql_cd"  in (1201,1802,1801);INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1802, 'UPDATE pat_main 
SET taboo_allergy_info =
CASE
    ''@tabooAllergyInfoFlg'' 
    WHEN '''' THEN
    ''@tabooAllergyInfoValue'' ELSE taboo_allergy_info || ''[{"memo":"@tabooAllergyInfo.memo", "ctl_no":"@nextCtlNo3", "content":"@tabooAllergyInfo.content", "disp_order":"@tabooAllergyInfo.dispOrder", "category_class":"@tabooAllergyInfo.categoryClass", "taboo_allergy_cd":"@tabooAllergyInfo.tabooAllergyCd", "taboo_allergy_class":"@tabooAllergyInfo.tabooAllergyClass"}]'' :: jsonb 
  END
  WHERE
    is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd''', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1801, 'UPDATE pat_main 
SET taboo_allergy_info = ''[]'' 
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
INSERT INTO "sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1201, 'select
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
  ) AS next_ctl_no_3
from
  pat_main
where
  is_del = ''0''
and
  pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）レポートファイル名', '2020-05-25 18:21:40.841', '2020-05-25 18:21:46.247', NULL);
