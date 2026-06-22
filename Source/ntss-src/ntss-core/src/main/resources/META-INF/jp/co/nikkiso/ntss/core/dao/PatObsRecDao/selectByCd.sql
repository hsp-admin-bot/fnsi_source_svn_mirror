select
  /*%expand "A" */*
from
  pat_obs_rec A
where
  A.obs_rec_no = /*obsRecNo*/1
;
