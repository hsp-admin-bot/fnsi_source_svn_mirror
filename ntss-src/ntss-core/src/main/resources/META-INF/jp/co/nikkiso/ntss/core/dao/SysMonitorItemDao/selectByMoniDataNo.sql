select
  /*%expand "A" */*
from
  sys_monitor_item A
where
  A.moni_data_no = /*moniDataNo*/'0'
;
