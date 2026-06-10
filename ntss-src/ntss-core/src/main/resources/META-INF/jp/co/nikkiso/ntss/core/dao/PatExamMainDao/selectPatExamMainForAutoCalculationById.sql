select
  A.exam_main_cd
from pat_exam_main A
where
  pat_id = /*patId*/1
and
  to_char(A.result_exam_date, 'YYYYMMDD') >= /*treatDate*/'20180220'
and
  is_del = '0'
order by
  reg_exam_date asc
;
