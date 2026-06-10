insert into sys_system_define 
  (ctl_no, service_cd, name, value, description, is_enable, up_date)
values
  (/*param.ctlNo*/0, 
  /*param.serviceCd*/'000', 
  /*param.name*/'000', 
  /*param.value*/'{"0":"1"}'::JSONB,
  /*param.description*/'xxx',
  /*param.isEnable*/0,
  CURRENT_TIMESTAMP)
;