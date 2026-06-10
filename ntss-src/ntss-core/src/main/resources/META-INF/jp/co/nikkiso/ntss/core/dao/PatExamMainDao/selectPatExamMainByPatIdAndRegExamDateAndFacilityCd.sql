SELECT
    pat_id
FROM
     pat_exam_main
WHERE
      pat_id IN /* patIdList */(null)
    AND
      facility_cd = /* facilityCd */null
    AND
      to_char(reg_exam_date,'YYYY-MM-DD') = /* regExamDate */null
    AND
      exam_status = '1'
    AND
      is_del = '0'
