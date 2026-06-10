update pat_main
set is_same = '0',
    up_date = CURRENT_TIMESTAMP
where pat_id in /* patIdList */(0)
  and is_same = '1';
