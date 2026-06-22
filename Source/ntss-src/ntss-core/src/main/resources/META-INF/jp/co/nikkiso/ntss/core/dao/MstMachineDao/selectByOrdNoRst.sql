select
  /*%expand "MM" */*
from
  ord_main OM
  inner join mst_machine MM
  ON OM.rst_machine_no = MM.machine_no and OM.facility_cd = MM.facility_cd
where
  OM.ord_no = /*ordNo*/null and
  MM.is_del = '0'
;