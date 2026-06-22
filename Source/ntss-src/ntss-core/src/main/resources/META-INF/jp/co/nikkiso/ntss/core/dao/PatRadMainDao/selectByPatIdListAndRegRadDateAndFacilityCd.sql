SELECT
       rad_result_cd
FROM
     pat_rad_main
WHERE
      is_del = '0'
AND
      pat_id IN /* patIdList */(null)
AND
      to_char(reg_rad_date,'YYYY-MM-DD') = /* regRadDate */null
AND
      facility_cd = /* facilityCd */null
