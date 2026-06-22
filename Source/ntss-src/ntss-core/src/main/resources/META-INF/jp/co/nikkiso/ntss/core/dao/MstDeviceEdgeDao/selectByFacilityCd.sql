select
  /*%expand*/*
from
  mst_device_edge
where
  facility_cd = /* facilityCd */'000001'
and
  is_disp = '1'
and
  is_del = '0'
order by 
  device_edge_no
;