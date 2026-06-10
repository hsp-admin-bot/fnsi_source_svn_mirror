DELETE FROM "ntss"."sys_data_set" where "sql_cd" IN (1209,1210);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1209, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
UPDATE pat_main 
SET charge_staff_info = jsonb_set(
		(CASE WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1''
			THEN COALESCE(NULLIF(jsonb_build_array (
					array (
						(
							SELECT
								* 
							FROM
								( SELECT jsonb_array_elements ( charge_staff_info ) j FROM pat_main WHERE is_del = ''0'' AND pat_id = @patId AND facility_cd = ''@facilityCd'') AS A 
							WHERE
								( j ->> ''is_main'' ) :: TEXT = ''1'' 
						) 
					) 
				)->0, ''[]''), jsonb_build_array (json_build_object(''ctl_no'', ''1'', ''is_main'', ''1'', ''staff_cd'', '''', ''is_charge'', ''0'', ''disp_order'', '''', ''is_puncture'', '''')))
			ELSE ''[]''
		END) 
		, ''{0,staff_cd}''
		, ''@chargeStaffInfo.indicatorStaffCd''
		, true
	)
WHERE
  is_del = ''0'' 
  AND pat_id = @patId 
  AND facility_cd = ''@facilityCd'' ', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の新規', '2022-06-17 06:29:02.276', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (1210, 'WITH take_cource_info AS ( 
  SELECT
    1 AS order_no
    , CASE TRIM(ini_info ->> ''value'') 
      WHEN '''' THEN COALESCE(NULLIF(TRIM(ini_info ->> ''default_v''), ''''), ''0'') 
      ELSE TRIM(ini_info ->> ''value'') 
      END AS take_cource_flg 
  FROM
    mst_coop_ini AS ini 
    CROSS JOIN LATERAL json_array_elements(ini.coop_ini_info ::json) AS ini_info 
  WHERE
    ini.is_del = ''0'' 
    AND ini.facility_cd = ''@facilityCd'' 
    AND TRIM(ini_info ->> ''key1'') = ''PATIENTRCV_XML'' 
    AND TRIM(ini_info ->> ''key2'') = ''IND_DOCTOR_FLG'' 
  UNION 
  SELECT
    2 AS order_no
    , ''0'' AS take_cource_flg 
  ORDER BY order_no ASC LIMIT 1
)
UPDATE pat_main 
SET charge_staff_info =
	Case WHEN (SELECT take_cource_flg FROM take_cource_info) = ''1'' AND ''@chargeStaffInfo.isMain'' = ''1''
	    THEN charge_staff_info
		ELSE (CASE ''@chargeStaffInfoFlg'' 
					WHEN '''' 
					THEN ''@chargeStaffInfoValue'' 
					ELSE charge_staff_info || ''[{"ctl_no":"@nextCtlNo2", "disp_order":"@chargeStaffInfo.dispOrder", "staff_cd":@chargeStaffInfo.staffCd, "is_main":"@chargeStaffInfo.isMain", "is_charge":"@chargeStaffInfo.isCharge", "is_puncture":"@chargeStaffInfo.isPuncture"}]'' :: jsonb 
			END)
	END
WHERE
is_del = ''0'' 
AND pat_id = @patId 
AND facility_cd = ''@facilityCd''	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(受信用)富士通の患者プロファイル_患者基本情報の修正', '2022-06-13 02:07:03.922', CURRENT_TIMESTAMP, NULL);
