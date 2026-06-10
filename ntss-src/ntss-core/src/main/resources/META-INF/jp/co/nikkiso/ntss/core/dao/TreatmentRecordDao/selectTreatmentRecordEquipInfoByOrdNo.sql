SELECT
  ord_no
  , rst_dialysis_state
  , rst_equip_info
  , up_date
  , reg_date
FROM
  ord_main
WHERE
  ord_no = /*ordNo*/1
AND
  is_del = '0'
;
