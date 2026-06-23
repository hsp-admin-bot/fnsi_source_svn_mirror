delete from ntss.sys_data_set where sql_cd in ('7109', '7110','7113','7114','7115','7116','7117','7118','7119');
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
	AND @dial_diff_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正の現在の日付', '2022-07-07 03:07:10.126', CURRENT_TIMESTAMP, '[{"sql_cd": 7110, "field_name": "dial_diff_cd", "replace_var": "@dial_diff_cd"}, {"sql_cd": 7114, "field_name": "date", "replace_var": "@date"}]');
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
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の透析困難cdの取得', '2022-07-07 03:07:10.131', CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7113, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@ppm_info_dial_diff_cd'')::text, ''reg_date''::text], ''null'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @ppm_info_dial_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の更新日が空です', '2022-07-07 03:07:10.117',CURRENT_TIMESTAMP, '[{"sql_cd": 7119, "field_name": "ppm_info_dial_diff_cd", "replace_var": "@ppm_info_dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7114, 'SELECT to_number( CURRENT_TIMESTAMP :: TEXT, ''9999999999999,9999999999999'' ) AS DATE', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の現在の日付取得', '2022-07-07 03:07:10.113', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7115, 'SELECT
 COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS info_diff_cd
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''1''
	AND info ->> ''dial_diff_cd'' != @dialysis_difficulty_cd :: text
	AND @dialDiffComInfo.ctlNo = ''1''
	union
select ''0'' as info_diff_cd
order by info_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の主透析困難cdの取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7116, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@info_diff_cd'')::text, ''is_main''::text], ''"0"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @info_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の置換主透析困難', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7115, "field_name": "info_diff_cd", "replace_var": "@info_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7117, 'SELECT
 COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS info_dial_diff_cd
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_main'' = ''0''
	AND info ->> ''is_dial_diff'' = ''1''
	AND info ->> ''dial_diff_cd'' != @dialysis_difficulty_cd :: text
	union
select ''0'' as info_dial_diff_cd
order by info_dial_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の透析困難1の取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7118, 'UPDATE pat_personal_main ppm1
 SET
  dial_diff_com_info = 
	CASE
    ''@dialDiffComInfo.dialDiffCd'' 
    WHEN '''' THEN
    ''@dialDiffComInfoValue''
ELSE	jsonb_set(dial_diff_com_info, array[(SELECT ORDINALITY::INT - 1 FROM pat_personal_main ppm2, jsonb_array_elements(dial_diff_com_info) WITH

ORDINALITY WHERE ppm1.pat_id = ppm2.pat_id AND value->>''dial_diff_cd'' = ''@info_dial_diff_cd'')::text, ''is_dial_diff''::text], ''"0"'') 
 END
WHERE  pat_id = @patId 
  AND facility_cd = ''@facilityCd''
  AND	is_del = ''0''
	AND @info_dial_diff_cd != 0', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の置換透析困難', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": 7117, "field_name": "info_dial_diff_cd", "replace_var": "@info_dial_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7119, 'SELECT
 COALESCE ( NULLIF ( info ->> ''dial_diff_cd'', '''' )) AS ppm_info_dial_diff_cd
FROM
	pat_personal_main as ppm
	CROSS JOIN LATERAL json_array_elements (ppm.dial_diff_com_info :: json ) info 
WHERE
	pat_id = @patId 
	AND facility_cd = @facilityCd
	AND is_del = ''0''
	AND info ->> ''is_dial_diff'' = ''0''
  AND info ->> ''reg_date'' is not null
	union
select ''0'' as ppm_info_dial_diff_cd
order by ppm_info_dial_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の日付が空でない透析困難cdの取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[]');
