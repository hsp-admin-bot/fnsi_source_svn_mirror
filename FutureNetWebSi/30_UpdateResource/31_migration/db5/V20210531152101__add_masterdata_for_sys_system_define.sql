-- システム設定
DELETE FROM sys_system_define Where ctl_no = 1007;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES 
 (1007, '003', 'IFエッジログPath', '{"path": "/efs/{0}/IFエッジログ/"}', 'IFエッジログPath', '0', '1970/01/01');
