select
  exam_main_cd,
  pat_id,
  result_exam_date,
  exam_result ->> 'item_cd' as item_cd,
  exam_result ->> 'result' as result,
  exam_result ->> 'unit' as unit,
  -- FNSI-add redmine4656 徐 start
  reg_order_class
  -- FNSI-add redmine4656 徐 end
from
  pat_exam_main as pem
CROSS JOIN lateral json_array_elements (pem.exam_result_info :: json) exam_result
where
  pat_id = /*patId*/21
  and exam_status = '1'
  and result_exam_date < /*maxDate*/'2020/02/20'
  /*%if limitDate != null */
  and result_exam_date > /*limitDate*/'1970/01/01'
  /*%end */
  and is_del = '0'
  and exam_result_info is not null
  and exam_result ->> 'item_cd' in /*itemCdList*/('1', '2', '3')
  and exam_result ->> 'result' is not null
  and exam_result ->> 'result' <> ''
order by
  result_exam_date desc
;
