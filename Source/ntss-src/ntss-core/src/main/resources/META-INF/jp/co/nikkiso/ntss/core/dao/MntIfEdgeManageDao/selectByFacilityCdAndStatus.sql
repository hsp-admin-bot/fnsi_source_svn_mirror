select
  /*%expand "A" */*
from
  mnt_if_edge_manage A
where
  A.facility_cd=/*facilityCd*/'000000'
  AND A.response_status = /*responseStatus*/''
  AND A.is_del = '0';
;
