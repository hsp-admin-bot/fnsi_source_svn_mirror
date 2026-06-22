select
  /*%expand "A" */*
from
  mnt_machine_state A
where
  A.pat_id = /*patId*/0
and
  A.facility_cd = /*facilityCd*/'1'
/*%if 0 < nextOrdNoList.size() */
and
  A.next_ord_no in /*nextOrdNoList*/(0)
/*%end*/
;
