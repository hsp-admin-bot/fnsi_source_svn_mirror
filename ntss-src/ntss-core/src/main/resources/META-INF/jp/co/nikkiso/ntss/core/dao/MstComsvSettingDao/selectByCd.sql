select
  /*%expand*/*
from
  mst_comsv_setting
where
  facility_cd = /*facilityCd*/'999999'
and
  device_edge_no = /*deviceEdgeNo*/'99'
;