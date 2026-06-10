DELETE FROM
  sys_coop_journal
WHERE
  reg_date < /*lastDate*/null
AND
  facility_cd = /*facilityCd*/null
