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
  A.result_exam_date >= /* startDate */'2199/01/01 23:59:59'
;
