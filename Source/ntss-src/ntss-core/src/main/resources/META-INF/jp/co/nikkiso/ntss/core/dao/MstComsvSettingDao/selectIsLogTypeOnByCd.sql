select
case
    when lcd_log_type = '0' then false
    when lcd_log_type != '0' then true
end
from
  mst_comsv_setting
where
  facility_cd = /*facilityCd*/'999999'
and
  device_edge_no = /*deviceEdgeNo*/1
and
  is_disp = '1'
and
  is_del = '0'
;
