select
  /*%expand "A" */*
from
  mnt_device_edge_state A
where
  A.facility_cd = /*facilityCd*/'000000'
/*%if -1 != deviceEdgeNo */
and
  A.device_edge_no = /*deviceEdgeNo*/1
/*%end*/
;