select
  /*%expand "A" */*
from
  pat_hhd_pattern A
where
  A.pat_id = /*pat_id*/null
order by
  A.revision desc