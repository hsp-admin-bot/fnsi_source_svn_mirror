select
  /*%expand*/*
from
  mst_comsv_setting
order by
  facility_cd,
  device_edge_no;
