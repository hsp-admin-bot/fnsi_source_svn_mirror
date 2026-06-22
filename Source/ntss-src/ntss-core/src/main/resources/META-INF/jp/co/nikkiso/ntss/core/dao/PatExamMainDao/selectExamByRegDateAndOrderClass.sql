SELECT *
FROM pat_exam_main
WHERE
    DATE ( reg_exam_date ) = /* regExamDate */null
  AND pat_id = /* patId */null
  AND facility_cd = /* facilityCd */null
  AND reg_order_class = /* regOrderClass */null
  AND is_del = '0'
ORDER BY is_order desc, reg_exam_date desc;