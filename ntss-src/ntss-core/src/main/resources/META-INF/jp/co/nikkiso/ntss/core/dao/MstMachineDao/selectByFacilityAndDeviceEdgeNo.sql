select
  /*%expand*/*
from
  mst_machine
where
  facility_cd = /* facilityCd */'000001'
  /*%if -1 != deviceEdgeNo */
and
  device_edge_no = /* deviceEdgeNo */1
  /*%else*/
and
  device_edge_no in
  (
    select
      device_edge_no
    from
      mst_device_edge
    where
      facility_cd = /* facilityCd */'000001'
    and
      device_edge_no is not null
    and
      is_disp = '1'
    and
      is_del = '0'
  )
  /*%end*/
and
  ip_address is not null
and
  is_disp = '1'
and
  is_del = '0'
order by
  machine_type_cd,
  machine_serial
;