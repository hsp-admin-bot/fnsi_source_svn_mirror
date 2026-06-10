DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (1209,1210);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1210, 'UPDATE pat_main 
SET
  up_date = CURRENT_TIMESTAMP
  ,charge_staff_info = jsonb_set(  
      charge_staff_info
      , ''{0,staff_cd}''
      , ''@chargeStaffInfo.indicatorStaffCd''
			, false
    )
  WHERE
  is_del = ''0'' 
  AND pat_id = @patId', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1209, '	SELECT
		facility_cd
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = @facilityCd
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG'' 
		AND TRIM(ini_info ->> ''value'') = ''1'' 
 ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
