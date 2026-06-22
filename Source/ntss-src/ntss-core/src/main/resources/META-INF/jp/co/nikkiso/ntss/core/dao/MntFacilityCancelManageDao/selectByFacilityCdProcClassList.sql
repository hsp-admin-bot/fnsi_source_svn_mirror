SELECT
  /*%expand*/*
FROM
  mnt_facility_cancel_manage
WHERE
  facility_cd = /* facilityCd */''
AND
  proc_class IN /* lstProcClass */(null)
AND
  is_disp = '1'
AND
  is_del = '0'
ORDER BY
  ctl_no DESC
LIMIT
  1
;
