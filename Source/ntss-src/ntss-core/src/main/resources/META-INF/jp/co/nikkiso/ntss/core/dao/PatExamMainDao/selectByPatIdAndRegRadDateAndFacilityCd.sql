SELECT
  /*%expand "A"*/*
FROM pat_exam_main A
WHERE A.is_del = '0'
AND A.pat_id = /* patId */null
AND to_char(A.reg_exam_date,'YYYY-MM-DD') = /* regExamDate */null
AND A.facility_cd = /* facilityCd */null
