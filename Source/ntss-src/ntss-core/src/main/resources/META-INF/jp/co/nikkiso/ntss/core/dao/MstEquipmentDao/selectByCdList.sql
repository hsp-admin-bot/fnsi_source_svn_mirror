select
  /*%expand "A" */*
from
  mst_equipment A
where
  is_del = '0'
/*%if equipList.size() > 0 */
  and equipment_cd in /* equipList */(null)
/*%end*/
order by
  equipment_cd
;
