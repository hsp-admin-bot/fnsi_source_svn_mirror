update ord_weight_scale
set
  weight_scale_status = /*param.weightScaleStatus*/3,
  message = /*param.message*/'00000000',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  weight_scale_no = /*param.weightScaleNo*/1
;