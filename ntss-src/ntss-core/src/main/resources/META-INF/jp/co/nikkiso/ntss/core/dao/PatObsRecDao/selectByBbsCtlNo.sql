select
  /*%expand "A" */*
from
  pat_obs_rec A
where
  A.bbs_ctl_no = /*bbsCtlNo*/null
and
  is_newest = '1'
and
  is_del = '0'
;
