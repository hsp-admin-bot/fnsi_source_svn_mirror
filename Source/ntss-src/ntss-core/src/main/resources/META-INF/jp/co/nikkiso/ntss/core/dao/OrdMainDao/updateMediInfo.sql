update ord_main
set
  rst_medi_info = /*mediInfo*/'{}',
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;