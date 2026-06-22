select
  /*%expand "A" */*
from
  mst_medicine A
where
  A.facility_cd = /* facilityCd */null
and
  A.is_del = '0'
/*%if medicineList.size() > 0 */
and
  A.medicine_cd in /* medicineList */(0)
/*%end*/
order by
  A.medicine_cd
;
