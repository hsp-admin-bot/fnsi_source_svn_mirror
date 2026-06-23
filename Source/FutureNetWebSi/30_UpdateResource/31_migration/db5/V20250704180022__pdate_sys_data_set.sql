DELETE FROM sys_data_set WHERE sql_cd IN 
(-1201007);

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-1201007, 'SELECT
CASE
		@aligh
		WHEN ''0'' THEN
	lpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'') else rpad(right(hosp_pat_id,COALESCE(@len, 12)), 12,''0'')
	END AS hosp_pat_id
FROM
	pat_personal_main
WHERE
	is_del = ''0''
	AND pat_id = @patId
	', 3, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, '{"classes": []}'::jsonb, 'SX_患者ID(透析実績)', '2025-05-30 17:21:59.877', CURRENT_TIMESTAMP, '[{"sql_cd": -1201009, "field_name": "len", "replace_var": "@len"}, {"sql_cd": -1201008, "field_name": "aligh", "replace_var": "@aligh"}]'::jsonb);

