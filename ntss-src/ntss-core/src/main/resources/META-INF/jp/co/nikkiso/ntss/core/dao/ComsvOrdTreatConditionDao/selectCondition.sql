select
  ord_no,
  facility_cd,
  machine_no,
  receive_date,
  treat_condition,
  treat_class
from
  ord_treat_condition
where
  ord_no = /*param.ordNo*/1
  and machine_no = /*param.machineNo*/1
  /*%if param.treatClass != null*/
  and treat_class = /*param.treatClass*/0
  /*%end*/
  and is_del = '0'
;
