update pat_unique
set
  is_del = '1',
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /*patId*/null
;