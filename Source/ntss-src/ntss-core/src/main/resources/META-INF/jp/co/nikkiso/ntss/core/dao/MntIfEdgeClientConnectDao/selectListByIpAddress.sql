select
  /*%expand "A" */*
from
  mnt_if_edge_client_connect A
where
    A.facility_cd=/*facilityCd*/'000000'
    and A.ip_address=/*ip_address*/'0.0.0.0'

;
