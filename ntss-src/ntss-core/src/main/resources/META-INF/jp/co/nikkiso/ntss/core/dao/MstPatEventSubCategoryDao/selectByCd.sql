select
  /*%expand "A" */*
from
  mst_pat_event_sub_category A
where
  category_cd = /*subCategoryCd*/1
and
  is_disp = '1'
and
  is_del = '0'
;
