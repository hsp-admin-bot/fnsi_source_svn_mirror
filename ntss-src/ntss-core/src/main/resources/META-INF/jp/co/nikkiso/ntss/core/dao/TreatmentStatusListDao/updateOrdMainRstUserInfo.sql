update ord_main
set
  rst_puncture_user_info = /*rst_puncture_user_info*/'{}',
  rst_charge_user_info = /*rst_charge_user_info*/'{}',
  rst_return_user_info = /*rst_return_user_info*/'{}',
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0
;