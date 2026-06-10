UPDATE
  ord_main
SET
  rst_edition = rst_edition + 1
  , rst_is_update_edition = '0'
  , rst_medi_info = /* mediInfo */'[{}]'
  , up_date = current_timestamp
WHERE
  ord_no = /* ordNo */'0'
;
