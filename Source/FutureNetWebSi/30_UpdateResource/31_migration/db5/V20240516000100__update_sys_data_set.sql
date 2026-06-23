DELETE FROM "ntss"."sys_data_set" where sql_cd in (202);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (202, 'select a.dialysis_conunt,translate(a.treat_week, ''1234567'', ''月火水木金土日'') AS treat_week from (SELECT COUNT
	( treat_date ) AS dialysis_conunt,
string_agg (DISTINCT
	treat_week||'''', '''' ) AS treat_week	from 
ord_main 
	WHERE
		facility_cd = @facilityCd
		AND pat_id = @patId
		AND treat_date BETWEEN to_char( CAST ( @fromDate AS TIMESTAMP ), ''YYYYMMDD'' ) 
		AND to_char( CAST ( @fromDate AS TIMESTAMP ) :: TIMESTAMP + ''6 day'', ''YYYYMMDD'' ) 
GROUP BY
	pat_id) as a', 2, '[{"preview": "5", "can_calc": "0", "data_code": "dialysis_conunt", "data_name": "透析パターン回数", "data_type": "decimal", "conv_table": [], "data_class": "透析パターン", "field_name": "dialysis_conunt", "disp_format": "0", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}, {"preview": "月", "can_calc": "0", "data_code": "treat_week", "data_name": "透析パターン曜日", "data_type": "string", "conv_table": [], "data_class": "透析パターン", "field_name": "treat_week", "disp_format": "", "data_category": "指示", "facility_table": "", "facility_filter_type": "0"}]', '0', '{"applications": [1]}', '{"classes": [1, 2, 3, 9]}', '指示：透析パターン', '2021-12-16 17:10:00', CURRENT_TIMESTAMP, NULL);
