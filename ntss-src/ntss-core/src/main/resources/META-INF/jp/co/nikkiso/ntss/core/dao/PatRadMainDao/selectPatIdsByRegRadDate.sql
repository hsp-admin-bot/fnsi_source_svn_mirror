SELECT DISTINCT pat_id
FROM  pat_rad_main
WHERE to_char(reg_rad_date, 'YYYYMMDD')  = /*date*/NULL AND is_del = '0'
AND facility_cd = /*facilityCd*/NULL