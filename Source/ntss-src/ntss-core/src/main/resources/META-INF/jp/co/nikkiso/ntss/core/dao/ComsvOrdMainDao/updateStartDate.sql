update ord_main
set
  rst_dialysis_state = /*param.dialState*/0,
  rst_start_date = /*param.startDate*/'1970/01/01 00:00:00',
  rst_input_class = 1,
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1
;