select
  A.exam_main_cd,
  A.pat_id,
  A.facility_cd,
  A.reg_order_class,
  CASE A.reg_order_class
    WHEN '1' THEN '透析前'
    WHEN '2' THEN '透析後'
    ELSE 'その他' END AS reg_order_class_name, 
  A.exam_status,
  A.result_exam_date,
  to_char(A.result_exam_date,'yyyymmddHH24MISS') As result_exam_date_name,
  A.result_comment,
  A.exam_result_info
from pat_exam_main A
where
  A.exam_status = '1' 
AND 
  A.is_del = '0'
AND
  jsonb_typeof(A.exam_result_info) = 'array'
AND
  A.exam_result_info <> '[]'
/*%if facilityCd != null */
AND
  A.facility_cd = /* facilityCd */null
/*%end */
/*%if patId != null */
AND 
  A.pat_id = /* patId */null
/*%end */
/*%if null != resultFrom && !resultFrom.isEmpty() && null != resultTo && !resultTo.isEmpty() */
AND
  DATE(A.result_exam_date) BETWEEN /* resultFrom */null AND /* resultTo */null
/*%elseif null != resultFrom && !resultFrom.isEmpty() */
AND
  DATE(A.result_exam_date) >= /* resultFrom */null
/*%elseif null != resultTo && !resultTo.isEmpty() */
AND
  DATE(A.result_exam_date) <= /* resultTo */null
/*%end */
ORDER BY 
/*%if examDateOrder != null && examDateOrder.equals("asc") */
  A.result_exam_date asc, 
/*%elseif examDateOrder != null && examDateOrder.equals("desc") */
  A.result_exam_date desc, 
/*%end */
  case when A.reg_order_class <> '0' then A.reg_order_class end asc,
  A.exam_main_cd desc;
