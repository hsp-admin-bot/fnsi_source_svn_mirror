SELECT
  /*%expand "A"*/*
FROM pat_rad_main_hst A
WHERE A.pat_id = /* patId */null
AND to_char(A.reg_rad_date,'YYYY-MM-DD') = /* regRadDate */null
AND A.facility_cd = /* facilityCd */null
ORDER BY A.up_date DESC LIMIT 1
