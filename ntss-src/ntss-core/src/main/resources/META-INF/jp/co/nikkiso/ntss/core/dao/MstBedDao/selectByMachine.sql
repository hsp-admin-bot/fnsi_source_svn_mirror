select
  /*%expand "A" */*
from
  mst_bed A
where
  A.facility_cd = /*facilityCd*/'999999'
  and
  A.machine_no = /*machineNo*/0
  and
  A.is_del = '0'
  and
  A.is_disp = '1'
;