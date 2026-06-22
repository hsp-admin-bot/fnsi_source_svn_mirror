select
  /*%expand "A" */*
from
  mnt_client_connect A
where
  A.facility_cd = /*facilityCd*/'000000'
;