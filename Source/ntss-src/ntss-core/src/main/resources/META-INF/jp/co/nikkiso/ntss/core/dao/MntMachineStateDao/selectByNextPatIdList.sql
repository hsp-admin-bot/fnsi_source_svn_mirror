select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.facility_cd = /*facilityCd*/'1'
and
  A.next_patid in /*nextPatIdList*/(null)
;
