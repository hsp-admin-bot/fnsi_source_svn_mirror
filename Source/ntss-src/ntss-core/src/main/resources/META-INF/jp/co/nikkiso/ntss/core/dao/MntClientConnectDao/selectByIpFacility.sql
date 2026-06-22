select
  /*%expand "A" */*
from
  mnt_client_connect A
where
  A.ip_address = /*ipAddress*/'127.0.0.1'
and
  A.facility_cd = /*facilityCd*/'000000'
;
