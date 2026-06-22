update ord_main
set
  rst_dialysis_state = /*ordMain.rstDialysisState*/'',
  facility_name = null,
  ind_kur_name = null,
  ind_bed_name = null,
  rst_dw = null,
  rst_fn_dialysis_no = null,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordMain.ordNo*/0
