select
  /*%expand "A" */*
from
  mst_alarm_notification A
where
  A.destination_facility_cd=/*destinationFacilityCd*/'000000'
and
  is_disp = '1'
and
  is_del = '0'
;
