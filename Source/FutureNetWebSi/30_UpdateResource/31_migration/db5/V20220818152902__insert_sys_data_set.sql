DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-132, -400014, -400015);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400015, 'WITH do_data AS (
    SELECT dial_diff_com_info2 ->> ''dial_diff_cd'' AS dial_diff_cd
    FROM pat_personal_main,
     jsonb_array_elements(dial_diff_com_info) AS dial_diff_com_info2
    WHERE dial_diff_com_info2 ->> ''is_dial_diff'' = ''1'' 
    AND pat_id = @patId
)
SELECT
  string_agg(dial_diff_cd :: text, '','') AS dial_diff_cd
FROM
  do_data', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400014, 'with data as (select regexp_split_to_table(@dial_diff_cd, '','') as details)

SELECT dialysis_difficulty_cd AS dial_diff_cd_e, dialysis_difficulty_name AS dial_diff_name_e
FROM mst_dialysis_difficulty, data
WHERE dialysis_difficulty_cd :: text IN (data.details)', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -400015, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-132, 'WITH A AS ( 
    SELECT (((ind_cond_info -> ''26'' ->> ''value'' )::FLOAT + (ind_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount
    FROM ord_main 
    WHERE ord_no = @ordNo
)
, B AS (
SELECT COALESCE
    ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
    facility_cd = @facilityCd
 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, C AS (
SELECT
  COALESCE ( to_char( to_date(pm.medical_care_info ->> ''dialysis_start_date'', ''YYYY/MM/DD''), ''YYYYMMDD'' ), '''' ) AS dialysis_start_date,
    COALESCE ( to_char( to_date(pm.medical_care_info ->> ''hospital_start_date'', ''YYYY/MM/DD''), ''YYYYMMDD'' ), '''' ) AS hospital_start_date
FROM
  pat_main AS pm,
  ord_main AS ord
WHERE
  ord.ord_no = @ordNo and
  pm.pat_id = ord.pat_id
) 
SELECT C.dialysis_start_date, C.hospital_start_date, B.default_setting,
(CASE A.anti_coagulant_amount::FLOAT >= 1
    WHEN true THEN
        LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE B.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM A, B, C', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
