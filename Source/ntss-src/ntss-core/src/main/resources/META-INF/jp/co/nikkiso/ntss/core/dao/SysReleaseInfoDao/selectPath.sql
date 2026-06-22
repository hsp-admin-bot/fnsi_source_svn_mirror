select
  A.path_url
from
  sys_release_info A
where
  A.ctl_no = /* ctl_no */0
and
  A.is_disp = '1'
and
  A.is_del = '0'
