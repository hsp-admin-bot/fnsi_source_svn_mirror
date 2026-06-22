select
  /*%expand "A" */*
from
  mst_pat_memo A
where
  /*%if params.facilityCd != null */
  facility_cd = /* params.facilityCd*/'0'
  /*%end */
order by pat_memo_no asc
;
