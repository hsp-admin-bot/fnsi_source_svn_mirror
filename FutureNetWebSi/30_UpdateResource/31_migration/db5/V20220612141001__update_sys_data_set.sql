DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (-109,-112);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-109, 'WITH 
  A AS (
  SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS setting_value 
  FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DOCTOR_TYPE'' 
	),
  B AS (
  SELECT COALESCE
	( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS default_doctor_cd
  FROM
	mst_coop_ini AS ini
	CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
  WHERE
	facility_cd = @facilityCd
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DOCTOR_DEF'' 
	),
	id_list AS (
		SELECT m.user_id
		FROM mst_user AS m 
		WHERE m.user_id IN 
		(
		SELECT (info ->>''staff_cd'')::INT AS staff_cd 
		FROM pat_main AS pat 
		CROSS JOIN LATERAL json_array_elements(charge_staff_info::json)info 
		WHERE pat.pat_id = @patId 
		AND info ->> ''is_main'' = ''1''
		LIMIT 2
		)
		AND m.is_del = ''0''
	)
	
SELECT
	A.setting_value as setting_value , B.default_doctor_cd as default_doctor_cd,
	(
  CASE
	A.setting_value 
	WHEN ''0'' THEN
	( SELECT up_user_id FROM ord_main WHERE ord_no = @ordNo )
	WHEN ''1'' THEN
	  (CASE (SELECT COUNT(*) FROM id_list)
	  WHEN 0 THEN
		NULL
	  ELSE
		(SELECT user_id FROM id_list LIMIT 1)
    END)
END 
	) AS doctor_cd 
FROM
	A,B
	
', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '(受信用)日機装)連携設定:医師コード', '2022-06-09 17:05:03', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-112, 'SELECT
(CASE 
	WHEN @doctorCd IS NOT NULL THEN
		(
		SELECT 
      disp_user_id 
    FROM 
      mst_user_authentication 
    WHERE 
      user_id = @doctorCd
		)
	WHEN @doctorCd IS NULL THEN
		@defaultDoctorCd
END) AS user_id
FROM mst_user_authentication LIMIT 1
', 1, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -109, "field_name": "doctor_cd", "replace_var": "@doctorCd"}, {"sql_cd": -109, "field_name": "default_doctor_cd", "replace_var": "@defaultDoctorCd"}]');
