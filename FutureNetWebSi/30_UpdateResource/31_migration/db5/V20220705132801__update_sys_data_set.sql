DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-951);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-951, 'SELECT 
    disp_user_id AS disp_user_id 
FROM 
    mst_user_authentication 
WHERE 
    user_id = @userId', 1, '[{}]', '0', '{"applications": [4]}', NULL, '透析予約：施設内職員ID(共通部)取得', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, '[{"sql_cd": -753, "field_name": "staff_cd", "replace_var": "@userId"}]');
DELETE FROM "ntss"."sys_data_set" WHERE "sql_cd" IN (-753);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-753, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd 
	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DEFAULT_DOCTOR'' 
	) 
select staff_cd from ind_user_id
where 
  ''0'' = (select * from ini_key)		
	UNION
		
(SELECT 
 charge_staff ->> ''staff_cd'' AS staff_cd 
  FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId
		AND charge_staff ->> ''is_main'' = ''1''
		and ''1'' = (select * from ini_key)
		order by charge_staff ->> ''ctl_no'' LIMIT 1)
	UNION
	
	select staff_cd from ind_user_id
		where  ''0'' = (SELECT COUNT(charge_staff ->> ''staff_cd'')FROM
    pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
  WHERE
    pm.pat_id = @patId
		AND charge_staff ->> ''is_main'' = ''1'')
		AND ''1'' = (select * from ini_key)', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
