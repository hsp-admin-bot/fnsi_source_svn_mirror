DELETE FROM "ntss"."sys_data_set" where "sql_cd" in (-111);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-111, 'SELECT info ->>''period_start'' AS start_date
FROM 
(
	SELECT jsonb_array_elements(in_out_visit_history_info) AS info 
	FROM pat_unique 
	WHERE pat_id = @patId
) AS history
WHERE info ->> ''move_in_out'' = ''1'' 
OR info ->>''move_in_out'' = ''2''
ORDER BY info ->>''period_start''
LIMIT 1', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析実績[送信]当院開始日', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
