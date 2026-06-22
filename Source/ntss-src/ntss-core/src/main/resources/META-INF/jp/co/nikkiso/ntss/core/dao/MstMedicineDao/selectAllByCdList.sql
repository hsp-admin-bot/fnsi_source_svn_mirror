select
  /*%expand "A" */*
from
  mst_medicine A
where
  is_del = '0'
/*%if medicineList.size() > 0 */
  and medicine_cd in /* medicineList */(null)
/*%end*/
order by
  medicine_cd
;