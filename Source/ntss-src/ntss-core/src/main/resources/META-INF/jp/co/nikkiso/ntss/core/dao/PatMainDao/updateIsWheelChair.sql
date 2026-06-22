update pat_main
set
  is_wheel_chair = '1',
  wheel_chair_cd = NULL,
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/null
;