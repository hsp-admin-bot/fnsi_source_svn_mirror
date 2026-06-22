update pat_event
set
 letter_info = /*letter_info*/null::jsonb
where
   pat_event_cd = /*pat_event_cd*/null
;
