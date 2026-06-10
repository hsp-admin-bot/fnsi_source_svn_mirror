select
  to_char(reg_exam_date,'yyyyMMdd') as event_start_date,
  exam_result_info as json_value
from
  pat_exam_main
where
  facility_cd = /*facilityCd*/1
and
  pat_id = /*patId*/1
/*%if treatDateFrom != null */
and
  to_char(reg_exam_date,'yyyyMMdd') >= /*treatDateFrom*/'00010101'
/*%end */
/*%if treatDateTo != null */
and
  to_char(reg_exam_date,'yyyyMMdd') <= /*treatDateTo*/'99991231'
/*%end */
and
  is_del = '0'
order by
  reg_exam_date desc
