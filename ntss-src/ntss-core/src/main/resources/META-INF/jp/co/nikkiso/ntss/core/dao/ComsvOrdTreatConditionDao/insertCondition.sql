insert into ord_treat_condition
  (ord_no,
  facility_cd,
  machine_no,
  receive_date,
  treat_condition,
  treat_class,
  reg_date,
  up_date)
values
  (/*param.ordNo*/1,
  /*param.facilityCd*/'000001',
  /*param.machineNo*/1,
  /*param.receiveDate*/'1970/01/01 00:00:00',
  /*param.treatCondition*/null,
  /*param.treatClass*/0,
  /*param.regDate*/'1970/01/01 00:00:00',
  /*param.upDate*/'1970/01/01 00:00:00'
)
;
