SELECT
  exam_main_cd
FROM
  pat_exam_main A
WHERE
  A.is_del = '0'
AND
  A.pat_id = /*patId*/0
