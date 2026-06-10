UPDATE
  ord_main
SET
  rst_medi_info = /* mediInfo */'[{}]'
  , up_date = current_timestamp
WHERE
  ord_no = /* ordNo */'0'
;