update ord_main
set
  rst_dialysis_state = /*param.dialState*/0,
  rst_end_date = /*param.endDate*/'1970/01/01 00:00:00',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1
;