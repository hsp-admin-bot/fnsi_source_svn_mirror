SELECT *
FROM pat_exam_main
WHERE
    DATE ( reg_exam_date ) = /* regExamDate */null
  AND pat_id = /* patId */null
  AND facility_cd = /* facilityCd */null
  AND is_del = '0';