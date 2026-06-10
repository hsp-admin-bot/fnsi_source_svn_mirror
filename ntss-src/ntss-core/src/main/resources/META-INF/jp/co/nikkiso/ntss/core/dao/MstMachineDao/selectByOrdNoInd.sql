select
  /*%expand "MM" */*
from
  ord_main OM
  inner join mst_bed MB
  ON OM.ind_bed_cd = MB.bed_cd and MB.facility_cd = OM.facility_cd
  inner join mst_machine MM
  ON MB.machine_no = MM.machine_no and MM.facility_cd = OM.facility_cd
where
  OM.ord_no = /*ordNo*/null and
  MM.is_del = '0'
;