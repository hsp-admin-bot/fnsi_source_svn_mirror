update ord_main
set
  weight_scale_no = /*weightScaleNo*/null,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;