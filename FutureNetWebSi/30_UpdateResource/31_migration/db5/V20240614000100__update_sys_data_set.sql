DELETE FROM "ntss"."sys_data_set" WHERE sql_cd IN (-852);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-852, 'with ind_user_id as (SELECT ord.ind_schedule_user_info ->> ''ind_user_id''  AS staff_cd FROM  ord_main AS ord 
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
case when 1 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Mon'' 
 when 2 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Tues'' 
 when 3 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Wednes'' 
 when 4 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Thurs'' 
 when 5 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Fri'' 
 when 6 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Satur'' 
 when 7 =(select treat_week from ord_main_restore ord where ord.ord_no = @ordNo order by ord.del_date desc limit 1)       
then ''Sun'' 
END ) as aaa))::json->>''disp_user_id'' as staff_cd from ord_main_restore ord, mst_kur mst where ord.ind_kur_cd = mst.kur_cd 
        and ord.ord_no = @ordNo 
        and (select 1 from ord_main where ord_no = @ordNo )is null  
        order by ord.del_date desc limit 1)
), 
ini_key as (SELECT COALESCE ( NULLIF( info ->> ''value'', '''' ), info ->> ''default_v'' ) AS staff_cd 
FROM mst_coop_ini AS ini
CROSS JOIN LATERAL json_array_elements ( ini.coop_ini_info :: json ) info 
WHERE
    facility_cd = @facilityCd
    AND is_del = ''0'' 
    -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
  AND COALESCE(info ->> ''key0'', '''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
    -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
  AND COALESCE(info ->> ''key0'', '''') = @key0
  -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
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
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 start
        AND COALESCE(info ->> ''key0'', '''') = @key0
        -- add #7304 異なる連携の機能を組み合わせて使用するため 王永吉 end
      AND info ->> ''key1'' = ''DIALYSISSCHESEND'' 
      AND info ->> ''key2'' = ''DEFAULT_DOCTOR'' )  
      when ((select staff_cd from mst_user_authenticator)is not NULL and
        (select staff_cd from mst_user_authenticator)!= ''''
        and (select staff_cd from mst_user_authenticator) != ''0''  and
      ''3'' = (select * from ini_key) ) then 
      (select staff_cd from mst_user_authenticator)
        end) as staff_cd,1 as code) Alldoctor where Alldoctor.staff_cd is not null', 2, '[{}]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '(日机装)ind_dial', '2022-07-06 07:49:27.698', CURRENT_TIMESTAMP, NULL);
