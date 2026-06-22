SELECT /*%expand */*
 FROM pat_event
WHERE facility_cd = /*facilityCd*/null
  AND pat_id = /*patId*/null
  AND event_start_date = /*eventStartDate*/''
  AND is_del  = '0'
;
