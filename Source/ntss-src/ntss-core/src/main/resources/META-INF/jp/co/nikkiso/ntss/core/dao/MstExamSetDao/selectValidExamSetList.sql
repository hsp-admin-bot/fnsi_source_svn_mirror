SELECT
  /*%expand "A" */*
FROM
  mst_exam_set A
WHERE
  A.facility_cd = /* facilityCd */null
AND
  A.is_del = '0'
ORDER BY
  exam_set_cd;
