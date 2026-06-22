select
  /*%expand "A" */*
from
  ord_weight_scale A
where
 A.ord_no = /*ordNo*/0
 and
 A.measure_date >= /*today*/'0'::timestamp
 and
 A.measure_date < (/*today*/'0'::timestamp + INTERVAL '1 day')
order by
 A.weight_scale_no desc
limit 1
;