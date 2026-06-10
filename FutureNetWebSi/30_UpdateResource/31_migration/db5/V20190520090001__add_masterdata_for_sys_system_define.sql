-- システム設定
DELETE FROM sys_system_define Where ctl_no = 5;
INSERT INTO sys_system_define (ctl_no, service_cd, name, value, description, is_enable, up_date) VALUES
 (5, '003', '条件送信データチェック対象型式', '{"machine_type_cd": ["069","071","072"]}', '条件送信データのチェック対象となる型式（型式マスタの型式コード）を設定します。', '1', current_timestamp)
;
