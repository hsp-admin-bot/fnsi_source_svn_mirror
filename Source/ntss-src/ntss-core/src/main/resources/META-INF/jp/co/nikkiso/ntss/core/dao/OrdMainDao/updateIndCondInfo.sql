update ord_main
set
  ind_cond_info = /*indCondInfo*/'{}',
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/null
;
