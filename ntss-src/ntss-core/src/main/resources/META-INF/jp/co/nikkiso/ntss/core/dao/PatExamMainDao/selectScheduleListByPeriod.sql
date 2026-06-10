select
  A.pat_id,
  to_char(A.reg_exam_date, 'YYYYMMDD') as str_exam_date
from
  pat_exam_main A
where
  A.is_del = '0'
and
  A.is_order = '1'
and
  A.facility_cd = /*facilityCd*/null
and
  DATE_TRUNC('DAY', A.reg_exam_date) >= TO_TIMESTAMP(/* startDate */null, 'YYYY/MM/DD')::timestamp
and
  DATE_TRUNC('DAY', A.reg_exam_date) <= TO_TIMESTAMP(/* endDate */null, 'YYYY/MM/DD')::timestamp
and
 order_exam_set_info <> '[]'
;
