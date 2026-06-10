update pat_main
set
  is_del = '1',
  wheel_chair_cd = null,
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/null
;