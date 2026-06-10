select
  exam_main_cd,
  result_exam_date,
  reg_order_class
from
  pat_exam_main
where
  pat_id = /*patId*/-1 and
  result_exam_date is not null and
  exam_result_info is not null and
  is_del = '0'
order by
  result_exam_date desc,
  case reg_order_class
    when '0' then '3'
    else reg_order_class
  end desc
limit 12
;