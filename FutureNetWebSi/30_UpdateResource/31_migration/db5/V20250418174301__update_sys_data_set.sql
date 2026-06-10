DELETE FROM "ntss"."sys_data_set" where sql_cd in (246,247);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (246, 'with  pat_facility as (
   select facility_cd
   from
    pat_exam_main
   where
     pat_id IN (@patIds) limit 1
),
infection_order AS (

  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order
from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
),
result_table as (
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
	p.pat_id,
  case p.reg_order_class
  when ''0'' then ''9''
  else p.reg_order_class
  end as reg_order_class_sort,
  p.exam_main_cd as exam_main_cd,
  case
		when info->>''upper''::TEXT = ''null'' then ''''
		when info->>''upper''::TEXT is null then ''''
		else info->>''upper''::TEXT end as upper,
  case
		when info->>''lower''::TEXT = ''null'' then ''''
		when info->>''lower''::TEXT is null then ''''
		else info->>''lower''::TEXT end as lower
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id IN (@patIds)
    and m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	  left join   infection_order as inf   on info->>''item_cd''::text=inf.infection_cd
ORDER BY
  result_exam_date,infection_cd_order
)

SELECT rt.*, case when lower = '''' and upper = '''' then '''' else COALESCE(lower, '''') || ''~'' || COALESCE(upper, '''')  end as normal_value FROM result_table AS rt;', 2, '[]', '1', '{"applications": [1]}', '{"classes": [3]}', '検査結果(指定日) @patId @date 複数患者帳票使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (247, 'with  pat_facility as (
  select facility_cd
  from
    pat_exam_main
  where  
    pat_id IN (@patIds) limit 1
),
infection_order AS (
  select
    one_json ->> ''code'' as infection_cd
    , json_idx as infection_cd_order 
  from
    mst_selector 
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd =  (select facility_cd from pat_facility )
    and master_physical_name = ''mst_exam_item''
),
near_day_date AS (
 select
    to_char(m.result_exam_date, ''YYYYMMDD'') as result_exam_date
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id IN (@patIds)
    and m.result_exam_date < date_trunc(''day'', @fromDate ::timestamp) + interval ''1 day''
    and m.result_exam_date >= (date_trunc(''day'', @fromDate ::timestamp) - interval ''1 year'')
    order by m.result_exam_date desc
    limit 1
)
select
  info->>''item_cd'' as item_cd,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  info->>''item_name'' as item_name,
  info->>''result'' as result,
  info->>''unit'' as unit,
  info->>''freememo'' as freememo,
  p.result_exam_date as result_exam_date,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
	p.pat_id,
  info->>''upper'' as upper,
  info->>''lower'' as lower
from (
  select
    m.*
  from
    pat_exam_main as m,near_day_date
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id IN (@patIds)
    and to_char(m.result_exam_date, ''YYYYMMDD'') = near_day_date.result_exam_date
    order by m.result_exam_date desc
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
  left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
order by
  infection_cd_order,reg_exam_date
;', 2, '[]', '1', '{"applications": [1]}', '{"classes": [3]}', '検査結果(指定日以前) @patId @date 複数患者帳票使用', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, NULL);
