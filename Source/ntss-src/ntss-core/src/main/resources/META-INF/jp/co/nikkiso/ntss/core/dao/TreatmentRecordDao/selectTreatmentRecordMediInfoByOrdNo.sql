SELECT
  ord_no
  , treat_date
  , rst_dialysis_state
  , rst_start_date
  , rst_end_date
  , rst_medi_info
  , up_date
  , reg_date
FROM
  ord_main
WHERE
  ord_no = /*ordNo*/1
AND
  is_del = '0'
;
