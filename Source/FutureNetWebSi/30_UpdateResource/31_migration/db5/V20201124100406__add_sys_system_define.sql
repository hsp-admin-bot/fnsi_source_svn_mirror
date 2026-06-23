-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 30;
insert
into sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) values ( 
  30
  , '003'
  , 'データのバージョン設定'
  , '{"version": "1.0.0.0"}'
  , null, '1'
  , current_timestamp
);
