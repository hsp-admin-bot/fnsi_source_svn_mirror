SELECT
  /*%expand "A" */*
FROM
  pat_exam_main A
WHERE
  A.exam_status = '1'
AND
  A.is_del = '0'
AND
  A.pat_id = /*patId*/0
AND
  A.reg_order_class = /*regOrderClass*/''
AND
  A.result_exam_date = /*resultExamDate*/'1970/01/01 00:00:00'
/*%if exclExamMainCd != null */
AND
  NOT (A.exam_main_cd = /*exclExamMainCd*/0)
/*%end */
