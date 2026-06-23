DELETE FROM ntss.sys_data_set WHERE sql_cd IN (-132);
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
  COALESCE ( to_char( to_date(REPLACE(pm.medical_care_info ->> ''dialysis_start_date'', ''/'', ''''), ''YYYYMMDD''), ''YYYYMMDD'' ), '''' ) AS dialysis_start_date,
    COALESCE ( to_char( to_date(REPLACE(pm.medical_care_info ->> ''hospital_start_date'', ''/'', ''''), ''YYYYMMDD''), ''YYYYMMDD'' ), '''' ) AS hospital_start_date
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
FROM A, B, C', 2, '[{}]', '0', '{"applications": [4]}', NULL, '汎用）指示）透析条件', '2022-08-18 15:49:19.638', CURRENT_TIMESTAMP, NULL);
