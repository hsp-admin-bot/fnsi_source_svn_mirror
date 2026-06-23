DELETE FROM "ntss"."sys_data_set" where sql_cd in (-66659);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66659, 'SELECT COALESCE
		( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS len 
	FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	WHERE
		facility_cd = @facilityCd 
		AND is_del = ''0'' 
		AND COALESCE ( info ->> ''key0'', '''' ) = @key0 
		AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
		AND info ->> ''key2'' = ''PAT_LENGTH'' 
		LIMIT 1 ', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-06-07 12:13:42.213', CURRENT_TIMESTAMP, NULL);
DELETE FROM "ntss"."sys_data_set" where sql_cd in (-66658);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-66658, 'SELECT COALESCE
	( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS aligh
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info
WHERE
	facility_cd =@facilityCd
	AND is_del = ''0''
	AND COALESCE(info->>''key0'','''') = @key0
	AND info ->> ''key1'' = ''DIALYSISSCHESEND''
	AND info ->> ''key2'' = ''PAT_ALIGN''
	LIMIT 1 ', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '日機装 透析レポート', '2022-05-17 08:54:31.633', CURRENT_TIMESTAMP, NULL);
