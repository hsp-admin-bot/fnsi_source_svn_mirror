DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-108);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-108, 'WITH A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS setting_value 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DERECT_ACID_FLG'' 
	),
B AS (SELECT COUNT(*) FROM sys_coop_journal WHERE pat_id = @patId AND ana_result = ''9'' AND coop_result = ''9'')	
	
SELECT
A.setting_value,
(CASE
	WHEN B.count > 0 THEN
	(SELECT
	( save ->> ''ord_no'' ) AS ord_no
	FROM
	pat_coop_detail AS d
  CROSS JOIN LATERAL json_array_elements ( d.save_2 :: json ) save 
  WHERE
  pat_id = @patId 
	AND reg_date < (SELECT rst_start_date FROM ord_main WHERE ord_no = @ordNo)
	ORDER BY reg_date 
	DESC LIMIT 1) 
	ELSE
		NULL
 END) AS ord_no
 FROM A,B
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
