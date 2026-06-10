select
  /*%expand "A" */*
from
  mnt_batch_manager A
where
  ctl_no = /*ctlNo*/0
;