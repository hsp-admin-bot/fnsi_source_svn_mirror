SELECT
  /*%expand "A" */*
FROM
  mst_kur A
WHERE
  A.facility_cd = /* facilityCd */'0'
  AND
  /* currentTime */'000000' between A.kur_start_time and A.kur_end_time
  AND
  A.is_del = '0'
;
