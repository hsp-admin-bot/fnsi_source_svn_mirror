select
  A.exam_pattern_cd,
  A.pat_id,
  A.facility_cd,
  A.fn_pat_id,
  A.reg_exam_date,
  to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date,
  A.reg_order_class,
  A.exam_pattern,
  A.exam_week,
  A.exam_from,
  A.exam_to,
  A.order_exam_set_cd,
  A.is_del,
  A.reg_date,
  A.reg_staff,
  A.up_date,
  A.up_staff,
  1 as status
from pat_exam_pattern A
where
  A.is_del = '0'
  /*%if patIdList.size() != 0 */
  and A.pat_id in /* patIdList */(null)
  /*%end*/
  and A.exam_to >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
order by A.exam_pattern, A.exam_week, A.reg_exam_date
;
