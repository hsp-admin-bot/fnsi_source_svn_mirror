update
  ord_treat_condition
set
  is_del = '1',
  up_date = /*param.upDate*/'1970/01/01 00:00:00'
where
  ord_no = /*param.ordNo*/1 and
  machine_no = /*param.machineNo*/1 and
  treat_class = /*param.treatClass*/0 and
  is_del = '0'
;
