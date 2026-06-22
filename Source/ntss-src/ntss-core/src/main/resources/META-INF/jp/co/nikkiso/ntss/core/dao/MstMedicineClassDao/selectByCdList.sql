SELECT
  /*%expand "A" */*
FROM
  mst_medicine_class A
WHERE
  A.class_cd IN /* classCdList */('0')
AND
  A.is_del = '0'
;
