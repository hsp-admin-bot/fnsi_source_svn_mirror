update pat_event
set
  event_start_date = to_char((to_date(event_start_date,'yyyymmdd') + interval '1 day' *  /*dataNumber*/0)	,'yyyymmdd'),
  event_end_date = to_char((to_date(event_end_date,'yyyymmdd') + interval '1 day' *  /*dataNumber*/0)	,'yyyymmdd')
where
  pat_event_cd = /*patEventCd*/null
