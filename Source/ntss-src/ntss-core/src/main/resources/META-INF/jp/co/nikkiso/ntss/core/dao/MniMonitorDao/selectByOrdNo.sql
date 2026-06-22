select
  /*%expand "A" */*
from
  mni_monitor A
where
  A.ord_no = /*ordNo*/'1'
order by
  A.occur_date
;
