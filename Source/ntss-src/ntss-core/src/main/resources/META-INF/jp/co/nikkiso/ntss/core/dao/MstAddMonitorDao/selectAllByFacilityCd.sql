select
  /*%expand "A" */*
from
  mst_add_monitor A
where
  A.facility_cd = /*facilityCd*/'0'
-- 9312 ADD Sort case
order by
  A.vital_monitor_class
  , A.vital_monitor_item_cd
;
