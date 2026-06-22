SELECT
  /*%expand*/*
FROM
  sys_coop_no
WHERE
  ctl_no < 0
AND
  is_del = '0'
AND
  coop_version = /* coopVersion */''
