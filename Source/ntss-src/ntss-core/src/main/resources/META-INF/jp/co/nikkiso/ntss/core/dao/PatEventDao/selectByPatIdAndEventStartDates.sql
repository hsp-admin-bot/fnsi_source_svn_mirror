SELECT /*%expand */*
 FROM pat_event
WHERE facility_cd = /*facilityCd*/null
  AND pat_id = /*patId*/null
  AND event_start_date::integer in (
  /*%for date : eventStartDates */
    /*#date*/
     /*%if date_has_next */
       /*# "," */
    /*%end*/
  /*%end*/
  )
  AND is_del  = '0'
;
