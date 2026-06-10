SELECT date(reg_rad_date) AS date,
       count(DISTINCT pat_id) AS number_of_pat
FROM pat_rad_main
WHERE date(reg_rad_date) >= /*startDate*/NULL
  AND date(reg_rad_date) <= /*endDate*/NULL
  AND is_del = '0'
  AND facility_cd = /*facilityCd*/NULL
GROUP BY date(reg_rad_date)