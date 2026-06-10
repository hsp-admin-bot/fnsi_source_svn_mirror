DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (7111,7112,7113,7109,7110,7114,7107,7104);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7104, 'SELECT dialysis_difficulty_cd as dialysis_difficulty_cd_no FROM mst_dialysis_difficulty WHERE  in_hospital_cd_1 = @dialDiffComInfo.dialDiffCd
union
select 0 as dialysis_difficulty_cd_no
order by dialysis_difficulty_cd_no desc nulls last
limit 1', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7112, 'SELECT
 COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS info_cd
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''1''
	union
select ''0'' as info_cd
order by info_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7114, 'SELECT to_number( CURRENT_TIMESTAMP :: TEXT, ''9999999999999,9999999999999'' ) AS DATE', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7113, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@info_cd'')::text, ''is_main''::text], ''"0"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dialysis_difficulty_cd_no = ''0''
	AND @info_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": 7112, "field_name": "info_cd", "replace_var": "@info_cd"}, {"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd_no"}]');
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
	AND @dialDiffComInfo.ctl_no = 2
	AND @dialysis_difficulty_cd != ''0''
	AND @is_main1 = 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正',CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, '[{"sql_cd": 7106, "field_name": "is_main", "replace_var": "@is_main"}, {"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}, {"sql_cd": 7111, "field_name": "is_main1", "replace_var": "@is_main1"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7109, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@dial_diff_cd'')::text, ''reg_date''::text], ''@date'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @dial_diff_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正',CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7110, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}, {"sql_cd": 7114, "field_name": "date", "replace_var": "@date"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7110, 'select
COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS dial_diff_cd 
from
pat_personal_main AS ppm
 CROSS JOIN LATERAL json_array_elements ( ppm.dial_diff_com_info :: json ) info 
where
     facility_cd = @facilityCd
AND  pat_id = @patId 
AND is_del = ''0''
AND info ->> ''is_dial_diff'' = ''0''
AND  info ->> ''dial_diff_cd'' = @dialysis_difficulty_cd :: text
union
select ''0'' as dial_diff_cd
order by dial_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
 INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7111, 'SELECT
 COALESCE ( NULLIF ( info ->> ''is_main'', '''' )) AS is_main1
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''1''
	union
select ''0'' as is_main1
order by is_main1 desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の取得', CURRENT_TIMESTAMP,CURRENT_TIMESTAMP, NULL);
