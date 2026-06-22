select
  /*%expand "A" */*
from
  ord_weight_scale A
where
 A.ord_no = /*ordNo*/461
 and
 A.scale_class = /*scaleClass*/0
 and
 A.scale_mode = /*scaleMode*/1
order by
 A.weight_scale_no desc
limit 1
;