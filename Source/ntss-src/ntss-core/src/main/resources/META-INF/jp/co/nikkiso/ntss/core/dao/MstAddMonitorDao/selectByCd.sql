select
  /*%expand "A" */*
from
  mst_add_monitor A
where
  A.vital_monitor_item_cd = /*vitalMonitorItemCd*/'0'
;
