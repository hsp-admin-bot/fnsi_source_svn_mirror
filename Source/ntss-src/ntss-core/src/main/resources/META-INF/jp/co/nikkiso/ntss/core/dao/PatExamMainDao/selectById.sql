SELECT
  /*%expand */*
FROM
  pat_exam_main
WHERE
  pat_id = /*patId*/0
AND
  facility_cd = /*facilityCd*/''
AND
  cop_order_no1 = /*copOrderNo1*/0
