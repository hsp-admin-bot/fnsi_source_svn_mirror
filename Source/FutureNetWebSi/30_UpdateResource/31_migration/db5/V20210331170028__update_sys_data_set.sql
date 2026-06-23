	UPDATE sys_data_set 
SET SQL = 'select
  info->>''set_cd'' as set_cd,
  info->>''set_name'' as set_name,
  item.in_hospital_cd1 as in_hospital_cd1,
  item.in_hospital_cd2 as in_hospital_cd2,
  item.in_hospital_cd3 as in_hospital_cd3,
  item.sbt_cd1 as sbt_cd1,
  item.sbt_cd2 as sbt_cd2,
  item.sbt_cd3 as sbt_cd3,
  p.reg_exam_date,
  p.reg_order_class
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
    mst_exam_set as item on info->>''set_cd'' = (item.exam_set_cd || '''')  where item.is_del =''0'' and item.is_disp =''1''
  limit 100
;' 
WHERE
	sql_cd = '37'