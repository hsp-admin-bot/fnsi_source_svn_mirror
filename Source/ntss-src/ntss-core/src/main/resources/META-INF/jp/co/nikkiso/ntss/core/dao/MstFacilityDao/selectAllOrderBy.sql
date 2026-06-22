select
  /*%expand*/*
from
  mst_facility
WHERE
  facility_cd NOT IN
    (SELECT
      facility_cd
    FROM
      mnt_facility_cancel_manage
    WHERE
      proc_status IN ('1', '2', '3', '9')
    AND
      proc_class = '1'
    AND is_disp = '1'
    AND is_del = '0')
/*# orderBy */
;
