DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7103);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7103, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dialysis_difficulty_cd'')::text, ''is_dial_diff''::text], ''"1"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)', '2020-05-25 18:21:40.841',CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd", "replace_var": "@dialysis_difficulty_cd"}]');