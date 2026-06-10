update pat_rad_main
set
  is_del = '1',
  up_date = CURRENT_TIMESTAMP
where
  pat_id = /* patId */null
and
  to_char(reg_rad_date,'YYYY/MM/DD') in /* dateList */(null)
;
