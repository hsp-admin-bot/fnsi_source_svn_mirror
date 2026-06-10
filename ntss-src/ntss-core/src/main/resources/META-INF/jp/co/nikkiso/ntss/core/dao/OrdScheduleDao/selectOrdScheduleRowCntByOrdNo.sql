select
  count(*)
from
  ord_schedule
where facility_cd = /*facilityCd*/''
  and ord_no = /* ordNo */null
;
