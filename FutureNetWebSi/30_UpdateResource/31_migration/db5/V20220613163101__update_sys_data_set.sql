DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-105, -108, -110);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-105, 'WITH A AS (
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_in_hospital_cd 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DEPARTMENT_DEF'' 
	) 
SELECT
	(
CASE
	WHEN ( SELECT rst_course_cd FROM ord_main WHERE ord_no = ''657279'' LIMIT 1 ) IS NOT NULL THEN
		CASE
			WHEN (SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo)) IS NULL THEN
				A.default_in_hospital_cd
			ELSE
				(SELECT in_hospital_cd_1 FROM mst_course WHERE course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo))
			END
	ELSE 
		A.default_in_hospital_cd
END 
	) AS in_hospital_cd_1 
FROM
A', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '実績（治療中）：診療科コード @ordNo 使用', '2022-05-27 15:57:30', CURRENT_TIMESTAMP, NULL);
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
	) 
	
SELECT
	setting_value,
	(
CASE
	setting_value 
	WHEN ''1'' THEN
	(
SELECT
	ord.ord_no 
FROM
	ord_main ord
	JOIN (
SELECT
	coop_save_no,
	( save ->> ''ord_no'' ) :: BIGINT AS ord_no 
FROM
	pat_coop_detail AS d
	CROSS JOIN LATERAL json_array_elements ( d.save_2 :: json ) save 
WHERE
	pat_id = @patId 
	) AS detail ON ord.ord_no = detail.ord_no 
WHERE
	pat_id = @patId 
	AND ord.ord_no = @ordNo 
	) 
	WHEN ''0'' THEN
NULL 
END 
	) AS ord_no 
FROM
	A;', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)透析実績：指示診療No取得', '2022-06-07 03:24:08.677', CURRENT_TIMESTAMP, NULL);
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
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''CREATE_NUMBER_FUNCTION'' 
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
		LPAD(LPAD(split_part((A.anti_coagulant_amount::FLOAT*100)::TEXT, ''.'', 1), 3, ''0''), 8, '' '')
  END
	)
END
) AS calculate_one_shot_amount
FROM A,B', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', 'NKK)  透析実績：抗凝固剤総量（単体薬剤）', '2022-06-08 15:38:53', CURRENT_TIMESTAMP, NULL);
