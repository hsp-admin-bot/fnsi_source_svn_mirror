DELETE FROM sys_system_define Where ctl_no = 4;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (4, '003', 'ログインURL', '{"url":"https://nksfn.com/ntss-admin-web/#/?key=", "urlHomeDialysis":"https://nksfn.com/ntss-admin-web/#/home-dialysis/?key=","urlVpn":"https://vpn.nksfn.com/ntss-admin-web/#/?key="}', 'ログイン用URLの共通部', '0', current_timestamp)
;
