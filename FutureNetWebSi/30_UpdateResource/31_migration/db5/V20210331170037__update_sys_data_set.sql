	
	UPDATE sys_data_set 
SET SQL = 'select
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
    order by m.reg_exam_date
	) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
  mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')  and item.is_del =''0''  and item.is_disp =''1'' 
  limit 100  
;' 
WHERE
	sql_cd = '48'