DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-108);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, 'WITH abc AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS setting_value 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''INDICATE_TREATMENT'' 
	AND info ->> ''key2'' = ''INDICATE_ORD_CD'' 
	) 	
SELECT
	setting_value,
	(
CASE
	setting_value 
	WHEN ''on'' THEN
	(
SELECT
	( save ->> ''ord_no'' ) 
FROM
	pat_coop_detail AS d
	CROSS JOIN LATERAL json_array_elements ( d.save_2 :: json ) save 
WHERE
	pat_id = @patId ORDER BY reg_date DESC LIMIT 1
	) 
	WHEN ''off'' THEN
NULL 
END 
	) AS ord_no
FROM
	abc;', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
