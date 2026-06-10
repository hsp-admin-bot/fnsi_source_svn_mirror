select
  A.ctl_no,
  A.release_date,
  A.title,
  A.system_type,
  A.is_disp,
  A.is_Del
from
  sys_release_info A
where
  A.is_disp = '1'
and
  A.is_del = '0'
order by
  A.release_date desc,
  A.ctl_no
