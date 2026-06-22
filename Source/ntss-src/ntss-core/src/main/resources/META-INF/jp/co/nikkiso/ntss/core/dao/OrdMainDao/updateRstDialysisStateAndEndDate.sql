update ord_main
set
  rst_dialysis_state = /*rstDialysisState*/null,
  rst_end_date = /*rstEndDate*/null,
  up_date = CURRENT_TIMESTAMP
where
    ord_no = /*ordNo*/0
;
