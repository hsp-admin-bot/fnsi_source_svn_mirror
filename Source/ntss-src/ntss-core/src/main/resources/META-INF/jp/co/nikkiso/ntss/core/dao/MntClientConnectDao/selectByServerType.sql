select
  /*%expand "A" */*
from
  mnt_client_connect A
where
  A.facility_cd = /*facilityCd*/'000001'
and
  A.server_type = /*serverType*/0
;