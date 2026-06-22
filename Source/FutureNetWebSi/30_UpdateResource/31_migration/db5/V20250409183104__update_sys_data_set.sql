DELETE FROM ntss.sys_data_set
WHERE sql_cd=-307069;

INSERT INTO ntss.sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-307069, 'with ord_main_info as(
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
,
addition_in_hospital_cd_no as(
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
,
rece_mng_min_id as(
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
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MIN_ID''
)
,
rece_mng_max_id as(
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
        and info ->> ''key1'' = ''PRESCRIPTION_XML_RECE_MNG_INFO''
        and info ->> ''key2'' = ''RECE_MNG_MAX_ID''
)
,
med_admin_unit_wrapper as (
select
	LPAD(@ordNo::text, 8, ''0'') || LPAD((row_number() over (order by cast(code as character varying)) - 1 + rm_min_id.value::numeric )::text, 2, ''0'') as order_units_id,
	(
        case
		(
		select
			value
		from
			addition_in_hospital_cd_no
            )
		when ''1'' then left(mst_addition.in_hospital_cd_1, 20)
		when ''2'' then left(mst_addition.in_hospital_cd_2, 20)
		when ''3'' then left(mst_addition.in_hospital_cd_3, 20)
	end
    ) as code,
	left(ord_main_info.name, 256) as name,
	null as count,
	null as unit,
	null as cutoff,
	1 as seq_no,
	LPAD((row_number() over (order by cast(code as character varying)) - 1 + rm_min_id.value::numeric )::text, 2, ''0'') as order_units_id_suffix
from
	ord_main_info
left join mst_addition on
	ord_main_info.code = cast(mst_addition.addition_cd as character varying)
cross join rece_mng_min_id rm_min_id
cross join rece_mng_max_id rm_max_id
where
	mst_addition.addition_class in (''13'')
	)
	
select
	order_units_id,
	code,
    name,
    count,
	unit,
	cutoff,
	seq_no,
	order_units_id_suffix
from
	med_admin_unit_wrapper
	cross join rece_mng_min_id rm_min_id
	cross join rece_mng_max_id rm_max_id
where
	order_units_id_suffix::numeric between rm_min_id.value::numeric and rm_max_id.value::numeric;', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, '医学管理科情報取得用', current_timestamp, current_timestamp, NULL);