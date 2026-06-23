DELETE FROM sys_data_set WHERE sql_cd in(-753,-852);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-753, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DOCTOR_SELECT_MODE'' 
	) 
(SELECT 
 charge_staff ->> ''staff_cd'' AS staff_cd ,
  0  as code
  FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId

		AND charge_staff ->> ''is_main'' = ''1''
		and ''1'' = (select * from ini_key)
		order by charge_staff ->> ''is_main'' asc LIMIT 1
		)
	UNION
	SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd ,
		1 as code
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
	and
	 ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId

		AND charge_staff ->> ''is_main'' = ''1'')
		AND ''1'' = (select * from ini_key)
		UNION
    select staff_cd , 0 as code from ind_user_id
		where  ''2'' = (select * from ini_key)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-08 02:16:54.412',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-852, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
union 
(SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main_restore AS ord 
WHERE  ord.ord_no = @ordNo and 0 = (SELECT count(1) FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo ) ORDER BY ord.del_date desc limit 1)
),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DOCTOR_SELECT_MODE'' 
	) 
(SELECT 
 charge_staff ->> ''staff_cd'' AS staff_cd ,
  0  as code
  FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId

		AND charge_staff ->> ''is_main'' = ''1''
		and ''1'' = (select * from ini_key)
		order by charge_staff ->> ''is_main'' asc LIMIT 1
		)
	UNION
	SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd ,
		1 as code
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
	and
	 ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId

		AND charge_staff ->> ''is_main'' = ''1'')
		AND ''1'' = (select * from ini_key)
		UNION
    select staff_cd , 0 as code from ind_user_id
		where  ''2'' = (select * from ini_key)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-06 07:49:27.698', CURRENT_TIMESTAMP, NULL);
