select
  /*%expand "A" */*
from
  mnt_client_connect A
where
  A.facility_cd in /*facilityCdList*/(null)
and
  A.server_type = /*serverType*/0
;