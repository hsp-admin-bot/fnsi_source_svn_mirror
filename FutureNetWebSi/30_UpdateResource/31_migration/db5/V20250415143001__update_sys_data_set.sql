DELETE FROM ntss.sys_data_set
WHERE sql_cd IN (-307004);

INSERT INTO sys_data_set (sql_cd, "sql", db_class, detail, can_repeat, use_application, report_class, memo, reg_date, up_date, pre_sql_info) 
VALUES(-307004, 'with ord as (
    select 
    treat_date,
    pat_id
    from ord_main
    where ord_no = @ordNo
)
, present as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') = ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date desc
    limit 1
)
, past as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') < ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date desc
    limit 1
)
, future as (
    select coop_save_no
    from pat_coop_detail, ord
    where TO_CHAR(up_date, ''YYYYMMDD'') > ord.treat_date
    and ord.pat_id = pat_coop_detail.pat_id
    order by up_date asc
    limit 1
)
, final_choice as (
    select coop_save_no from present
    union all
    select coop_save_no from past
    where not exists (select 1 from present)
    union all
    select coop_save_no from future
    where not exists (select 1 from present) and not exists (select 1 from past)
)
select
    pcd.save_2 ->> ''insu_name'' as insurance,
    pcd.save_2 ->> ''insu_no'' as insurance_id
from
    pat_coop_detail pcd
    join final_choice fc on pcd.coop_save_no = fc.coop_save_no
', 2, '[]'::jsonb, '0', '{"applications": [4]}'::jsonb, NULL, NULL, '2023-11-21 23:54:57.716', CURRENT_TIMESTAMP, NULL);
