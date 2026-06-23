DELETE FROM "ntss"."sys_data_set" where "sql_cd" = -110;
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-110, 'WITH 
	A AS ( 
	SELECT (((rst_cond_info -> ''26'' ->> ''value'' )::FLOAT + (rst_cond_info -> ''28'' ->> ''value'')::FLOAT))::TEXT AS anti_coagulant_amount
	FROM ord_main 
	WHERE ord_no = @ordNo 
	),
 B AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_setting 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''ANTI_COAGULANT_SETTING'' 
	AND info ->> ''key2'' = ''0'' 
	) 
SELECT B.default_setting,
(CASE A.anti_coagulant_amount::FLOAT >= 1
	WHEN true THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	ELSE
		(
		CASE B.default_setting
	WHEN ''0'' THEN
		LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
	WHEN ''1'' THEN
		LPAD(''0'' || split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 8, '' '')
  END
	)
END
) AS calculate_one_shot_amount
FROM A,B
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
