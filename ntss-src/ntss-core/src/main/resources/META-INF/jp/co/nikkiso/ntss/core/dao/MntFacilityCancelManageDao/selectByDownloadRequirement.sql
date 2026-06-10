SELECT
  /*%expand*/*
FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd=/* facilityCd */''
AND
  proc_class = /* procClass */''
AND
  CAST(st_date AS DATE) = /* baseDate */''
AND
  proc_status = '9'
AND
  is_del = '0'
order by up_date desc
limit 1
;
