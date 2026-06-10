SELECT
  /*%expand*/*
FROM
  mnt_facility_cancel_manage
WHERE
  proc_class in ('1', '3', '4')
AND
  is_disp = '1'
AND
  is_del = '0'
AND
  proc_status NOT IN ('C', 'E')
ORDER BY
  ctl_no DESC
;
