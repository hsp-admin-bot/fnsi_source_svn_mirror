INSERT INTO "ntss"."sys_data_set" ( "sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info" )
VALUES
	( - 11039, 'SELECT COUNT
		( * ) 
		FROM
		ord_main,
		jsonb_to_recordset ( addition_info ) AS j1 ( cd TEXT, reg_date TEXT, is_enable TEXT ) 
		WHERE
		treat_date BETWEEN @dateFrom 
		AND @dateTo 
		AND is_del = ''0'' 
	AND facility_cd = @facilityCd 
	AND j1.cd = @itemId::text', 2, '[]', '0', '{"applications": []}', '{"classes": []}', 'データリスト', '2021-04-25 16:40:02', '2021-04-25 16:40:02', NULL );