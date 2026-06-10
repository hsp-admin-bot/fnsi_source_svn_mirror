select
  /*%expand "A" */*
from
  mnt_if_edge_client_connect A
where
    A.facility_cd=/*facilityCd*/'000000'
    and A.if_edge_type=/*ifEdgeType*/0
;
