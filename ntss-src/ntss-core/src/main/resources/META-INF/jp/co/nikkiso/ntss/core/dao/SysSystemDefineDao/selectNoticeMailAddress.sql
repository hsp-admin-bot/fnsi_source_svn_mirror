select
  value::json->>'e_mail_address'
from
  sys_system_define
where
  ctl_no = '6'
and
  service_cd = '000'
;