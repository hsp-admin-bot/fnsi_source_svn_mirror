select
  /*%expand "A" */*
from
  mst_obs_kind A
where
  A.kind_no = /*kindNo*/1
;
