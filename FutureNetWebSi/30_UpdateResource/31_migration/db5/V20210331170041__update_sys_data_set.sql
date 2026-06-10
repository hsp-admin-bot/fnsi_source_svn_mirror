	
	UPDATE sys_data_set 
SET SQL = 'select
  spitz.spitz_name
from(
  select
    m.*
  from
    pat_exam_main as m
  where
    m.is_del = ''0''
	and jsonb_array_length(m.order_exam_set_info) > 0
  	and m.pat_id = @patId
	and m.reg_exam_date between date_trunc(''day'', @date ::timestamp ) and date_trunc(''day'', @date ::timestamp) + ''1 days - 1 milliseconds''
    order by m.reg_exam_date
	) p
  cross join lateral
    json_array_elements (p.exam_order_info :: json) info
  left outer join
    mst_exam_item as item on info->>''item_cd'' = (item.exam_item_cd || '''')   and item.is_del =''0'' and item.is_disp =''1''
  left outer join
    mst_spitz as spitz on item.spitz_cd = spitz.spitz_cd   and spitz.is_del =''0'' and spitz.is_disp =''1''
where
  spitz.spitz_name is not null 
group by
  spitz.spitz_name
;' 
WHERE
	sql_cd = '53'