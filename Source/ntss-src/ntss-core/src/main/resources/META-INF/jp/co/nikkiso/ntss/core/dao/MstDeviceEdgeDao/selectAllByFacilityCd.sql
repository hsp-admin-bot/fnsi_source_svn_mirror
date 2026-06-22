select
  /*%expand*/*
  ,CASE WHEN is_disp = '0' or is_del = '1' THEN '【削除済み】' || device_name ELSE device_name END as device_name
from
  mst_device_edge
where
  facility_cd = /* facilityCd */'000001'
order by
  device_edge_no
;
