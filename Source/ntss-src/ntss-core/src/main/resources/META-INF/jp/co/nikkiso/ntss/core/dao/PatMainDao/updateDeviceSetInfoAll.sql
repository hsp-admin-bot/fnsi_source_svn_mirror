update pat_main
set
  device_set_info = jsonb(/*deviceInfo*/'{}'),
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/'1'