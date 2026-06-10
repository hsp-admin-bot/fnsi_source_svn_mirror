select
  /*%expand "A" */*
from
  mst_alarm_notification A
where
  A.facility_cd=/*facilityCd*/'000000'
;
