UPDATE "ntss"."sys_data_set" SET "sql" = 'with  pat_facility as (
   select facility_cd    
   from
    pat_exam_main
   where  
     pat_id =  @patId limit 1
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
  info->>''upper'' as upper,
  info->>''lower'' as lower 
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date between date_trunc(''day'', @fromDate ::timestamp) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del =''0'' and is_disp =''1''
	  left join   infection_order as inf   on info->>''item_cd''::text=inf.infection_cd
ORDER BY
  infection_cd_order,reg_exam_date 
;' WHERE "sql_cd" = 29;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with  pat_facility as (
   select facility_cd    
   from
    pat_exam_main
   where  
     pat_id =  @patId limit 1
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
  info->>''upper'' as upper,                                            
  info->>''lower'' as lower                                             
from (                                            
  select                                            
    m.*                                            
  from                                            
    pat_exam_main as m                                            
  where                                            
    m.is_del = ''0''                                            
    and m.exam_status = ''1''                                            
     and m.pat_id = @patId                                           
    and m.result_exam_date between date_trunc (''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp)                                     
              
    order by m.result_exam_date desc                                            
  ) as p                                            
  cross join lateral                                            
  json_array_elements (p.exam_result_info :: json) info                                            
  left outer join                                            
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
	left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
	ORDER BY
  infection_cd_order,reg_exam_date 
	
;                                            
' WHERE "sql_cd" = 30;
UPDATE "ntss"."sys_data_set" SET "sql" = 'with  pat_facility as (
   select facility_cd    
   from
    pat_exam_main
   where  
     pat_id =  @patId limit 1
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
  info->>''upper'' as upper,
  info->>''lower'' as lower 
from (
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and m.exam_status = ''1''
    and m.pat_id = @patId
    and m.result_exam_date < date_trunc(''day'', @date ::timestamp) + ''1 days''
    order by m.result_exam_date desc
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
	left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
	ORDER BY  
  infection_cd_order,reg_exam_date 
  limit 100
;' WHERE "sql_cd" = 31;
