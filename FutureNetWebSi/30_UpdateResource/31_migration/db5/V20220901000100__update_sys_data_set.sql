DELETE  FROM sys_data_set WHERE sql_cd IN (-132);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-132, 'WITH ord_main_data AS ( 
    SELECT (((ind_cond_info -> ''26'' ->> ''value'' )::FLOAT + (ind_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount, pat_id
    FROM ord_main 
    WHERE ord_no = @ordNo
)
, ini_data AS (
SELECT COALESCE
    ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
    mst_coop_ini AS ini
    CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
    facility_cd = @facilityCd
 
    AND is_del = ''0'' 
    AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
    AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
) 
, dialysis_date AS (
SELECT
  COALESCE ( to_char( to_date(REPLACE(pm.medical_care_info ->> ''dialysis_start_date'', ''/'', ''''), ''YYYYMMDD''), ''YYYYMMDD'' ), '''' ) AS dialysis_start_date
FROM
  pat_main AS pm
WHERE
    pm.pat_id = (SELECT pat_id FROM ord_main_data)
) 
, hospital_date AS (
    SELECT info ->>''period_start_date'' AS hospital_start_date
    FROM 
    (
        SELECT jsonb_array_elements(in_out_visit_history_info) AS info 
        FROM pat_unique 
        WHERE pat_id = (SELECT pat_id FROM ord_main_data)
    ) AS history
    WHERE (info ->>''move_in_out'' = ''1'' OR info ->>''move_in_out'' = ''2'')
    AND info ->>''from_facility'' IS NULL
    AND info ->>''period_start_date'' IS NOT NULL
    ORDER BY info ->>''period_start_date''
    LIMIT 1
)
SELECT dialysis_date.dialysis_start_date, hospital_date.hospital_start_date, ini_data.default_setting,
(CASE ord_main_data.anti_coagulant_amount::FLOAT >= 1
    WHEN true THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    ELSE
        (
        CASE ini_data.default_setting
    WHEN ''0'' THEN
        LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
    WHEN ''1'' THEN
        LPAD(LPAD(split_part((ord_main_data.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
    )
END
) AS calculate_one_shot_amount
FROM ord_main_data, ini_data, dialysis_date, hospital_date', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638', CURRENT_TIMESTAMP, NULL);
