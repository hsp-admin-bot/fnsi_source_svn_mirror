DELETE FROM "ntss"."sys_data_set" where "sql_cd" in (-105);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-105, 'WITH A AS(
SELECT
	in_hospital_cd_1
FROM
	mst_course 
WHERE
	course_cd = (SELECT rst_course_cd FROM ord_main WHERE ord_no = @ordNo)
)
SELECT in_hospital_cd_1 FROM A
UNION ALL
SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS in_hospital_cd_1 
FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DEPARTMENT_DEF''
  AND NOT EXISTS(SELECT in_hospital_cd_1 FROM A);', 2, '[{}]', '0', '{"applications": [4]}', '{"classes": []}', '実績（治療中）：診療科コード @ordNo 使用', '2022-05-27 15:57:30', CURRENT_TIMESTAMP, NULL);
