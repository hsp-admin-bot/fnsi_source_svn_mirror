select
  /*%expand "A" */*
from
  ord_main A
where
  A.pat_id = /*patIdList*/null
  and A.facility_cd = /*facilityCd*/null
  and rst_start_date < /*startDate*/null
  and rst_weight_info is not null
order by
  A.rst_start_date desc
limit 1
;
