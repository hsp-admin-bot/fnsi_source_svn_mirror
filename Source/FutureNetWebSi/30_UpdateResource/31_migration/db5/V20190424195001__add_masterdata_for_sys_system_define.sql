-- システム設定
DELETE FROM sys_system_define Where ctl_no = 2;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (2, '002', 'ログインURL', '{"url":"https://nksfn.com/ntss-admin-web/#/?key="}', 'ログイン用URLの共通部', '0', '1970/01/01')
;
