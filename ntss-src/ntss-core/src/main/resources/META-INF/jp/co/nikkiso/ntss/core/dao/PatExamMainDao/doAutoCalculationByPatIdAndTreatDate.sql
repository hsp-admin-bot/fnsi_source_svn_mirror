select
  A.exam_main_cd
from pat_exam_main A
where
  pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
  to_char(A.result_exam_date, 'YYYY-MM-DD') >= /*treatDateFrom*/'2018-02-20'
/*%end*/
/*%if treatDateTo != null */
  and
  to_char(A.result_exam_date, 'YYYY-MM-DD') <= /*treatDateTo*/'2018-02-20'
/*%end*/
and
  exam_status = '1'
and
  is_del = '0'
order by
  reg_exam_date asc
;
