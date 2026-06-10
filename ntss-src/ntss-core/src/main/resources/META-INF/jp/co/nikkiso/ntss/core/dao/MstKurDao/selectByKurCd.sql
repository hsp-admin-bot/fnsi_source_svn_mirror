SELECT
  /*%expand "A" */*
FROM
  mst_kur A
WHERE
  kur_cd = /* kurCd */'0'
AND
  is_del = '0'
;
