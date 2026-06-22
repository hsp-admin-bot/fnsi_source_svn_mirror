update ord_main
set
  rst_return_home_date = /*returnHomeDate*/null,
  rst_dialysis_state = /*state*/null,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;