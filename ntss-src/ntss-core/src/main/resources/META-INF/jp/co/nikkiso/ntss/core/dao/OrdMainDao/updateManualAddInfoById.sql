update ord_main
set
  addition_info = /* additionInfo */'[]',
  is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/0