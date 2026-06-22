select
  /*%expand "A" */*
from
  mst_alarm_notification A
where
  A.destination_facility_cd=/*destinationFacilityCd*/'000000'
and
  A.is_disp = '1'
and
  A.is_del = '0'
and
  A.target_machine_record @> ('{"cds":[{"machine_record_cd":"G005"}]}')::jsonb
and
  (A.is_notice_mon = '1'
   or A.is_notice_tue = '1'
   or A.is_notice_wed = '1'
   or A.is_notice_thu = '1'
   or A.is_notice_fri = '1'
   or A.is_notice_sat = '1'
   or A.is_notice_sun = '1')
;