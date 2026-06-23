DELETE FROM "ntss"."sys_data_set" where "sql_cd" = -400002;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400002, 'SELECT
CASE
		@aligh
		WHEN ''0'' THEN
	lpad(substr(hosp_pat_id,0,@len+1), 12,''0'') else rpad(substr(hosp_pat_id,0,@len+1), 12,''0'')
	END AS hosp_pat_id
FROM
	pat_personal_main
WHERE
	is_del = ''0''
	AND pat_id = @patId', 3, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-05-17 08:54:31.638', CURRENT_TIMESTAMP, '[{"sql_cd": -400005, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -400003, "field_name": "aligh", "replace_var": "@aligh"}]');
