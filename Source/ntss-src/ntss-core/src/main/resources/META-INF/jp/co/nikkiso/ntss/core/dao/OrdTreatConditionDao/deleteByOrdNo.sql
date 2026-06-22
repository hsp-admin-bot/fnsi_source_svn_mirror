UPDATE
  ord_treat_condition
SET
  is_del = '1',
  is_disp = '0',
  up_date = /*upDate*/null
WHERE
  ord_no = /*ordNo*/0
and
  is_del = '0'
and
  is_disp = '1'
;
