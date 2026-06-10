SELECT DISTINCT
  A.pat_id
FROM
  pat_exam_main A
WHERE
  exam_status = '1'
  AND
  /*%if facility_cd != null */
    facility_cd = /*facility_cd */1
  AND
/*%end*/
    is_del = '0'
  /*%if startDate != null && startDate != "" */
  AND to_char(result_exam_date, 'yyyy-mm-dd') >= /*startDate */null
  /*%end*/
  /*%if endDate != null && endDate != "" */
  AND to_char(result_exam_date, 'yyyy-mm-dd') <= /*endDate */null
  /*%end*/
ORDER BY
  pat_id ASC
;
