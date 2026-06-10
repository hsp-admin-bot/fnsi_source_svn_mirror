select
  exam_main_cd,
  pat_id,
  to_char(result_exam_date, 'YYYY-MM-DD') as date,
  (case when pat_exam ->> 'item_cd' = /*params.get("examItemX")*/null then pat_exam ->> 'result' else null end) exam_item_result_x,
  (case when pat_exam ->> 'item_cd' = /*params.get("examItemY")*/null then pat_exam ->> 'result' else null end) exam_item_result_y
from pat_exam_main pem
cross join lateral
  json_array_elements (pem.exam_result_info :: json) pat_exam
where (pat_exam ->> 'item_cd' = /*params.get("examItemX")*/null
or pat_exam ->> 'item_cd' = /*params.get("examItemY")*/null)
/*%if params.get("resultExamDateFrom") != null*/
and to_char(result_exam_date, 'YYYY-MM-DD') >= /*params.get("resultExamDateFrom")*/null
/*%end*/
/*%if params.get("resultExamDateTo") != null*/
and to_char(result_exam_date, 'YYYY-MM-DD') <= /*params.get("resultExamDateTo")*/null
/*%end*/
/*%if regOrderClassList.size() != 0*/
and reg_order_class in /*regOrderClassList*/(null)
/*%end*/
/*%if patId != null*/
and pat_id = /*patId*/null
/*%else*/
and pat_id in /*patList*/(null)
/*%end*/
and facility_cd = /*params.get("facilityCd")*/null
AND is_del = '0'
order by pat_id asc, result_exam_date desc
