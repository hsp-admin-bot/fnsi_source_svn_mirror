-- システム設定
DELETE FROM sys_system_define WHERE ctl_no = 1000;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
(1000, '003', 'ログダウンロード',
 '{
  "path_output": "/tmp/ntss-admin-web"
  }',
'ログダウンロード', '1', now());