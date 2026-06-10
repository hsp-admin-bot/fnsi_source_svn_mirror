delete from ntss.sys_data_set where sql_cd in ('7105','7107','7115');
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
	AND @info_diff_cd = ''0''
	AND @dialysis_difficulty_cd != ''0''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', '2022-06-18 10:26:27.618',CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}, {"sql_cd": 7115, "field_name": "info_diff_cd", "replace_var": "@info_diff_cd"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (7107, 'WITH  data_info AS (
  SELECT
    info ->> ''is_main'' AS is_main, 
		info ->> ''reg_date'' AS reg_date, 
		info ->> ''dial_diff_cd'' AS dial_diff_cd, 
		info ->> ''is_dial_diff'' AS is_dial_diff
  FROM
    pat_personal_main ppm
    CROSS JOIN LATERAL json_array_elements ( ppm.dial_diff_com_info :: json ) AS info 
  WHERE
    pat_id = @patId 
    AND facility_cd = ''@facilityCd'' 
    AND is_del = ''0'' 
)
, json_data AS (
  SELECT json_build_object(
    ''is_main'', 0::TEXT, 
    ''reg_date'', NULL, 
    ''dial_diff_cd'', dial_diff_cd::INTEGER, 
    ''is_dial_diff'', 0::TEXT
) AS new_data
  FROM data_info
)
UPDATE pat_personal_main 
SET
  dial_diff_com_info = (SELECT array_to_json(ARRAY_AGG(new_data)) FROM json_data)
  , up_date = CURRENT_TIMESTAMP
WHERE
  pat_id = @patId 
  AND facility_cd = ''@facilityCd'' 
  AND is_del = ''0''
	AND '''' = ''@dialDiffComInfo.dialDiffCd''', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の修正', '2022-07-07 03:07:10.122',CURRENT_TIMESTAMP, '[{"sql_cd": 7106, "field_name": "is_main", "replace_var": "@is_main"}, {"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}, {"sql_cd": 7111, "field_name": "is_main1", "replace_var": "@is_main1"}]');
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
	union
select ''0'' as info_diff_cd
order by info_diff_cd desc nulls last
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の主透析困難cdの取得', '2022-07-22 05:24:43.91',CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
