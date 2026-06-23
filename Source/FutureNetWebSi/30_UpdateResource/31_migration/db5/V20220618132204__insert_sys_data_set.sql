DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7104,7105,7106,7107);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7104, 'SELECT
	dialysis_difficulty_cd 
FROM
	mst_dialysis_difficulty 
WHERE
	@dialDiffComInfo.dialDiffCd = in_hospital_cd_1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7105, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dialysis_difficulty_cd'')::text, ''is_main''::text], ''"1"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dialDiffComInfo.ctl_no = 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7106, 'SELECT
 COALESCE ( NULLIF ( info ->> ''is_main'', '''' )) AS is_main
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''1''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイルの取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7107, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dialysis_difficulty_cd'')::text, ''is_main''::text], ''"1"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dialDiffComInfo.ctl_no = 2', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7106, "field_name": "is_main", "replace_var": "@is_main"}, {"sql_cd": 7104, "field_name": "dialysis_difficulty_cd", "replace_var": "@dialysis_difficulty_cd"}]');
