SELECT
  *
FROM
  sys_coop_journal
WHERE
  facility_cd = /* facilityCd */'999999'
AND
  direction = 'R'
AND
  ana_result = '1'
AND
  coop_result = '9'
AND
  is_del = '0'
AND 
  current_timestamp > in_ana_date + interval '1 minute' * /*waitMinutes*/1
ORDER BY ctl_no ASC
LIMIT 1
;