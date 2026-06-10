
select
  /*%expand "A" */*
from
  mnt_machine_state A
inner join
  mst_machine B
on
  A.facility_cd = B.facility_cd
and
  A.machine_type_cd = B.machine_type_cd
and
  A.machine_serial = B.machine_serial
and
  B.device_edge_no = /*deviceEdgeNo*/1
and
  B.is_del = '0'
inner join
  mst_machine_type C
on
  B.machine_type_cd = C.machine_type_cd
and
  (C.model = '004' or C.model = '005')
where
  A.facility_cd = /*facilityCd*/'999900'
;