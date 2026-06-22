update pat_event
set
  is_del = '1'
where
  facility_cd = /*facilityCd*/NULL
AND
  pat_id = /*patId*/1
AND
  pat_event_cd in /* patEventCds */(0)
