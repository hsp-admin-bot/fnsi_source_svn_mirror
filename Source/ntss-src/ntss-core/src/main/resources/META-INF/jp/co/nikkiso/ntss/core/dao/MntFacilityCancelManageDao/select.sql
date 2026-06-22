SELECT
  /*%expand*/*
FROM
  mnt_facility_cancel_manage
WHERE
  proc_status IN /* statusList */('0', '2')
AND
  proc_class IN /* procClass */('1')
AND
  st_date <= /* now */NULL
AND
  is_disp = '1'
AND
  is_del = '0'
ORDER BY
  ctl_no
;
