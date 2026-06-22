SELECT
  /*%expand */*
FROM
  pat_rad_main
WHERE
  facility_cd = /* facilityCd */null
AND
  pat_id = /* patId */null
AND
  is_del = '0'
AND
  rad_status = '0'
AND
  reg_rad_date >= /* indStartDate */null
AND
  reg_rad_date <= /* indEndDate */null
;
