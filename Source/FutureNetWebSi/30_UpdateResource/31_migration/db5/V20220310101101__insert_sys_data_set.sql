INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-60, '	WITH report_send_post AS (
	SELECT
		info ->> ''key2'' AS key2,
		COALESCE ( NULLIF ( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS 
	VALUE
  FROM
		mst_coop_ini AS ini
		CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
	WHERE
		facility_cd = @facilityCd
		AND is_del = ''0'' 
		AND info ->> ''key1'' = ''REPORT_SEND'' 
	) 
SELECT 
COALESCE((select VALUE FROM report_send_post WHERE key2=''REPORT_POST''),'''') as report_post,
COALESCE((select VALUE FROM report_send_post WHERE key2=''EXECUTION_POST''),'''') as execution_post', 2, '[{}]', '0', '{"applications": [4]}', NULL, '連携で送信する報告部署・実施部署', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
