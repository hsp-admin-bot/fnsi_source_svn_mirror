update pat_event
set
  is_del = '1'
where
  pat_event_cd = /*patEventCd*/null
