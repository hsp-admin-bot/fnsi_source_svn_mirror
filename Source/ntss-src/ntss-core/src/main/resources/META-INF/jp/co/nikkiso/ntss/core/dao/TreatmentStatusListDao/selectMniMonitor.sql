select
  /*%expand "A" */*
from
  mni_monitor A
where
  A.facility_cd = /*facilityCd*/'1'
  and
  A.machine_type_cd = /*machineTypeCd*/'1'
  and
  A.machine_serial = /*machineSerial*/'1'
/*%if occurDate != null */
  and
  A.occur_date > /*occurDate*/'1900/01/01 00:00:00'
/*%end*/
order by
  A.occur_date desc
fetch first row only
;
