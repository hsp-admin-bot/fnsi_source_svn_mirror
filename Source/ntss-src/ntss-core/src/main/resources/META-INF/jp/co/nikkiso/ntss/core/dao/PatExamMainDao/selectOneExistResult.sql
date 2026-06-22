SELECT
    exam_main_cd,
    result_exam_date,
    exam_result_info
FROM
    pat_exam_main A
WHERE
    A.pat_id = /*patId*/null
AND 
    A.facility_cd = /* facilityCd */null
AND
    DATE(reg_exam_date) = /* regExamDate */null
AND
    reg_order_class = /* regOrderClass */null
AND
    exam_status = '1'
AND
    is_order = '0'
AND
    is_del = '0'
ORDER BY
    reg_exam_date DESC
LIMIT 1
;
