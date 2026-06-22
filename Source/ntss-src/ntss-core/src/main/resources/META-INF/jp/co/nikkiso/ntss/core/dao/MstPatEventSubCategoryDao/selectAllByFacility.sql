select
  /*%expand "A" */*
from
  mst_pat_event_sub_category A
where
  facility_cd = /*facilityCd*/1
and
  is_del = '0'
-- or EXISTS (select sub_category_cd from pat_event where facility_cd = /*facilityCd*/1 and sub_category_cd = A.sub_category_cd)
;
