update ord_main
set
  rst_dialysis_state = /*rstDialysisState*/null,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;
