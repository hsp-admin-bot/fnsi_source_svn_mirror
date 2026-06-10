select
  /*%expand*/*
from
  mst_device_edge
where
  device_edge_no = /*deviceEdgeNo*/'1'
and
  facility_cd = /*facilityCd*/'1'
;
