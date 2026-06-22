select
  /*%expand "MM" */*
from
  mst_bed MB
  inner join mst_machine MM
  ON MB.machine_no = MM.machine_no and MM.facility_cd = MB.facility_cd
where
  MB.bed_cd = /*bedCd*/null and
  MM.facility_cd = /*facilityCd*/'1' and
  MM.is_del = '0'
;