update pat_main
set
  acceptance_status_info = acceptance_status_info ||
  ('{"class": "' || /*param.acceptanceStatusInfo*/'0' || '"}') :: jsonb,
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  pat_id = /*param.patId*/1
;
