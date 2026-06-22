update pat_main
set
  is_same = /* is_same */null,
  up_date = CURRENT_TIMESTAMP
where
  pat_id in /* patIdList */(0)
;