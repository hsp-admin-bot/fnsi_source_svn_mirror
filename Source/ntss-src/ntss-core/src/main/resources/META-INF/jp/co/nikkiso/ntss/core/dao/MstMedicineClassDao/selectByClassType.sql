SELECT
  /*%expand "A" */*
FROM
  mst_medicine_class A
WHERE
  A.class_type = /* classType */'0'
AND
  A.facility_cd = /* facilityCd */null
AND
  A.is_disp = '1'
AND
  A.is_del = '0'
;
