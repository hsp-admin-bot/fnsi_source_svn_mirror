DELETE FROM sys_data_set
WHERE sql_cd IN (-310014);

INSERT INTO sys_data_set
(sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info)
VALUES(-310014, 'with
min_staff_ctl_no AS (
SELECT min(staff.value ->> ''ctl_no'') AS min_is_main_ctl_no
FROM pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        AND staff.value ->> ''is_main'' = ''1'' 
)
,staff AS (
SELECT 
    staff.value ->> ''staff_cd'' staff_cd
from pat_main 
        CROSS JOIN
            LATERAL json_array_elements(pat_main.charge_staff_info::json) staff
    WHERE
        pat_id = @patId
        and staff.value ->> ''ctl_no'' = (SELECT min_is_main_ctl_no FROM min_staff_ctl_no)
)
,def_doctor AS(
    SELECT
        COALESCE(NULLIF(info ->> ''value'', ''''), info ->> ''default_v'') AS value
    FROM
        mst_coop_ini AS ini
        CROSS JOIN
            LATERAL json_array_elements(ini.coop_ini_info::json) info
    WHERE
        facility_cd = @facilityCd
    AND is_del = ''0''
    AND info ->> ''key0'' = @key0
    AND info ->> ''key1'' = ''EXAM_ORD''
    AND info ->> ''key2'' = ''DEFAULT_DOCTOR''
)
, doctor_data as(
SELECT 
    CASE 
    WHEN (SELECT min_is_main_ctl_no FROM min_staff_ctl_no) IS NULL THEN (SELECT value FROM def_doctor)
    ELSE (SELECT staff_cd FROM staff)
    END AS staff_cd
)
,exam_data as (
    select
        TO_CHAR(
            reg_exam_date,
            ''YYYYMMDD''
        ) as exam_date,
        case
            reg_order_class
    when ''0'' then '' ''
            else reg_order_class
        end as exam_timing,
        order_exam_set_info
    from
        ntss.pat_exam_main
    where
        exam_main_cd = @ordNo ::integer
        --    )
),
output_item as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_ITEM''
)
,
exam_set as(
    select
        exam_set.other_exam_time
    from
        (
            select
                order_exam_set_info
            from
                exam_data
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as exam_set 
                on
        info ->> ''set_cd'' = (
            exam_set.exam_set_cd || ''''
        )
),
before_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''BEFORE_MARGIN''
),
after_margin as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''AFTER_MARGIN''
),
ord_data as(
    select
        ord.ord_no,
        ord.ind_treat_start_time,
        ind_cond_info -> ''1'' ->> ''value'' as plan_dialysis_time
    from
        (
            select
                *
            from
                ord_main
            where
                pat_id = @patId ::integer
                and treat_date = (
                    select
                        exam_date
                    from
                        exam_data
                )
                and is_del = ''0''
            order by
                ind_treat_start_time asc
            limit 1
        ) ord
),
exam_time as (
    select
        (
            select
                ord_no
            from
                ord_data
        ) as ord_no,
        exam_date,
        exam_timing,
        case
            exam_timing
  when ''1'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time - (
                        (
                            select
                                value
                            from
                                before_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            when ''2'' then 
  to_char(
                (
                    (
                        select
                            ind_treat_start_time
                        from
                            ord_data
                    )::time + (
                        (
                            select
                                plan_dialysis_time
                            from
                                ord_data
                        ) || '' minutes''
                    )::interval + (
                        (
                            select
                                value
                            from
                                after_margin
                        ) || '' minutes''
                    )::interval
                ),
                ''HH24MI''
            )
            else (
                select
                    other_exam_time
                from
                    exam_set
            )
        end as exam_time
    from
        exam_data
),
output_in_out as(
    select
        coalesce(
            nullif(
                info ->> ''value'',
                ''''
            ),
            info ->> ''default_v''
        ) as value
    from
        mst_coop_ini as ini
    cross join
            lateral json_array_elements(
            ini.coop_ini_info::json
        ) info
    where
        facility_cd = @facilityCd
        and is_del = ''0''
        and info ->> ''key0'' = @key0
        and info ->> ''key1'' = ''EXAM_ORD''
        and info ->> ''key2'' = ''OUTPUT_IN_OUT''
),
item_set_no as (
    --SELECT info.value ->> ''no'' AS no
    select
        info ->> ''set_cd'' as no
    from
        (
            select
                m.*
            from
                pat_exam_main as m
            where
                m.is_del = ''0''
                and jsonb_array_length(m.order_exam_set_info) > 0
                    and m.exam_main_cd = @ordNo ::integer
        ) p
    cross join lateral json_array_elements(
            p.order_exam_set_info ::json
        ) info
    inner join mst_exam_set as item 
                on
        info ->> ''set_cd'' = (
            item.exam_set_cd || ''''
        )
),
exam_items AS (
select
    item_cd,
    item_name,
    in_hospital_cd1,
    in_hospital_cd2,
    in_hospital_cd3
from
    (
        select
            info ->> ''set_cd'' as seq_no,
            ''6'' as sub_no,
            -- 子（検査項目）
            info ->> ''item_cd'' as item_cd,
            info ->> ''item_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.exam_order_info ::json
            ) info
        join mst_exam_item as item 
            on
            info ->> ''item_cd'' = (
                item.exam_item_cd || ''''
            )
            and 
                case (select value from output_in_out)
                when ''1'' then item.is_in_hospital = ''0''
                when ''2'' then item.is_in_hospital = ''1''
                else true
            end
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''1'' then false
                else true
            end
    union all
        select
            info ->> ''set_cd'' as seq_no,
            ''5'' as sub_no,
            -- 親（検査セット）
            info ->> ''set_cd'' as item_cd,
            info ->> ''set_name'' as item_name,
            item.in_hospital_cd1,
            item.in_hospital_cd2,
            item.in_hospital_cd3
        from
            (
                select
                    m.*
                from
                    pat_exam_main as m
                where
                    m.is_del = ''0''
                    and jsonb_array_length(m.order_exam_set_info) > 0
                        and m.exam_main_cd = @ordNo ::integer
            ) p
        cross join lateral json_array_elements(
                p.order_exam_set_info ::json
            ) info
        left outer join mst_exam_set as item
            on
            info ->> ''set_cd'' = (
                item.exam_set_cd || ''''
            )
        where
            info ->> ''set_cd'' in (
                select
                    no
                from
                    item_set_no
            )
            and 
          case
                (
                    select
                        value
                    from
                        output_item
                )
                when ''2'' then false
                else true
            end
    ) exam_all
order by
    item_cd
)
INSERT INTO ntss.pat_coop_detail(
    facility_cd,
    pat_id,
    save_1,
    save_2,
    is_disp,
    is_del,
    user_id,
    up_date,
    reg_date,
    coop_version
)
SELECT
    @facilityCd,
    @patId::integer,
    ''{"pkg": "MED"}''::jsonb,
    jsonb_build_object(
        ''ord_no'', (SELECT ord_no FROM ord_data),
        ''hosp_pat_id'', LPAD(@hospPatId::text, 12, ''0''),
        ''exam_date'', (SELECT exam_date FROM exam_data), 
        ''exam_timing'', (SELECT exam_timing FROM exam_data),
        ''exam_time'', (SELECT exam_time FROM exam_time),
        ''staff_cd'',(SELECT staff_cd FROM doctor_data),
        ''exam_items'',
        (select jsonb_agg(
            jsonb_build_object(
                    ''exam_cd'',item_cd,
                    ''exam_name'',item_name,
                    ''in_hospital_cd1'',in_hospital_cd1,
                    ''in_hospital_cd2'',in_hospital_cd2,
                    ''in_hospital_cd3'',in_hospital_cd3
                )
            )
            from exam_items
        )::jsonb),
    ''1'',
    ''0'',
    - 1,
    CURRENT_TIMESTAMP,
    CURRENT_TIMESTAMP,
    ''MED''
FROM
    exam_items
    limit 1', 2, '[]'::jsonb, '0', '{"applications": [6]}'::jsonb, NULL, 'Medicom検査依頼実績連携', '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);