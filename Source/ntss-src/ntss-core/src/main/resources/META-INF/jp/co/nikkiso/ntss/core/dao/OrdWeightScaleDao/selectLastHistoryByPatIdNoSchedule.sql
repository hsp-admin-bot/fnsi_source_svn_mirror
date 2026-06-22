select
  /*%expand "A" */*
from
  ord_weight_scale A
where
 A.ord_no IS NULL
 and
 A.pat_id = /*patId*/0
order by
 A.weight_scale_no desc
limit 1
;