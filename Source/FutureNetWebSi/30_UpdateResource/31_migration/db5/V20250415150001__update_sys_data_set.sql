DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307063;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307065;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307066;
DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307064;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307063, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )

 select distinct
    @ordNo as ord_no,
	@key0 as key0,
	@facilityCd as facility_cd,
    ''15'' AS detail_id
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''10'', ''11'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307065, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 
 select distinct
    @ordNo as ord_no,
	@key0 as key0,
	@facilityCd as facility_cd,
    ''16'' AS detail_id
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''9'')', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307066, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 , treatment_item_value as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
 )
select
    ROW_NUMBER() over(
        order by
            code :: text
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(ord_main_info.name, 256) as name,
    null as count,
    null as unit,
    null as cutoff
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''9'')
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);
INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307064, 'with ord_main_info as(
    select
        ord_addition_info ->> ''cd'' as code,
        ord_addition_info ->> ''name'' as name
    from
        ord_main
        cross join lateral json_array_elements(ord_main.addition_info :: json) ord_addition_info
    where
        ord_main.ord_no = @ordNo
        and is_del = ''0''
 )
 , treatment_item_value as(
    select
        coalesce(
            nullif(info ->> ''value'', ''''),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
        cross join lateral json_array_elements(ini.coop_ini_info :: json) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''MST''
        and info ->> ''key2'' = ''ADDITION_IN_HOSPITAL_CD_NO''
 )
select
    ROW_NUMBER() over(
        order by
            code :: text
    ) AS seq_no,
    (
        case
            (
                select
                    value
                from
                    treatment_item_value
            )
            when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
            when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
            when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
        end
    ) as code,
    left(ord_main_info.name, 256) as name,
    null as count,
    null as unit,
    null as cutoff
 from
    ord_main_info,
    mst_addition
 where
    ord_main_info.code = mst_addition.addition_cd :: text
    and mst_addition.addition_class in (''10'', ''11'')
 ', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', current_timestamp, NULL);