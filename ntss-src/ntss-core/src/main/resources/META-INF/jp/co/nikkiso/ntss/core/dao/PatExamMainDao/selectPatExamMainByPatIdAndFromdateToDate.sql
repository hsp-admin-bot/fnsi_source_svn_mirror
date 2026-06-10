select
	t1.*
from
	pat_exam_main as t1
where
  /*%if pat_id != null */
  t1.pat_id = /*pat_id */null
  and
  t1.exam_status = '1'
  and
  to_char(t1.reg_exam_date, 'yyyy-MM-dd') >= /*fromDate*/'1950-01-01'
  and
  to_char(t1.reg_exam_date, 'yyyy-MM-dd') <= /*toDate*/'2099-12-31'
  and
  /*%end*/
  t1.is_del = '0'
	ORDER BY t1.reg_exam_date DESC
