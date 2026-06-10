-- システム設定
DELETE FROM sys_system_define Where ctl_no = 15;

INSERT INTO sys_system_define (
  ctl_no, 
  service_cd, 
  name, 
  value, 
  description, 
  is_enable, 
  up_date
) VALUES (
  15, 
  '003', 
  'カードアクセスアプリケーション', 
  '{"version":"1.0.0.0"}', 
  'カードアクセスアプリケーション', 
  '1', 
  current_timestamp
);
