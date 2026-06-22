SELECT
  /*%expand "A"*/*
FROM pat_rad_main A
WHERE A.is_del = '0'
AND A.pat_id = /* patId */null
AND to_char(A.reg_rad_date,'YYYY-MM-DD') = /* regRadDate */null
AND A.facility_cd = /* facilityCd */null
ORDER BY A.up_date DESC LIMIT 1
