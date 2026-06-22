UPDATE
  ord_checklist
SET
  rst_class = '2'
WHERE
  ord_no = /*ordNo*/0
and
  is_del = '0'
and
  is_disp = '1'
;
