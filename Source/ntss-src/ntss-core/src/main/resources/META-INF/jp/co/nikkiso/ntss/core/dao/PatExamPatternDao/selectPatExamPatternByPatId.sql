select
  count(*)
from
  pat_exam_pattern A
where
  A.pat_id = /* patId */null
and
  A.is_del = '0'
;
