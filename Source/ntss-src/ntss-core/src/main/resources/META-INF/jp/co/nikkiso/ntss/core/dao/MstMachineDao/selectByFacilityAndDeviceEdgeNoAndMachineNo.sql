select
    /*%expand*/*
from
    mst_machine
where
  facility_cd = /*facilityCd*/'1'
  and device_edge_no = /*deviceEdgeNo*/0
  and machine_no = /*machineNo*/0
;