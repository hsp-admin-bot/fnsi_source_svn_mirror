DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (7115);
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
limit 1', 3, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)日機装の患者プロファイル(透析困難情報)の主透析困難cdの取得','2022-08-05 11:01:31.53', CURRENT_TIMESTAMP, '[{"sql_cd": 7104, "field_name": "dialysis_difficulty_cd_no", "replace_var": "@dialysis_difficulty_cd"}]');
