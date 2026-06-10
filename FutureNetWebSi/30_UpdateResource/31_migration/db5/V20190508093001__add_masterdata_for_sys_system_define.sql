-- システム設定
DELETE FROM sys_system_define Where ctl_no = 2;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (2, '001', '定期データ収集実施サーバー', '{"ip_address": ""}', 'データ収集アプリの定期収集処理を行うサーバーのIPアドレスを設定します。設定したIPアドレスに該当しないサーバーのデータ収集アプリは定期収集処理を行いません。', '1', current_timestamp)
;

DELETE FROM sys_system_define Where ctl_no = 3;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (3, '002', '定期死活監視実施サーバー', '{"ip_address": ""}', '死活監視アプリの定期監視処理を行うサーバーのIPアドレスを設定します。設定したIPアドレスに該当しないサーバーの死活監視アプリは定期監視処理を行いません。', '1', current_timestamp)
;

DELETE FROM sys_system_define Where ctl_no = 4;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (4, '003', 'ログインURL', '{"url":"https://nksfn.com/ntss-admin-web/#/?key="}', 'ログイン用URLの共通部', '0', current_timestamp)
;
