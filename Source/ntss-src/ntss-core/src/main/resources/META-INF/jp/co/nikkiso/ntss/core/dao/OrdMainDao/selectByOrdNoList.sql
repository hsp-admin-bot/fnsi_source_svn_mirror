select
  /*%expand "A" */*
from
  ord_main A
where
  A.ord_no in /*ordNoList*/(null)
order by
  A.treat_date
;