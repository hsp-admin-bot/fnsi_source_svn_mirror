/** 検査日付を指定して検査を収集 */
select
  /*%expand "pem" */*
from
  pat_exam_main as pem
where
  pem.pat_id in /* patIds */(null)
  and pem.is_del = '0'
  and pem.reg_order_class in /*regOrderClassList*/('0','1','2')
  and (
    (pem.reg_exam_date between /* fromDate */'' and /* toDate */'' and jsonb_array_length(pem.order_exam_set_info) > 0)
    or
    (pem.result_exam_date between /* fromDate */'' and /* toDate */'' and pem.exam_status = '1')
  )
order by
  pem.reg_exam_date, pem.result_exam_date  NULLS LAST
;
