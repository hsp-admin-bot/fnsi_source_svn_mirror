UPDATE
  ord_main
SET
  is_confirm = '1'
  , rst_dialysis_state = '6'
  , up_date = current_timestamp
WHERE
  ord_no = /* ordNo */'0'
;
