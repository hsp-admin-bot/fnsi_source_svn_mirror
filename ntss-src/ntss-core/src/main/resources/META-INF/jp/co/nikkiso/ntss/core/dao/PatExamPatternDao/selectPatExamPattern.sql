select
  /*%expand "A" */*
from
  pat_exam_pattern A
where
  A.pat_id = /* patId */null
and
  A.is_del = '0'
and
  to_char(A.exam_from,'YYYY-MM-DD') <=  /* toDate */null
and
  to_char(A.exam_to,'YYYY-MM-DD') >=  /* fromDate */null
;
