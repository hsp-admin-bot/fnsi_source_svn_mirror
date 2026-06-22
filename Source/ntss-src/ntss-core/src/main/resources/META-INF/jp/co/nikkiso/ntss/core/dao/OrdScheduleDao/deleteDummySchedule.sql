delete from
  ord_schedule
where
  is_dummy = '1'
and
  ord_no in /* ordNoList */(null)
;