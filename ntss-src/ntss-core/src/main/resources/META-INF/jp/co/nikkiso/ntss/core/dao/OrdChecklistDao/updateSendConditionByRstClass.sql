UPDATE
  ord_checklist
SET
  rst_class = 1
WHERE
  ord_no = /*ordNo*/0
and
  rst_class = 0
and
  is_del = '0'
and
  is_disp = '1'
;