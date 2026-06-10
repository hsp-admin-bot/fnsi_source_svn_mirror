update
  ord_main
set
  is_confirm = case when rst_dialysis_state = '6' then '0' else is_confirm end
  , up_date = CURRENT_TIMESTAMP
where
  ord_no = /*entity.ordNo*/1
;
