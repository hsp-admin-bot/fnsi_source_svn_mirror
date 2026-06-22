select
  /*%expand "A" */*
from
  ord_weight_scale A
where
 A.weight_scale_no = /*weightScaleNo*/null
order by
  A.weight_scale_no
;
