update ord_main
set
  rst_cond_send_date = /*param.sendDate*/'1970/01/01 00:00:00',
  rst_accept_date = /*param.sendDate*/'1970/01/01 00:00:00',
  rst_dialysis_state = /*param.dialState*/'1',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1
;
