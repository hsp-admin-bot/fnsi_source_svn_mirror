select
  /*%expand "A"*/*
from pat_exam_main A
where
  A.pat_id = /* patId */-1
and
  A.reg_exam_date >= /* regExamDateFrom */'1970/01/01 00:00:00'
and
  A.reg_exam_date < /* regExamDateTo */'2199/01/01 23:59:59'
and
  A.is_del = '0'
order by
  A.result_exam_date asc
;
