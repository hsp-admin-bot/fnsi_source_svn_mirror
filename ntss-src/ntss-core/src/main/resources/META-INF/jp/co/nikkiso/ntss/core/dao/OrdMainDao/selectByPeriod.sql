select
  /*%expand "A" */*
from
  ord_main A
where
  A.pat_id = /*patId*/0
  and A.facility_cd = /*facilityCd*/''
  and to_timestamp(A.treat_date, 'YYYYMMDD') >= to_timestamp(/*searchStartDate*/null, 'YYYY-MM-DD')::timestamp
  and to_timestamp(A.treat_date, 'YYYYMMDD') <= to_timestamp(/*searchEndDate*/null, 'YYYY-MM-DD')::timestamp
order by
  A.treat_date,
  A.ind_treat_start_time
;