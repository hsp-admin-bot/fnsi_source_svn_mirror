UPDATE "ntss"."sys_data_set" SET "sql" = 
'with  pat_facility as (
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
  case p.reg_order_class
  when ''0'' then ''9''
  else p.reg_order_class
  end as reg_order_class_sort,
  p.exam_main_cd as exam_main_cd,
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
  result_exam_date,infection_cd_order
)

SELECT rt.*, lower || ''~'' || upper as normal_value FROM result_table AS rt;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 29;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'with pat_facility as (
   select facility_cd
   from
     pat_exam_main
   where
     pat_id = @patId limit 1
),
infection_order AS (
  select
    one_json ->> ''code'' as infection_cd,
    json_idx as infection_cd_order
  from
    mst_selector
    cross join lateral jsonb_array_elements(order_settings -> ''items'') with ordinality as tmp(one_json, json_idx)
  where
    facility_cd = (select facility_cd from pat_facility)
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
  p.exam_main_cd as exam_main_cd,
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
    and m.result_exam_date between date_trunc (''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
  order by m.result_exam_date desc
  ) as p
  cross join lateral
  json_array_elements (p.exam_result_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
  left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
ORDER BY
  infection_cd_order,reg_exam_date
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 30;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'with  pat_facility as (
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
  p.exam_main_cd as exam_main_cd,
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
    and m.result_exam_date >= (date_trunc(''day'', @date ::timestamp) - interval ''1 year'')
    order by m.result_exam_date desc
  ) as p
  cross join lateral
    json_array_elements (p.exam_result_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del = ''0'' and item.is_disp =''1''
  left  join  infection_order as inf  on  info->>''item_cd''=inf.infection_cd
order by
  infection_cd_order,reg_exam_date
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 31;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
    and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @date ::timestamp) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 35;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
    and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 36;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  info->>''set_cd'' as item_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
    and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date
    ) p
  cross join lateral
    json_array_elements (p.order_exam_set_info :: json) info
  left outer join
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''') where item.is_del = ''0'' and item.is_disp = ''1''
  limit 100
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 37;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order 
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx ) 
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility ) 
	AND master_physical_name = ''mst_exam_item'' 
	) SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	item.unit AS unit,
	p.reg_exam_date AS reg_exam_date,
	p.reg_order_class,
	p.exam_main_cd as exam_main_cd,
CASE
	
	WHEN item.normal_value_class = ''0'' THEN
	item.normal_value_upper ELSE
CASE
	
	WHEN @patSex = 1 THEN
	item.normal_value_upper_m 
	WHEN @patSex = 2 THEN
	item.normal_value_upper_w ELSE item.normal_value_upper 
END 
	END AS upper,
CASE
		
		WHEN item.normal_value_class = ''0'' THEN
		item.normal_value_lower ELSE
	CASE
			
			WHEN @patSex = 1 THEN
			item.normal_value_lower_m 
			WHEN @patSex = 2 THEN
			item.normal_value_lower_w ELSE item.normal_value_lower 
		END 
		END AS lower 
	FROM
		(
		SELECT
			m.* 
		FROM
			pat_exam_main AS m 
		WHERE
			m.is_del = ''0'' 
			AND jsonb_array_length ( m.order_exam_set_info ) > 0 
			AND m.pat_id = @patId 
			AND m.reg_exam_date BETWEEN date_trunc ( ''day'', @date :: TIMESTAMP ) 
			AND date_trunc ( ''day'', @date :: TIMESTAMP ) + ''1 days - 1 milliseconds'' 
		ORDER BY
			m.reg_exam_date,
			( CASE m.reg_order_class WHEN ''0'' THEN ''a'' ELSE m.reg_order_class END ) 
		) p
		CROSS JOIN lateral json_array_elements ( p.exam_order_info :: json ) info
		LEFT OUTER JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' ) 
		AND item.is_del = ''0'' 
		AND item.is_disp = ''1''
		LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd 
ORDER BY
infection_cd_order;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 46;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx )
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility )
	AND master_physical_name = ''mst_exam_item''
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
  item.unit as unit,
  p.reg_exam_date as reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_upper
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_upper_m
    WHEN @patSex = 2 THEN
      item.normal_value_upper_w
    ELSE
      item.normal_value_upper
    END
  END as upper,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_lower
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_lower_m
    WHEN @patSex = 2 THEN
      item.normal_value_lower_w
    ELSE
      item.normal_value_lower
    END
  END as lower
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end)  
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''') and item.is_del = ''0'' and item.is_disp = ''1''
		LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd 
ORDER BY
infection_cd_order;
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 47;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'WITH pat_facility AS ( SELECT facility_cd FROM pat_exam_main WHERE pat_id = @patId LIMIT 1 ),
infection_order AS (
SELECT
	one_json ->> ''code'' AS infection_cd,
	json_idx AS infection_cd_order
FROM
	mst_selector
	CROSS JOIN lateral jsonb_array_elements ( order_settings -> ''items'' ) WITH ordinality AS tmp ( one_json, json_idx ) 
WHERE
	facility_cd = ( SELECT facility_cd FROM pat_facility ) 
	AND master_physical_name = ''mst_exam_item'' 
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
  item.unit as unit,
  p.reg_exam_date as reg_exam_date,
  p.reg_order_class,
  p.exam_main_cd as exam_main_cd,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_upper
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_upper_m
    WHEN @patSex = 2 THEN
      item.normal_value_upper_w
    ELSE
      item.normal_value_upper
    END
  END as upper,
  CASE WHEN item.normal_value_class = ''0'' THEN
      item.normal_value_lower
  ELSE
    CASE WHEN @patSex = 1 THEN
      item.normal_value_lower_m
    WHEN @patSex = 2 THEN
      item.normal_value_lower_w
    ELSE
      item.normal_value_lower
    END
  END as lower
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_exam_set_info) > 0
      and m.pat_id = @patId
    and m.reg_exam_date >= date_trunc(''day'', @date ::timestamp)
    order by m.reg_exam_date, (case m.reg_order_class when ''0'' then ''a''else m.reg_order_class end) 
    ) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del =''0''  and item.is_disp =''1'' 
	LEFT JOIN infection_order AS inf ON info ->> ''item_cd'':: text = inf.infection_cd 
	ORDER BY
infection_cd_order
	limit 100
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 48;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'SELECT
	info ->> ''item_cd'' AS item_cd,
	item.in_hospital_cd1 AS in_hospital_cd1,
	item.in_hospital_cd2 AS in_hospital_cd2,
	item.in_hospital_cd3 AS in_hospital_cd3,
	item.sbt_cd1 AS sbt_cd1,
	item.sbt_cd2 AS sbt_cd2,
	item.sbt_cd3 AS sbt_cd3,
	info ->> ''item_name'' AS item_name,
	info ->> ''result'' AS RESULT,
	info ->> ''unit'' AS unit,
	info ->> ''freememo'' AS freememo,
	P.result_exam_date AS result_exam_date,
	P.reg_exam_date,
	P.reg_order_class,
	p.exam_main_cd as exam_main_cd,
	info ->> ''upper'' AS UPPER,
	info ->> ''lower'' AS LOWER,
	P.pat_id AS pat_id,
	P.pat_id AS pat_name,
	p.pat_id AS pat_birthday,
	p.pat_id AS pat_age,
	p.pat_id AS pat_sex,
	p.pat_id AS in_out_class,
	p.pat_id AS pat_blood_type_abo_rh
FROM
	(
	SELECT M
		.* 
	FROM
		pat_exam_main AS M 
	WHERE
		M.is_del = ''0'' 
		AND M.exam_status = ''1'' 
		AND M.pat_id in (@patIds)
		AND M.result_exam_date BETWEEN date_trunc( ''day'', @fromDate :: TIMESTAMP ) 
		AND date_trunc( ''day'', @toDate :: TIMESTAMP ) + ''1 days - 1 milliseconds'' 
	ORDER BY
		M.result_exam_date DESC 
	)
	AS P CROSS JOIN LATERAL json_array_elements ( P.exam_result_info :: json ) info
	Inner JOIN mst_exam_item AS item ON info ->> ''item_cd'' = ( item.exam_item_cd || '''' ) 
	AND ((@examItemCd
::text is not null and @examItemCd
::text  <> '''') and (item.exam_item_cd = @examItemCd
))
	AND item.facility_Cd = @facilityCd
	AND item.is_del = ''0'' 
	AND is_disp = ''1'' 
ORDER BY
	pat_id;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 197;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 56;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date between date_trunc(''day'', @fromDate ::timestamp ) and date_trunc(''day'', @toDate ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on mst.is_del = ''0'' and mst.is_disp = ''1'' and info->>''rad_set_cd'' = (mst.rad_set_cd || '''')
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 57;

UPDATE "ntss"."sys_data_set" SET "sql" = 
'select
  p.reg_rad_date,
  p.rad_result_cd,
  info->>''rad_set_name'' as rad_set_name,
  mst.rad_set_abb_name,
  mst.rad_item_info->0->>''ctl_name'' as ctl_name1,
  mst.rad_item_info->0->>''item_cd'' as item_cd1,
  mst.rad_item_info->1->>''ctl_name'' as ctl_name2,
  mst.rad_item_info->1->>''item_cd'' as item_cd2,
  mst.rad_item_info->2->>''ctl_name'' as ctl_name3,
  mst.rad_item_info->2->>''item_cd'' as item_cd3,
  mst.rad_item_info->3->>''ctl_name'' as ctl_name4,
  mst.rad_item_info->3->>''item_cd'' as item_cd4,
  mst.rad_item_info->4->>''ctl_name'' as ctl_name5,
  mst.rad_item_info->4->>''item_cd'' as item_cd5,
  mst.rad_item_info->5->>''ctl_name'' as ctl_name6,
  mst.rad_item_info->5->>''item_cd'' as item_cd6,
  mst.in_hospital_cd1 as in_hospital_cd1,
  mst.in_hospital_cd2 as in_hospital_cd2,
  mst.in_hospital_cd3 as in_hospital_cd3,
  mst.sbt_cd1 as sbt_cd1,
  mst.sbt_cd2 as sbt_cd2,
  mst.sbt_cd3 as sbt_cd3
from(
  select
   m.*
  from
    pat_rad_main as m
  where
    m.is_del = ''0''
    and jsonb_array_length(m.order_rad_set_info) > 0
    and m.pat_id = @patId
    and m.reg_rad_date >= date_trunc(''day'', @date ::timestamp )
    order by m.reg_rad_date
    ) p
  cross join lateral
    json_array_elements (p.order_rad_set_info :: json) info
  left outer join
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''') and mst.is_del = ''0'' and mst.is_disp = ''1''
  limit 100
;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 58;
