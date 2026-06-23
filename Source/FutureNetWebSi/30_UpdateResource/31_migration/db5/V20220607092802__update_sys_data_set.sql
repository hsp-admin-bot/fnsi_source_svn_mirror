DELETE
FROM
	sys_data_set
WHERE
	sql_cd = -400003;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-400003, 'SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS aligh
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND info ->> ''key1'' = ''DIALYSISSEND''
	AND info ->> ''key2'' = ''PAT_ALIGN''', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-05-17 08:54:31.633', CURRENT_TIMESTAMP, NULL);
