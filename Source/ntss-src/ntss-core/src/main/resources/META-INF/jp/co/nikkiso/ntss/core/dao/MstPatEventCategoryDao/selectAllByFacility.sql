select
  /*%expand "A" */*
from
  mst_pat_event_category A
where
  facility_cd = /*facilityCd*/1
and
  is_del = '0'
-- or EXISTS (select category_cd from pat_event where facility_cd = /*facilityCd*/1 and category_cd = A.category_cd)
;
