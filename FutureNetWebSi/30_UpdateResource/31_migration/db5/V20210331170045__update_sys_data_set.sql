
		UPDATE sys_data_set 
SET SQL = 'select
  p.reg_rad_date,
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
    mst_rad_set as mst on info->>''rad_set_cd'' = (mst.rad_set_cd || '''')  and mst.is_del =''0'' and mst.is_disp = ''1''
  limit 100
;' 
WHERE
	sql_cd = '58'
	