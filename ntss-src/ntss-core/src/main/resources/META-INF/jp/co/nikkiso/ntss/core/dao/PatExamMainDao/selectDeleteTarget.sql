SELECT
  /*%expand */*
FROM
  pat_exam_main
WHERE
  facility_cd = /* facilityCd */null
AND
  pat_id = /* patId */null
AND
  is_order = '1'
AND
  is_del = '0'
AND
  exam_status = '0'
AND
  result_exam_date IS NULL
AND
  reg_exam_date >= /* indStartDate */null
AND
  reg_exam_date <= /* indEndDate */null
;
