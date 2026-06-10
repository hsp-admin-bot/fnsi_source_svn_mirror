select
  /*%expand "A" */*
from
  mnt_if_edge_manage A
where
  A.ctl_no=/*ctlNo*/'0'
  AND A.is_del='0'
;
