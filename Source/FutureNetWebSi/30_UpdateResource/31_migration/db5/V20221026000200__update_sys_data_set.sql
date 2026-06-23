DELETE  FROM "ntss"."sys_data_set" WHERE sql_cd IN (-852,-952,-753,-951,-24,-241,-112,-109);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-852, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
union 
(SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main_restore AS ord 
WHERE  ord.ord_no = @ordNo and 0 = (SELECT count(1) FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo ) ORDER BY ord.del_date desc limit 1)
),


mst_user_authenticator as(
select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
		and ord.ord_no = @ordNo 
union
(
select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main_restore ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
		and ord.ord_no = @ordNo 
		and (select count(1) from ord_main where ord_no = @ordNo )is null  
		order by ord.del_date desc limit 1)
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
select staff_cd,code from((SELECT 
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
		where  ''2'' = (select * from ini_key)
			union

     select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR 
 		(select staff_cd from mst_user_authenticator)= ''''
 		OR  (select staff_cd from mst_user_authenticator) = ''0'') and
 	  ''3'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
 	  AND info ->> ''key1'' = ''DIALYSISSEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''''
 		and (select staff_cd from mst_user_authenticator) != ''0''  and
 	  ''3'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-06 07:49:27.698',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-24, 'with ordnocopy as (
select ord_no ordnocopy  from pat_exam_main where exam_main_cd = @ordNo
),
weekend as( 
select EXTRACT(DOW FROM reg_exam_date)  as reg_exam_date from pat_exam_main where exam_main_cd = @ordNo
),
mst_user_authenticator as(
select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>
(select  (
case when 1 =(select reg_exam_date from weekend )		
then ''Mon'' 
 when 2 =(select reg_exam_date from weekend )		
then ''Tues'' 
 when 3 =(select reg_exam_date from weekend )		
then ''Wednes'' 
 when 4 =(select reg_exam_date from weekend )		
then ''Thurs'' 
 when 5 =(select reg_exam_date from weekend )		
then ''Fri'' 
 when 6 =(select reg_exam_date from weekend )		
then ''Satur'' 
 when 0 =(select reg_exam_date from weekend )		
then ''Sun'' 
END ) as aaa)
)::json->>''disp_user_id'' as staff_cd from mst_kur mst where
facility_cd = @facilityCd
and kur_name = ''午前''
and (select ordnocopy from ordnocopy ) is null
union 
select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main ord where ord.ord_no = (select ordnocopy from ordnocopy ) )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
		and ord.ord_no = (select ordnocopy from ordnocopy )),
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
	AND info ->> ''key2'' = ''DOCTOR_SELECT_MODE'' 
	) 
     select staff_cd,code from((SELECT 
    charge_staff ->> ''staff_cd'' AS staff_cd ,
    0  as code
    FROM
      pat_main AS pm,jsonb_array_elements(pm.charge_staff_info) as charge_staff
    WHERE
      pm.pat_id = 16897
  
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
      select ind_user_id::text as staff_cd, 0 as code from pat_exam_main
  		where  ''2'' = (select * from ini_key)
			and exam_main_cd = @ordNo
  		union

     select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR 
 		(select staff_cd from mst_user_authenticator)= ''''
 		OR  (select staff_cd from mst_user_authenticator) = ''0'') and
 	  ''3'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
 	  AND info ->> ''key1'' = ''DIALYSISSEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''''
 		and (select staff_cd from mst_user_authenticator) != ''0''  and
 	  ''3'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null
        
 		
	
		
		', 2, '[{}]', '0', '{"applications": [4]}', NULL, '富士通）検査依頼ID', '2020-05-11 17:19:24.215', CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-241, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[{}]', '0', '{"applications": [4]}', NULL, '透析予約：施設内職員ID(共通部)取得', '2022-07-08 02:16:54.402',CURRENT_TIMESTAMP, '[{"sql_cd": -24, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -24, "field_name": "code", "replace_var": "@code"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-753, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
),
mst_user_authenticator as(		select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
		and ord.ord_no = @ordNo 
		
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
     select staff_cd,code from((SELECT 
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
  		where  ''2'' = (select * from ini_key)
  		union

     select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR 
 		(select staff_cd from mst_user_authenticator)= ''''
 		OR  (select staff_cd from mst_user_authenticator) = ''0'') and
 	  ''3'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
 	  AND info ->> ''key1'' = ''DIALYSISSEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''''
 		and (select staff_cd from mst_user_authenticator) != ''0''  and
 	  ''3'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null
        
 		
	', 2, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-08 02:16:54.412',CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-951, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[{}]', '0', '{"applications": [4]}', NULL, '透析予約：施設内職員ID(共通部)取得', '2022-07-08 02:16:54.402',CURRENT_TIMESTAMP, '[{"sql_cd": -753, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -753, "field_name": "code", "replace_var": "@code"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-952, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS disp_user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[{}]', '0', '{"applications": [4]}', NULL, '(日机装)ind_dial', '2022-07-08 02:16:54.421', CURRENT_TIMESTAMP, '[{"sql_cd": -852, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -852, "field_name": "code", "replace_var": "@code"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-112, 'select case  when @code = 1 THEN @userId ELSE (select disp_user_id AS user_id
FROM 
    mst_user_authentication 
WHERE 
    user_id::TEXT = @userId
		and @code = 0
		) END;', 1, '[]', '0', '{"applications": [4]}', '{"classes": []}', NULL, '2022-06-11 14:01:34', CURRENT_TIMESTAMP, '[{"sql_cd": -109, "field_name": "staff_cd", "replace_var": "@userId"}, {"sql_cd": -109, "field_name": "code", "replace_var": "@code"}]');
INSERT INTO "ntss"."sys_data_set"("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (-109, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
WHERE  ord.ord_no = @ordNo
),
mst_user_authenticator as(		select (json_array_elements((mst.mst_user_authentication ->> ''data'')::json)->>(select  (
case when 1 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Mon'' 
 when 2 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Tues'' 
 when 3 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Wednes'' 
 when 4 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Thurs'' 
 when 5 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Fri'' 
 when 6 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Satur'' 
 when 7 =(select treat_week from ord_main ord where ord.ord_no = @ordNo )		
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
		and ord.ord_no = @ordNo 
		
), 
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
	facility_cd = @facilityCd

	AND is_del = ''0'' 
	AND info ->> ''key1'' = ''DIALYSISSEND'' 
	AND info ->> ''key2'' = ''DOCTOR_TYPE''  
	) 
     select staff_cd,code from((SELECT 
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
  		where  ''0'' = (select * from ini_key)
  		union

     select  (case when (((select staff_cd  from mst_user_authenticator)is NULL OR 
 		(select staff_cd from mst_user_authenticator)= ''''
 		OR  (select staff_cd from mst_user_authenticator) = ''0'') and
 	  ''2'' = (select * from ini_key))
 		THEN (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
     FROM mst_coop_ini AS ini
     CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
     WHERE
 	  facility_cd = @facilityCd
 	  AND is_del = ''0'' 
 	  AND info ->> ''key1'' = ''DIALYSISSEND'' 
 	  AND info ->> ''key2'' = ''DOCTOR_DEF'' )  
 	  when ((select staff_cd from mst_user_authenticator)is not NULL and
 		(select staff_cd from mst_user_authenticator)!= ''''
 		and (select staff_cd from mst_user_authenticator) != ''0''  and
 	  ''2'' = (select * from ini_key) ) then 
 	  (select staff_cd from mst_user_authenticator)
 		end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null
        
 		
	', 2, '[]', '0', '{"applications": [4]}', '{"classes": []}', '(受信用)日機装)連携設定:医師コード', '2022-06-09 17:05:03',CURRENT_TIMESTAMP, NULL);
