select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.facility_cd = /*facilityCd*/'1'
and
  A.next_ord_no is not null
and
  A.next_patid is not null
;
