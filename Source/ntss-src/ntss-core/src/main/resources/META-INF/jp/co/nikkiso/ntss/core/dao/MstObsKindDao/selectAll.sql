select
  /*%expand "A" */*
from
  mst_obs_kind A
where
  A.facility_cd = /*facilityCd*/'000000'
and
 A.is_disp = '1'
and
 A.is_del = '0'
;
